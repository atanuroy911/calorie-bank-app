import 'package:equatable/equatable.dart';
import 'nutrition.dart';

class DailySummary extends Equatable {
  final String userId;
  final DateTime date;
  final int budget;
  final int consumed;
  final int exerciseBonus;  // calories earned from exercise
  final int bankBonus;      // calories drawn from bank
  final Macros macros;      // accumulated macros for the day
  final Micros micros;      // accumulated micros for the day
  final bool endOfDayProcessed;

  const DailySummary({
    required this.userId,
    required this.date,
    required this.budget,
    this.consumed = 0,
    this.exerciseBonus = 0,
    this.bankBonus = 0,
    this.macros = const Macros(),
    this.micros = const Micros(),
    this.endOfDayProcessed = false,
  });

  // ── Convenience getters (backwards compat) ─────────────────────────────────
  double get proteinConsumedG => macros.proteinG;
  double get carbsConsumedG   => macros.carbsG;
  double get fatConsumedG     => macros.fatG;
  double get fiberConsumedG   => macros.fiberG;

  // ── Calorie math ───────────────────────────────────────────────────────────
  int get totalAvailable  => budget + exerciseBonus + bankBonus;
  int get remaining       => (totalAvailable - consumed).clamp(0, totalAvailable);
  int get deficit         => (consumed - totalAvailable).clamp(0, consumed);
  bool get isOverBudget   => consumed > totalAvailable;
  double get consumedPercent => totalAvailable > 0 ? consumed / totalAvailable : 0;

  DailySummary copyWith({
    int? consumed,
    int? exerciseBonus,
    int? bankBonus,
    Macros? macros,
    Micros? micros,
    bool? endOfDayProcessed,
    // Legacy field names for callers that haven't migrated yet
    double? proteinConsumedG,
    double? carbsConsumedG,
    double? fatConsumedG,
    double? fiberConsumedG,
  }) {
    // Build updated macros — supports both the new Macros object and legacy
    // individual field overrides so existing callers don't break
    final newMacros = macros ??
        (this.macros).copyWith(
          proteinG: proteinConsumedG,
          carbsG: carbsConsumedG,
          fatG: fatConsumedG,
          fiberG: fiberConsumedG,
        );

    return DailySummary(
      userId: userId,
      date: date,
      budget: budget,
      consumed: consumed ?? this.consumed,
      exerciseBonus: exerciseBonus ?? this.exerciseBonus,
      bankBonus: bankBonus ?? this.bankBonus,
      macros: newMacros,
      micros: micros ?? this.micros,
      endOfDayProcessed: endOfDayProcessed ?? this.endOfDayProcessed,
    );
  }

  @override
  List<Object?> get props => [userId, date, consumed, budget];
}
