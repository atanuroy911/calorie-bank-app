import 'package:equatable/equatable.dart';
import 'nutrition.dart';

class FoodItem extends Equatable {
  final String name;
  final String quantity;
  final int calories;
  final Macros macros;
  final Micros micros;

  const FoodItem({
    required this.name,
    required this.quantity,
    required this.calories,
    this.macros = const Macros(),
    this.micros = const Micros(),
  });

  // ── Convenience getters (backwards compat with existing UI) ────────────────
  double get proteinG => macros.proteinG;
  double get carbsG => macros.carbsG;
  double get fatG => macros.fatG;
  double get fiberG => macros.fiberG;
  double get sugarG => macros.sugarG;
  double get saturatedFatG => macros.saturatedFatG;
  double get cholesterolMg => macros.cholesterolMg;
  double get sodiumMg => micros.sodiumMg;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'calories': calories,
        ...macros.toJson(),
        ...micros.toJson(),
      };

  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
        name: j['name'] as String? ?? '',
        quantity: j['quantity'] as String? ?? '',
        calories: (j['calories'] as num?)?.toInt() ?? 0,
        macros: Macros.fromJson(j),
        micros: Micros.fromJson(j),
      );

  @override
  List<Object?> get props => [name, quantity, calories];
}

class FoodEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final String mealType; // breakfast | lunch | dinner | snack
  final List<FoodItem> foods;
  final int totalCalories;
  final Macros totalMacros;
  final Micros totalMicros;
  final String? aiSessionId;
  final String userId;

  const FoodEntry({
    required this.id,
    required this.timestamp,
    required this.mealType,
    required this.foods,
    required this.totalCalories,
    this.totalMacros = const Macros(),
    this.totalMicros = const Micros(),
    this.aiSessionId,
    required this.userId,
  });

  // ── Convenience getters for existing code ──────────────────────────────────
  double get totalProteinG => totalMacros.proteinG;
  double get totalCarbsG => totalMacros.carbsG;
  double get totalFatG => totalMacros.fatG;
  double get totalFiberG => totalMacros.fiberG;

  factory FoodEntry.fromFoods({
    required String id,
    required String mealType,
    required List<FoodItem> foods,
    String? aiSessionId,
    required String userId,
  }) {
    final totalMacros = foods.fold(
      const Macros(),
      (acc, f) => acc + f.macros,
    );
    final totalMicros = foods.fold(
      const Micros(),
      (acc, f) => acc + f.micros,
    );
    return FoodEntry(
      id: id,
      timestamp: DateTime.now(),
      mealType: mealType,
      foods: foods,
      totalCalories: foods.fold(0, (sum, f) => sum + f.calories),
      totalMacros: totalMacros,
      totalMicros: totalMicros,
      aiSessionId: aiSessionId,
      userId: userId,
    );
  }

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast': return 'Breakfast';
      case 'lunch':     return 'Lunch';
      case 'dinner':    return 'Dinner';
      case 'snack':     return 'Snack';
      default:          return mealType;
    }
  }

  @override
  List<Object?> get props => [id, timestamp, totalCalories];
}
