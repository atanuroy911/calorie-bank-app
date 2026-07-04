extension NumExtensions on num {
  /// Format as calorie display: 1400 → "1,400"
  String get kcalFormatted {
    if (this >= 1000) {
      final thousands = (this / 1000).floor();
      final remainder = (this % 1000).round();
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return round().toString();
  }

  /// Format as short calorie: 1400 → "1.4k", 950 → "950"
  String get kcalShort {
    if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}k';
    }
    return round().toString();
  }

  /// Format grams: 45.6 → "45.6g"
  String get gramFormatted => '${toStringAsFixed(1)}g';

  /// Clamp progress to 0..1
  double get clampedProgress => clamp(0.0, 1.0).toDouble();

  /// Percentage of a total
  double percentOf(num total) {
    if (total == 0) return 0;
    return (this / total * 100).clamp(0, 999).toDouble();
  }
}

extension IntExtensions on int {
  /// Calories with sign: +400, -700
  String get signedKcal => this >= 0 ? '+$kcalFormatted kcal' : '-${(-this).kcalFormatted} kcal';
}
