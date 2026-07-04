import 'package:sqflite/sqflite.dart';
import '../../domain/entities/calorie_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/isar_service.dart';

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<void> addTransaction(CalorieTransaction t) async {
    final db = await DatabaseService.instance;
    await db.insert(
      'calorie_transactions',
      {
        'id': t.id,
        'user_id': t.userId,
        'timestamp': t.timestamp.toIso8601String(),
        'date_key': t.date,
        'type': t.type.name,
        'calories': t.calories,
        'label': t.label,
        'food_entry_id': t.foodEntryId,
        'exercise_entry_id': t.exerciseEntryId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<CalorieTransaction>> getTransactionsForDate(
      String userId, DateTime date) async {
    final db = await DatabaseService.instance;
    final rows = await db.query(
      'calorie_transactions',
      where: 'user_id = ? AND date_key = ?',
      whereArgs: [userId, _dateKey(date)],
      orderBy: 'timestamp DESC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<CalorieTransaction>> getRecentTransactions(String userId,
      {int limit = 20}) async {
    final db = await DatabaseService.instance;
    final rows = await db.query(
      'calorie_transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Stream<List<CalorieTransaction>> watchTransactionsForDate(
      String userId, DateTime date) async* {
    while (true) {
      yield await getTransactionsForDate(userId, date);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  CalorieTransaction _fromRow(Map<String, dynamic> row) {
    final type = TransactionType.values.firstWhere(
      (e) => e.name == row['type'],
      orElse: () => TransactionType.manualAdjustment,
    );
    return CalorieTransaction(
      id: row['id'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      type: type,
      calories: row['calories'] as int,
      label: row['label'] as String,
      foodEntryId: row['food_entry_id'] as String?,
      exerciseEntryId: row['exercise_entry_id'] as String?,
      userId: row['user_id'] as String,
      date: row['date_key'] as String,
    );
  }
}
