import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/entities/daily_summary.dart';
import '../../../domain/entities/nutrition.dart';

class MacroProgressCard extends StatelessWidget {
  final UserProfile profile;
  final DailySummary summary;

  const MacroProgressCard({
    super.key,
    required this.profile,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final macros = summary.macros;

    return GestureDetector(
      onTap: () => context.push('/nutrition'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Macros Today', style: AppTextStyles.titleLarge),
                const Spacer(),
                Text(
                  'Full Nutrition →',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _MacroRing(
                  label: 'Protein',
                  consumed: macros.proteinG,
                  goal: profile.dailyProteinGoalG,
                  color: AppColors.protein,
                ),
                const SizedBox(width: 10),
                _MacroRing(
                  label: 'Carbs',
                  consumed: macros.carbsG,
                  goal: profile.dailyCarbsGoalG,
                  color: AppColors.carbs,
                ),
                const SizedBox(width: 10),
                _MacroRing(
                  label: 'Fat',
                  consumed: macros.fatG,
                  goal: profile.dailyFatGoalG,
                  color: AppColors.fat,
                ),
                const SizedBox(width: 10),
                _MacroRing(
                  label: 'Fiber',
                  consumed: macros.fiberG,
                  goal: DailyReferenceValues.fiberG,
                  color: const Color(0xFF66BB6A),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Quick micro highlights
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MicroChip('Na', '${summary.micros.sodiumMg.toStringAsFixed(0)}mg',
                    summary.micros.sodiumMg > DailyReferenceValues.sodiumMg
                        ? AppColors.negative
                        : AppColors.textMuted),
                _MicroChip('K', '${summary.micros.potassiumMg.toStringAsFixed(0)}mg',
                    AppColors.textMuted),
                _MicroChip('Ca', '${summary.micros.calciumMg.toStringAsFixed(0)}mg',
                    AppColors.textMuted),
                _MicroChip('Fe', '${summary.micros.ironMg.toStringAsFixed(0)}mg',
                    AppColors.textMuted),
                _MicroChip('Vit C', '${summary.micros.vitaminCMg.toStringAsFixed(0)}mg',
                    AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MicroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MicroChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.labelSmall
            .copyWith(color: color, fontSize: 10),
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  final String label;
  final double consumed;
  final double goal;
  final Color color;

  const _MacroRing({
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (consumed / goal).clamp(0.0, 1.0) : 0.0;
    final remaining = (goal - consumed).clamp(0.0, goal);

    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 72,
            width: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 24,
                    sections: [
                      PieChartSectionData(
                        color: color,
                        value: consumed > 0 ? consumed : 0.001,
                        radius: 10,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: AppColors.cardBorder,
                        value: remaining > 0 ? remaining : 0.001,
                        radius: 10,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${consumed.toStringAsFixed(0)}g',
            style: AppTextStyles.titleMedium.copyWith(color: color, fontSize: 13),
          ),
          Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
          Text(
            '/ ${goal.toStringAsFixed(0)}g',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textMuted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
