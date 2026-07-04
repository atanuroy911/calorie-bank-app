import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF131929);
  static const Color surfaceElevated = Color(0xFF1A2235);
  static const Color cardBorder = Color(0xFF1E2D45);

  // Brand
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00A882);
  static const Color primaryLight = Color(0xFF33DDBB);
  static const Color accent = Color(0xFF7B61FF);
  static const Color accentLight = Color(0xFF9B85FF);

  // Semantic
  static const Color positive = Color(0xFF00C97B);
  static const Color negative = Color(0xFFFF4757);
  static const Color warning = Color(0xFFFFB347);
  static const Color info = Color(0xFF4ECDC4);

  // Text
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8896B0);
  static const Color textMuted = Color(0xFF4A5568);
  static const Color textOnPrimary = Color(0xFF0A0E1A);

  // Chart / Progress
  static const Color protein = Color(0xFF7B61FF);
  static const Color carbs = Color(0xFFFF8C42);
  static const Color fat = Color(0xFFFF4757);
  static const Color fiber = Color(0xFF00C97B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF00A882)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF7B61FF), Color(0xFF5A45CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bankGradient = LinearGradient(
    colors: [Color(0xFF1A2235), Color(0xFF0D1526)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2235), Color(0xFF131929)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient positiveGradient = LinearGradient(
    colors: [Color(0xFF00C97B), Color(0xFF00A862)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient negativeGradient = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFCC3344)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
