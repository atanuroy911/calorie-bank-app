import '../entities/food_entry.dart';

abstract class FoodLogRepository {
  Future<void> addFoodEntry(FoodEntry entry);
  Future<void> deleteFoodEntry(String entryId);
  Future<List<FoodEntry>> getEntriesForDate(String userId, DateTime date);
  Stream<List<FoodEntry>> watchEntriesForDate(String userId, DateTime date);
}
