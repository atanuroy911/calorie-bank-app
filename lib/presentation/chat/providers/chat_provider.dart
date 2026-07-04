import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/datasources/remote/custom_backend_datasource.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/entities/food_entry.dart';
import '../../../domain/entities/exercise_entry.dart';
import '../../../domain/entities/calorie_transaction.dart';
import '../../../domain/entities/daily_summary.dart';

final _uuid = const Uuid();

class ChatState {
  final String sessionId;
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  const ChatState({
    required this.sessionId,
    this.messages = const [],
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      sessionId: sessionId,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class ChatNotifier extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(sessionId: _uuid.v4());
  }

  Future<void> sendMessage(String userText) async {
    if (userText.trim().isEmpty) return;

    final userId =
        ref.read(preferencesServiceProvider).userId ?? 'unknown';

    // Add user message immediately
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      sessionId: state.sessionId,
      role: ChatRole.user,
      content: userText,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sent,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      error: null,
    );

    try {
      // Check AI usage limit
      final prefs = ref.read(preferencesServiceProvider);
      final profile =
          await ref.read(userProfileRepositoryProvider).getProfile(userId);
      final limit = (profile?.isPremium ?? false)
          ? AppConstants.premiumTierAiDailyLimit
          : AppConstants.freeTierAiDailyLimit;

      if (prefs.aiUsageToday >= limit) {
        final limitMsg = ChatMessage(
          id: _uuid.v4(),
          sessionId: state.sessionId,
          role: ChatRole.assistant,
          content:
              '⚠️ You\'ve reached your daily AI limit ($limit messages). Upgrade to Premium for unlimited access, or add your own API key in Settings.',
          timestamp: DateTime.now(),
        );
        state = state.copyWith(
          messages: [...state.messages, limitMsg],
          isSending: false,
        );
        return;
      }

      // Build user context — gives server richer signals for model routing
      final todaySummary = await ref
          .read(dailySummaryRepositoryProvider)
          .getSummaryForDate(userId, DateTime.now());
      final bankAccount = await ref
          .read(bankRepositoryProvider)
          .getBankAccount(userId);

      final userContext = {
        'daily_budget': todaySummary?.budget ?? 0,
        'consumed_today': todaySummary?.consumed ?? 0,
        'remaining_today': todaySummary?.remaining ?? 0,
        'bank_balance': bankAccount.balance,
        'user_id': userId,
      };

      // Call AI (custom backend or direct provider)
      final response = await ref.read(aiRepositoryProvider).sendMessage(
            sessionId: state.sessionId,
            history: state.messages
                .where((m) => m.status == ChatMessageStatus.sent)
                .toList(),
            userMessage: userText,
            userContext: userContext,
          );

      await prefs.incrementAiUsage();

      // Build assistant message
      bool hasFoodLog = false;
      bool hasExerciseLog = false;

      if (response.isFoodLog && response.data != null) {
        hasFoodLog = await _processFoodLog(userId, response.data!);
      } else if (response.isExerciseLog && response.data != null) {
        hasExerciseLog = await _processExerciseLog(userId, response.data!);
      } else if (response.isBankWithdraw && response.data != null) {
        await _processBankWithdraw(userId, response.data!);
      }

      final assistantMsg = ChatMessage(
        id: _uuid.v4(),
        sessionId: state.sessionId,
        role: ChatRole.assistant,
        content: response.message,
        timestamp: DateTime.now(),
        status: ChatMessageStatus.sent,
        hasFoodLog: hasFoodLog,
        hasExerciseLog: hasExerciseLog,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isSending: false,
      );
    } on AiBackendException catch (e) {
      // Structured backend errors get a friendly, actionable message
      final errorMsg = ChatMessage(
        id: _uuid.v4(),
        sessionId: state.sessionId,
        role: ChatRole.assistant,
        content: e.userMessage,
        timestamp: DateTime.now(),
        status: ChatMessageStatus.error,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isSending: false,
        error: e.userMessage,
      );
    } on Exception catch (e) {
      // Generic errors — strip noise
      final msg = e.toString().replaceAll('Exception:', '').trim();
      final errorMsg = ChatMessage(
        id: _uuid.v4(),
        sessionId: state.sessionId,
        role: ChatRole.assistant,
        content: '❌ $msg',
        timestamp: DateTime.now(),
        status: ChatMessageStatus.error,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isSending: false,
        error: msg,
      );
    }
  }

  Future<bool> _processFoodLog(
      String userId, Map<String, dynamic> data) async {
    try {
      final mealType = data['meal_type'] as String? ?? 'snack';
      final foodsData = (data['foods'] as List<dynamic>?) ?? [];
      final foods = foodsData
          .map((f) => FoodItem.fromJson(f as Map<String, dynamic>))
          .toList();

      final entry = FoodEntry.fromFoods(
        id: _uuid.v4(),
        mealType: mealType,
        foods: foods,
        aiSessionId: state.sessionId,
        userId: userId,
      );

      await ref.read(foodLogRepositoryProvider).addFoodEntry(entry);

      // Create withdrawal transaction
      final tx = CalorieTransaction(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        type: TransactionType.foodWithdrawal,
        calories: entry.totalCalories,
        label: '${entry.mealTypeLabel} • ${foods.map((f) => f.name).join(', ')}',
        foodEntryId: entry.id,
        userId: userId,
        date: _dateKey(DateTime.now()),
      );
      await ref.read(transactionRepositoryProvider).addTransaction(tx);

      // Update daily summary
      await _updateDailySummary(userId, entry.totalCalories, entry);

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _processExerciseLog(
      String userId, Map<String, dynamic> data) async {
    try {
      final entry = ExerciseEntry(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        exerciseName: data['exercise_name'] as String? ?? 'Exercise',
        durationMinutes: (data['duration_minutes'] as num?)?.toInt() ?? 0,
        caloriesBurned: (data['calories_burned'] as num?)?.toInt() ?? 0,
        notes: data['notes'] as String?,
        userId: userId,
      );

      // Create exercise deposit transaction
      final tx = CalorieTransaction(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        type: TransactionType.exerciseDeposit,
        calories: entry.caloriesBurned,
        label: '${entry.exerciseName} • ${entry.durationMinutes} min',
        exerciseEntryId: entry.id,
        userId: userId,
        date: _dateKey(DateTime.now()),
      );
      await ref.read(transactionRepositoryProvider).addTransaction(tx);

      // Update daily summary (add exercise bonus)
      final summaryRepo = ref.read(dailySummaryRepositoryProvider);
      final today = DateTime.now();
      final summary = await summaryRepo.getSummaryForDate(userId, today);
      if (summary != null) {
        await summaryRepo.updateSummary(summary.copyWith(
          exerciseBonus: summary.exerciseBonus + entry.caloriesBurned,
        ));
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _processBankWithdraw(
      String userId, Map<String, dynamic> data) async {
    try {
      final calories = (data['calories'] as num?)?.toInt() ?? 0;
      final reason = data['reason'] as String? ?? 'Bank Withdrawal';

      await ref.read(bankRepositoryProvider).withdraw(userId, calories, reason);

      // Update daily summary (bank bonus)
      final summaryRepo = ref.read(dailySummaryRepositoryProvider);
      final today = DateTime.now();
      final summary = await summaryRepo.getSummaryForDate(userId, today);
      if (summary != null) {
        await summaryRepo.updateSummary(
          summary.copyWith(bankBonus: summary.bankBonus + calories),
        );
      }
    } catch (_) {}
  }

  Future<void> _updateDailySummary(
      String userId, int calories, FoodEntry entry) async {
    final summaryRepo = ref.read(dailySummaryRepositoryProvider);
    final profile =
        await ref.read(userProfileRepositoryProvider).getProfile(userId);
    final today = DateTime.now();

    var summary = await summaryRepo.getSummaryForDate(userId, today);
    summary ??= DailySummary(
      userId: userId,
      date: today,
      budget: profile?.dailyCalorieBudget ?? 2000,
    );

    final updated = summary.copyWith(
      consumed: summary.consumed + calories,
      macros: summary.macros + entry.totalMacros,
      micros: summary.micros + entry.totalMicros,
    );

    if (await summaryRepo.getSummaryForDate(userId, today) == null) {
      await summaryRepo.saveSummary(updated);
    } else {
      await summaryRepo.updateSummary(updated);
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void clearError() => state = state.copyWith(error: null);
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
