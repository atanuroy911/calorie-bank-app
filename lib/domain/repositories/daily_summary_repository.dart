import '../entities/daily_summary.dart';

abstract class DailySummaryRepository {
  Future<DailySummary?> getSummaryForDate(String userId, DateTime date);
  Future<void> saveSummary(DailySummary summary);
  Future<void> updateSummary(DailySummary summary);
  Stream<DailySummary?> watchSummaryForDate(String userId, DateTime date);
}
