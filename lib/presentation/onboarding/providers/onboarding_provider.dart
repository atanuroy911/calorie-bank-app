import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../core/utils/calorie_calculator.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/entities/daily_summary.dart';

class OnboardingState {
  final int currentPage;
  final String name;
  final String email;
  final int age;
  final String gender; // male | female | other
  final String unitSystem; // metric | imperial
  final double heightCm;
  final double currentWeightKg;
  final double goalWeightKg;
  final String activityLevel;
  final String goal;
  final bool isSubmitting;
  final String? error;

  const OnboardingState({
    this.currentPage = 0,
    this.name = '',
    this.email = '',
    this.age = 25,
    this.gender = 'male',
    this.unitSystem = 'metric',
    this.heightCm = 170,
    this.currentWeightKg = 70,
    this.goalWeightKg = 65,
    this.activityLevel = 'moderate',
    this.goal = 'weight_loss',
    this.isSubmitting = false,
    this.error,
  });

  OnboardingState copyWith({
    int? currentPage,
    String? name,
    String? email,
    int? age,
    String? gender,
    String? unitSystem,
    double? heightCm,
    double? currentWeightKg,
    double? goalWeightKg,
    String? activityLevel,
    String? goal,
    bool? isSubmitting,
    String? error,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      unitSystem: unitSystem ?? this.unitSystem,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  NutritionGoals get calculatedGoals => CalorieCalculator.calculateFromProfile(
        weightKg: currentWeightKg,
        heightCm: heightCm,
        age: age,
        gender: gender,
        activityLevel: activityLevel,
        goal: goal,
      );
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void nextPage() => state = state.copyWith(currentPage: state.currentPage + 1);
  void prevPage() =>
      state = state.copyWith(currentPage: (state.currentPage - 1).clamp(0, 3));

  void updateName(String v) => state = state.copyWith(name: v);
  void updateEmail(String v) => state = state.copyWith(email: v);
  void updateAge(int v) => state = state.copyWith(age: v);
  void updateGender(String v) => state = state.copyWith(gender: v);
  void updateUnitSystem(String v) => state = state.copyWith(unitSystem: v);
  void updateHeight(double v) => state = state.copyWith(heightCm: v);
  void updateCurrentWeight(double v) =>
      state = state.copyWith(currentWeightKg: v);
  void updateGoalWeight(double v) => state = state.copyWith(goalWeightKg: v);
  void updateActivityLevel(String v) => state = state.copyWith(activityLevel: v);
  void updateGoal(String v) => state = state.copyWith(goal: v);

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final prefs = ref.read(preferencesServiceProvider);
      final userId = prefs.userId ?? const Uuid().v4();
      final goals = state.calculatedGoals;

      final profile = UserProfile(
        id: userId,
        email: state.email,
        displayName: state.name,
        age: state.age,
        gender: state.gender,
        heightCm: state.heightCm,
        currentWeightKg: state.currentWeightKg,
        goalWeightKg: state.goalWeightKg,
        activityLevel: state.activityLevel,
        goal: state.goal,
        dailyCalorieBudget: goals.dailyCalories,
        dailyProteinGoalG: goals.proteinG,
        dailyCarbsGoalG: goals.carbsG,
        dailyFatGoalG: goals.fatG,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ref.read(userProfileRepositoryProvider).saveProfile(profile);

      // Create today's daily summary
      final today = DateTime.now();
      final summary = DailySummary(
        userId: userId,
        date: today,
        budget: goals.dailyCalories,
      );
      await ref.read(dailySummaryRepositoryProvider).saveSummary(summary);

      await prefs.setOnboardingComplete(true);
      await prefs.setLastActiveDate(today);

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
