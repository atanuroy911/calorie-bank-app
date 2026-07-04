import '../entities/calorie_transaction.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(CalorieTransaction transaction);
  Future<List<CalorieTransaction>> getTransactionsForDate(String userId, DateTime date);
  Future<List<CalorieTransaction>> getRecentTransactions(String userId, {int limit = 20});
  Stream<List<CalorieTransaction>> watchTransactionsForDate(String userId, DateTime date);
}
