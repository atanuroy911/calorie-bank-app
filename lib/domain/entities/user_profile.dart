import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final int age;
  final String gender; // 'male' | 'female' | 'other'
  final double heightCm;
  final double currentWeightKg;
  final double goalWeightKg;
  final String activityLevel; // sedentary | light | moderate | active | very_active
  final String goal; // weight_loss | maintenance | weight_gain
  final int dailyCalorieBudget;
  final double dailyProteinGoalG;
  final double dailyCarbsGoalG;
  final double dailyFatGoalG;
  final double dailyFiberGoalG;
  final double dailySugarGoalG;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    required this.goalWeightKg,
    required this.activityLevel,
    required this.goal,
    required this.dailyCalorieBudget,
    required this.dailyProteinGoalG,
    required this.dailyCarbsGoalG,
    required this.dailyFatGoalG,
    this.dailyFiberGoalG = 28,
    this.dailySugarGoalG = 50,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? displayName,
    int? age,
    String? gender,
    double? heightCm,
    double? currentWeightKg,
    double? goalWeightKg,
    String? activityLevel,
    String? goal,
    int? dailyCalorieBudget,
    double? dailyProteinGoalG,
    double? dailyCarbsGoalG,
    double? dailyFatGoalG,
    double? dailyFiberGoalG,
    double? dailySugarGoalG,
    bool? isPremium,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyCalorieBudget: dailyCalorieBudget ?? this.dailyCalorieBudget,
      dailyProteinGoalG: dailyProteinGoalG ?? this.dailyProteinGoalG,
      dailyCarbsGoalG: dailyCarbsGoalG ?? this.dailyCarbsGoalG,
      dailyFatGoalG: dailyFatGoalG ?? this.dailyFatGoalG,
      dailyFiberGoalG: dailyFiberGoalG ?? this.dailyFiberGoalG,
      dailySugarGoalG: dailySugarGoalG ?? this.dailySugarGoalG,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, email, dailyCalorieBudget, isPremium];
}
