import '../entities/bank_account.dart';
import '../entities/calorie_transaction.dart';

abstract class BankRepository {
  Future<BankAccount> getBankAccount(String userId);
  Future<void> updateBankBalance(String userId, int newBalance);
  Future<void> deposit(String userId, int calories, String label);
  Future<void> withdraw(String userId, int calories, String label);
  Stream<BankAccount> watchBankAccount(String userId);
  Future<List<CalorieTransaction>> getBankTransactions(String userId, {int limit = 30});
}
