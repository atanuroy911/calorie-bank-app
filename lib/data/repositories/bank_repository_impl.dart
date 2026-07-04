import 'package:uuid/uuid.dart';
import '../../domain/entities/bank_account.dart';
import '../../domain/entities/calorie_transaction.dart';
import '../../domain/repositories/bank_repository.dart';
import '../datasources/local/isar_service.dart';

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class BankRepositoryImpl implements BankRepository {
  final _uuid = const Uuid();

  @override
  Future<BankAccount> getBankAccount(String userId) async {
    final db = await DatabaseService.instance;
    final rows = await db.query(
      'bank_accounts',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (rows.isEmpty) {
      final account = BankAccount(
        userId: userId,
        balance: 0,
        lastUpdated: DateTime.now(),
      );
      await db.insert('bank_accounts', {
        'user_id': userId,
        'balance': 0,
        'last_updated': DateTime.now().toIso8601String(),
      });
      return account;
    }
    return BankAccount(
      userId: rows.first['user_id'] as String,
      balance: rows.first['balance'] as int,
      lastUpdated:
          DateTime.parse(rows.first['last_updated'] as String),
    );
  }

  @override
  Future<void> updateBankBalance(String userId, int newBalance) async {
    final db = await DatabaseService.instance;
    await db.update(
      'bank_accounts',
      {
        'balance': newBalance,
        'last_updated': DateTime.now().toIso8601String(),
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  @override
  Future<void> deposit(String userId, int calories, String label) async {
    final account = await getBankAccount(userId);
    await updateBankBalance(userId, account.balance + calories);

    final now = DateTime.now();
    final db = await DatabaseService.instance;
    await db.insert('calorie_transactions', {
      'id': _uuid.v4(),
      'user_id': userId,
      'timestamp': now.toIso8601String(),
      'date_key': _dateKey(now),
      'type': TransactionType.dailySavingsDeposit.name,
      'calories': calories,
      'label': label,
      'food_entry_id': null,
      'exercise_entry_id': null,
    });
  }

  @override
  Future<void> withdraw(String userId, int calories, String label) async {
    final account = await getBankAccount(userId);
    final newBalance = (account.balance - calories).clamp(0, account.balance);
    await updateBankBalance(userId, newBalance);

    final now = DateTime.now();
    final db = await DatabaseService.instance;
    await db.insert('calorie_transactions', {
      'id': _uuid.v4(),
      'user_id': userId,
      'timestamp': now.toIso8601String(),
      'date_key': _dateKey(now),
      'type': TransactionType.bankWithdrawal.name,
      'calories': calories,
      'label': label,
      'food_entry_id': null,
      'exercise_entry_id': null,
    });
  }

  @override
  Stream<BankAccount> watchBankAccount(String userId) async* {
    while (true) {
      yield await getBankAccount(userId);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Future<List<CalorieTransaction>> getBankTransactions(String userId,
      {int limit = 30}) async {
    final db = await DatabaseService.instance;
    final rows = await db.query(
      'calorie_transactions',
      where: "user_id = ? AND (type = ? OR type = ?)",
      whereArgs: [
        userId,
        TransactionType.dailySavingsDeposit.name,
        TransactionType.bankWithdrawal.name,
      ],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows
        .map((row) => CalorieTransaction(
              id: row['id'] as String,
              timestamp:
                  DateTime.parse(row['timestamp'] as String),
              type: TransactionType.values.firstWhere(
                  (e) => e.name == row['type'],
                  orElse: () => TransactionType.manualAdjustment),
              calories: row['calories'] as int,
              label: row['label'] as String,
              userId: row['user_id'] as String,
              date: row['date_key'] as String,
            ))
        .toList();
  }
}
