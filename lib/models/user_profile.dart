import 'dart:convert';

enum Sex { male, female, other }

enum ExerciseLevel {
  none, // Sedentary
  slight, // Light exercise 1-2 days/week
  moderate, // Moderate exercise 3-5 days/week
  active, // Active exercise 6-7 days/week
  veryActive, // Very active / athlete
}

class UserProfile {
  final String name;
  final int age;
  final Sex sex;
  final double weight; // in kg
  final double height; // in cm
  final double targetWeight; // in kg
  final int daysToTarget;
  final ExerciseLevel exerciseLevel;

  UserProfile({
    required this.name,
    required this.age,
    required this.sex,
    required this.weight,
    required this.height,
    required this.targetWeight,
    required this.daysToTarget,
    required this.exerciseLevel,
  });

  // Calculate BMR using Mifflin-St Jeor Equation
  double get bmr {
    double baseBMR = (10 * weight) + (6.25 * height) - (5 * age);
    switch (sex) {
      case Sex.male:
        return baseBMR + 5;
      case Sex.female:
        return baseBMR - 161;
      case Sex.other:
        return baseBMR - 80; // Average of male and female
    }
  }

  // Get activity multiplier based on exercise level
  double get activityMultiplier {
    switch (exerciseLevel) {
      case ExerciseLevel.none:
        return 1.2;
      case ExerciseLevel.slight:
        return 1.375;
      case ExerciseLevel.moderate:
        return 1.55;
      case ExerciseLevel.active:
        return 1.725;
      case ExerciseLevel.veryActive:
        return 1.9;
    }
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  double get tdee => bmr * activityMultiplier;

  // Calculate daily calorie target
  double get dailyCalorieTarget {
    // Weight difference in kg
    double weightDiff = targetWeight - weight;

    // Calories needed per kg of weight change (approximately 7700 cal/kg)
    double totalCalorieChange = weightDiff * 7700;

    // Daily calorie change needed
    double dailyCalorieChange = totalCalorieChange / daysToTarget;

    // Target = TDEE + daily change (negative for weight loss, positive for gain)
    return tdee + dailyCalorieChange;
  }

  // Check if trying to lose weight
  bool get isLosingWeight => targetWeight < weight;

  // Check if trying to gain weight
  bool get isGainingWeight => targetWeight > weight;

  // Check if maintaining weight
  bool get isMaintaining => targetWeight == weight;

  // BMI calculation
  double get bmi => weight / ((height / 100) * (height / 100));

  // Target BMI
  double get targetBmi => targetWeight / ((height / 100) * (height / 100));

  // Serialization
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'sex': sex.name,
      'weight': weight,
      'height': height,
      'targetWeight': targetWeight,
      'daysToTarget': daysToTarget,
      'exerciseLevel': exerciseLevel.name,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      sex: Sex.values.firstWhere((e) => e.name == json['sex']),
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      daysToTarget: json['daysToTarget'] as int,
      exerciseLevel: ExerciseLevel.values.firstWhere(
        (e) => e.name == json['exerciseLevel'],
      ),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserProfile.fromJsonString(String jsonString) =>
      UserProfile.fromJson(jsonDecode(jsonString));

  UserProfile copyWith({
    String? name,
    int? age,
    Sex? sex,
    double? weight,
    double? height,
    double? targetWeight,
    int? daysToTarget,
    ExerciseLevel? exerciseLevel,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      targetWeight: targetWeight ?? this.targetWeight,
      daysToTarget: daysToTarget ?? this.daysToTarget,
      exerciseLevel: exerciseLevel ?? this.exerciseLevel,
    );
  }
}

// Extension to get user-friendly labels
extension ExerciseLevelExtension on ExerciseLevel {
  String get label {
    switch (this) {
      case ExerciseLevel.none:
        return 'None (Sedentary)';
      case ExerciseLevel.slight:
        return 'Slight (1-2 days/week)';
      case ExerciseLevel.moderate:
        return 'Moderate (3-5 days/week)';
      case ExerciseLevel.active:
        return 'Active (6-7 days/week)';
      case ExerciseLevel.veryActive:
        return 'Very Active (Athlete)';
    }
  }

  String get description {
    switch (this) {
      case ExerciseLevel.none:
        return 'Little or no exercise';
      case ExerciseLevel.slight:
        return 'Light exercise or sports 1-2 days per week';
      case ExerciseLevel.moderate:
        return 'Moderate exercise 3-5 days per week';
      case ExerciseLevel.active:
        return 'Hard exercise 6-7 days per week';
      case ExerciseLevel.veryActive:
        return 'Very hard exercise, physical job, or training twice per day';
    }
  }
}

extension SexExtension on Sex {
  String get label {
    switch (this) {
      case Sex.male:
        return 'Male';
      case Sex.female:
        return 'Female';
      case Sex.other:
        return 'Other';
    }
  }
}
