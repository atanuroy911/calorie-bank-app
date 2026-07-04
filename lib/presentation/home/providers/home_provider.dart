import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/daily_summary.dart';
import '../../../domain/entities/food_entry.dart';
import '../../../domain/entities/calorie_transaction.dart';
import '../../../domain/entities/bank_account.dart';
import '../../../domain/entities/user_profile.dart';

// Current user ID (from preferences)
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(preferencesServiceProvider).userId;
});

// Watch today's daily summary
final todaysSummaryProvider = StreamProvider<DailySummary?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(dailySummaryRepositoryProvider).watchSummaryForDate(
        userId,
        DateTime.now(),
      );
});

// Watch bank account
final bankAccountProvider = StreamProvider<BankAccount>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(bankRepositoryProvider).watchBankAccount(userId);
});

// Watch today's food entries
final todaysFoodEntriesProvider = StreamProvider<List<FoodEntry>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(foodLogRepositoryProvider).watchEntriesForDate(
        userId,
        DateTime.now(),
      );
});

// Watch today's transactions
final todaysTransactionsProvider =
    StreamProvider<List<CalorieTransaction>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(transactionRepositoryProvider).watchTransactionsForDate(
        userId,
        DateTime.now(),
      );
});

// User profile
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream<UserProfile?>.empty();
  return ref.watch(userProfileRepositoryProvider).watchProfile(userId);
});

// End-of-day check and processing
final endOfDayCheckerProvider = FutureProvider<void>((ref) async {
  final prefs = ref.read(preferencesServiceProvider);
  final userId = prefs.userId;
  if (userId == null) return;

  final lastActive = prefs.lastActiveDate;
  final today = DateTime.now();

  // If lastActiveDate is not today, process end of day for yesterday
  if (lastActive != null &&
      !(lastActive.year == today.year &&
          lastActive.month == today.month &&
          lastActive.day == today.day)) {
    final yesterday = lastActive;
    final summaryRepo = ref.read(dailySummaryRepositoryProvider);
    final bankRepo = ref.read(bankRepositoryProvider);

    final summary = await summaryRepo.getSummaryForDate(userId, yesterday);
    if (summary != null && !summary.endOfDayProcessed) {
      final remaining = summary.remaining;
      if (remaining > 0) {
        await bankRepo.deposit(userId, remaining, 'Daily Savings — ${_dateLabel(yesterday)}');
      }
      await summaryRepo.updateSummary(
          summary.copyWith(endOfDayProcessed: true));
    }

    // Create today's summary if not exists
    final todaySummary = await summaryRepo.getSummaryForDate(userId, today);
    if (todaySummary == null) {
      final profile =
          await ref.read(userProfileRepositoryProvider).getProfile(userId);
      if (profile != null) {
        await summaryRepo.saveSummary(DailySummary(
          userId: userId,
          date: today,
          budget: profile.dailyCalorieBudget,
        ));
      }
    }

    await prefs.setLastActiveDate(today);
  }
});

String _dateLabel(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}';
}
