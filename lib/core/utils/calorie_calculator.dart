import '../../core/constants/app_constants.dart';

class CalorieCalculator {
  CalorieCalculator._();

  /// Mifflin-St Jeor BMR
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender, // 'male' or 'female'
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender.toLowerCase() == 'male' ? base + 5 : base - 161;
  }

  /// TDEE = BMR × activity multiplier
  static double calculateTDEE({
    required double bmr,
    required String activityLevel, // sedentary, light, moderate, active, very_active
  }) {
    final multiplier = _activityMultiplier(activityLevel);
    return bmr * multiplier;
  }

  /// Daily calorie budget = TDEE ± goal adjustment
  static int calculateDailyBudget({
    required double tdee,
    required String goal, // weight_loss, maintenance, weight_gain
  }) {
    final adjustment = _goalAdjustment(goal);
    return (tdee + adjustment).round().clamp(1200, 5000);
  }

  /// Protein goal in grams
  static double calculateProteinGoal(int dailyCalories) {
    return (dailyCalories * AppConstants.proteinPercent) /
        AppConstants.proteinKcalPerGram;
  }

  /// Carbs goal in grams
  static double calculateCarbsGoal(int dailyCalories) {
    return (dailyCalories * AppConstants.carbsPercent) /
        AppConstants.carbsKcalPerGram;
  }

  /// Fat goal in grams
  static double calculateFatGoal(int dailyCalories) {
    return (dailyCalories * AppConstants.fatPercent) /
        AppConstants.fatKcalPerGram;
  }

  /// Complete calculation from profile data
  static NutritionGoals calculateFromProfile({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    final tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel);
    final dailyCalories = calculateDailyBudget(tdee: tdee, goal: goal);

    return NutritionGoals(
      dailyCalories: dailyCalories,
      proteinG: calculateProteinGoal(dailyCalories),
      carbsG: calculateCarbsGoal(dailyCalories),
      fatG: calculateFatGoal(dailyCalories),
    );
  }

  static double _activityMultiplier(String activityLevel) {
    switch (activityLevel.toLowerCase()) {
      case 'sedentary':
        return AppConstants.sedentaryMultiplier;
      case 'light':
        return AppConstants.lightMultiplier;
      case 'moderate':
        return AppConstants.moderateMultiplier;
      case 'active':
        return AppConstants.activeMultiplier;
      case 'very_active':
        return AppConstants.veryActiveMultiplier;
      default:
        return AppConstants.moderateMultiplier;
    }
  }

  static int _goalAdjustment(String goal) {
    switch (goal.toLowerCase()) {
      case 'weight_loss':
        return AppConstants.weightLossAdjustment;
      case 'maintenance':
        return AppConstants.maintenanceAdjustment;
      case 'weight_gain':
        return AppConstants.weightGainAdjustment;
      default:
        return AppConstants.maintenanceAdjustment;
    }
  }
}

class NutritionGoals {
  final int dailyCalories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const NutritionGoals({
    required this.dailyCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });
}
