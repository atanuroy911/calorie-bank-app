import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/extensions/num_extensions.dart';
import '../../../domain/entities/daily_summary.dart';

class BalanceCard extends StatelessWidget {
  final DailySummary? summary;
  final int bankBalance;

  const BalanceCard({
    super.key,
    required this.summary,
    required this.bankBalance,
  });

  @override
  Widget build(BuildContext context) {
    final budget = summary?.totalAvailable ?? 0;
    final consumed = summary?.consumed ?? 0;
    final remaining = summary?.remaining ?? 0;
    final isOver = summary?.isOverBudget ?? false;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF131929), Color(0xFF0E1622)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Today's Account",
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    )),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '${DateTime.now().day} ${_monthName(DateTime.now().month)}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2x2 grid
            Row(
              children: [
                Expanded(
                  child: _MetricCell(
                    label: 'Daily Budget',
                    value: budget.kcalFormatted,
                    unit: 'kcal',
                    color: AppColors.primary,
                    icon: Icons.account_balance_wallet_rounded,
                  ).animate().fadeIn(delay: 100.ms),
                ),
                _Divider(isVertical: true),
                Expanded(
                  child: _MetricCell(
                    label: 'Consumed',
                    value: consumed.kcalFormatted,
                    unit: 'kcal',
                    color: AppColors.negative,
                    icon: Icons.restaurant_rounded,
                  ).animate().fadeIn(delay: 200.ms),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: _Divider(isVertical: false),
            ),

            Row(
              children: [
                Expanded(
                  child: _MetricCell(
                    label: 'Remaining',
                    value: remaining.kcalFormatted,
                    unit: 'kcal',
                    color: isOver ? AppColors.negative : AppColors.positive,
                    icon: isOver
                        ? Icons.warning_rounded
                        : Icons.trending_up_rounded,
                  ).animate().fadeIn(delay: 300.ms),
                ),
                _Divider(isVertical: true),
                Expanded(
                  child: _MetricCell(
                    label: 'Bank Balance',
                    value: bankBalance.kcalFormatted,
                    unit: 'kcal',
                    color: AppColors.accent,
                    icon: Icons.account_balance_rounded,
                  ).animate().fadeIn(delay: 400.ms),
                ),
              ],
            ),

            if (summary != null && budget > 0) ...[
              const SizedBox(height: 20),
              _ProgressBar(progress: summary!.consumedPercent),
            ],
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class _MetricCell extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _MetricCell({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: AppTextStyles.bankBalance.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                )),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(unit,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  )),
            ),
          ],
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isVertical;
  const _Divider({required this.isVertical});

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Container(
        width: 1,
        height: 60,
        color: AppColors.cardBorder,
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );
    }
    return Container(height: 1, color: AppColors.cardBorder);
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final isOver = progress > 1.0;
    final barColor = isOver ? AppColors.negative : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Daily Progress',
                style:
                    AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            Text('${(progress * 100).clamp(0, 999).round()}%',
                style: AppTextStyles.labelSmall
                    .copyWith(color: isOver ? AppColors.negative : AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 6,
            backgroundColor: AppColors.cardBorder,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
