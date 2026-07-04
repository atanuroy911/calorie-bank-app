import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../domain/entities/nutrition.dart';
import '../home/providers/home_provider.dart';

class NutritionDetailScreen extends ConsumerWidget {
  const NutritionDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todaysSummaryProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: Text('Nutrition Today', style: AppTextStyles.headlineSmall),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                summaryAsync.when(
                  data: (summary) {
                    if (summary == null) {
                      return _EmptyState();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calorie summary pill
                        _CalorieSummaryPill(summary: summary),
                        const SizedBox(height: 24),

                        // Macros section
                        _SectionTitle(icon: '🥩', label: 'Macronutrients'),
                        const SizedBox(height: 12),
                        _MacroGrid(
                          macros: summary.macros,
                          profile: profileAsync.value,
                        ),

                        const SizedBox(height: 28),

                        // Micros — Minerals
                        _SectionTitle(icon: '⚗️', label: 'Minerals'),
                        const SizedBox(height: 12),
                        _MicroList(
                          items: _mineralItems(summary.micros),
                        ),

                        const SizedBox(height: 28),

                        // Micros — Vitamins
                        _SectionTitle(icon: '💊', label: 'Vitamins'),
                        const SizedBox(height: 12),
                        _MicroList(
                          items: _vitaminItems(summary.micros),
                        ),

                        const SizedBox(height: 80),
                      ],
                    ).animate().fadeIn(duration: 400.ms);
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 80),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  ),
                  error: (_, __) => _EmptyState(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<_MicroItem> _mineralItems(Micros m) => [
        _MicroItem('Sodium',      '${m.sodiumMg.toStringAsFixed(0)} mg',     m.sodiumMg,     DailyReferenceValues.sodiumMg,     _microColor(m.sodiumMg, DailyReferenceValues.sodiumMg)),
        _MicroItem('Potassium',   '${m.potassiumMg.toStringAsFixed(0)} mg',  m.potassiumMg,  DailyReferenceValues.potassiumMg,  AppColors.positive),
        _MicroItem('Calcium',     '${m.calciumMg.toStringAsFixed(0)} mg',    m.calciumMg,    DailyReferenceValues.calciumMg,    AppColors.positive),
        _MicroItem('Iron',        '${m.ironMg.toStringAsFixed(1)} mg',       m.ironMg,       DailyReferenceValues.ironMg,       AppColors.positive),
        _MicroItem('Magnesium',   '${m.magnesiumMg.toStringAsFixed(0)} mg',  m.magnesiumMg,  DailyReferenceValues.magnesiumMg,  AppColors.positive),
        _MicroItem('Zinc',        '${m.zincMg.toStringAsFixed(1)} mg',       m.zincMg,       DailyReferenceValues.zincMg,       AppColors.positive),
        _MicroItem('Phosphorus',  '${m.phosphorusMg.toStringAsFixed(0)} mg', m.phosphorusMg, DailyReferenceValues.phosphorusMg, AppColors.positive),
      ];

  List<_MicroItem> _vitaminItems(Micros m) => [
        _MicroItem('Vitamin C',   '${m.vitaminCMg.toStringAsFixed(1)} mg',   m.vitaminCMg,   DailyReferenceValues.vitaminCMg,   AppColors.positive),
        _MicroItem('Vitamin D',   '${m.vitaminDUg.toStringAsFixed(1)} μg',   m.vitaminDUg,   DailyReferenceValues.vitaminDUg,   AppColors.positive),
        _MicroItem('Vitamin B12', '${m.vitaminB12Ug.toStringAsFixed(1)} μg', m.vitaminB12Ug, DailyReferenceValues.vitaminB12Ug, AppColors.positive),
        _MicroItem('Folate',      '${m.folateMcg.toStringAsFixed(0)} μg',    m.folateMcg,    DailyReferenceValues.folateMcg,    AppColors.positive),
        _MicroItem('Vitamin A',   '${m.vitaminAUg.toStringAsFixed(0)} μg',   m.vitaminAUg,   DailyReferenceValues.vitaminAUg,   AppColors.positive),
        _MicroItem('Vitamin E',   '${m.vitaminEMg.toStringAsFixed(1)} mg',   m.vitaminEMg,   DailyReferenceValues.vitaminEMg,   AppColors.positive),
        _MicroItem('Vitamin K',   '${m.vitaminKUg.toStringAsFixed(0)} μg',   m.vitaminKUg,   DailyReferenceValues.vitaminKUg,   AppColors.positive),
      ];

  // Sodium is "lower is better" — flip color logic
  Color _microColor(double value, double rdv) =>
      value > rdv * 1.1 ? AppColors.negative : AppColors.positive;
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CalorieSummaryPill extends StatelessWidget {
  final dynamic summary;
  const _CalorieSummaryPill({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Pill('Consumed', '${summary.consumed} kcal', Colors.white),
          _Pill('Remaining', '${summary.remaining} kcal', Colors.white70),
          _Pill('Budget', '${summary.totalAvailable} kcal', Colors.white70),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Pill(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.titleMedium.copyWith(color: color)),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: color.withValues(alpha: 0.8))),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String icon;
  final String label;
  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.titleLarge
                .copyWith(color: AppColors.textPrimary)),
      ],
    );
  }
}

class _MacroGrid extends StatelessWidget {
  final Macros macros;
  final dynamic profile; // UserProfile?
  const _MacroGrid({required this.macros, required this.profile});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MacroItem('Protein',       '${macros.proteinG.toStringAsFixed(1)}g',      macros.proteinG,       profile?.dailyProteinGoalG ?? 0,  AppColors.protein),
      _MacroItem('Carbs',         '${macros.carbsG.toStringAsFixed(1)}g',         macros.carbsG,         profile?.dailyCarbsGoalG ?? 0,    AppColors.carbs),
      _MacroItem('Fat',           '${macros.fatG.toStringAsFixed(1)}g',           macros.fatG,           profile?.dailyFatGoalG ?? 0,      AppColors.fat),
      _MacroItem('Fiber',         '${macros.fiberG.toStringAsFixed(1)}g',         macros.fiberG,         DailyReferenceValues.fiberG,      const Color(0xFF66BB6A)),
      _MacroItem('Sugar',         '${macros.sugarG.toStringAsFixed(1)}g',         macros.sugarG,         DailyReferenceValues.sugarG,      const Color(0xFFFFB300)),
      _MacroItem('Sat. Fat',      '${macros.saturatedFatG.toStringAsFixed(1)}g',  macros.saturatedFatG,  DailyReferenceValues.saturatedFatG, const Color(0xFFEF5350)),
      _MacroItem('Trans Fat',     '${macros.transFatG.toStringAsFixed(2)}g',      macros.transFatG,      0,                                const Color(0xFFF44336)),
      _MacroItem('Cholesterol',   '${macros.cholesterolMg.toStringAsFixed(0)}mg', macros.cholesterolMg,  DailyReferenceValues.cholesterolMg, const Color(0xFFAB47BC)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _MacroTile(item: items[i]),
    );
  }
}

class _MacroItem {
  final String label;
  final String value;
  final double current;
  final double goal;
  final Color color;
  const _MacroItem(this.label, this.value, this.current, this.goal, this.color);
}

class _MacroTile extends StatelessWidget {
  final _MacroItem item;
  const _MacroTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final progress = item.goal > 0
        ? (item.current / item.goal).clamp(0.0, 1.0)
        : 0.0;
    final isOver = item.goal > 0 && item.current > item.goal * 1.05;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOver
              ? AppColors.negative.withValues(alpha: 0.5)
              : item.color.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.label,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textSecondary)),
              if (isOver)
                const Icon(Icons.warning_amber_rounded,
                    size: 12, color: AppColors.negative),
            ],
          ),
          Text(item.value,
              style: AppTextStyles.titleMedium.copyWith(color: item.color)),
          if (item.goal > 0) ...[
            const SizedBox(height: 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                color: isOver ? AppColors.negative : item.color,
                backgroundColor: AppColors.cardBorder,
                minHeight: 3,
              ),
            ),
            Text(
              '/ ${item.goal.toStringAsFixed(0)}${item.label.contains('mg') ? 'mg' : 'g'}',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textMuted, fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }
}

class _MicroItem {
  final String label;
  final String value;
  final double current;
  final double rdv;
  final Color color;
  const _MicroItem(this.label, this.value, this.current, this.rdv, this.color);
}

class _MicroList extends StatelessWidget {
  final List<_MicroItem> items;
  const _MicroList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return _MicroRow(item: e.value, isLast: isLast);
        }).toList(),
      ),
    );
  }
}

class _MicroRow extends StatelessWidget {
  final _MicroItem item;
  final bool isLast;
  const _MicroRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final progress =
        item.rdv > 0 ? (item.current / item.rdv).clamp(0.0, 1.2) : 0.0;
    final percent = item.rdv > 0
        ? '${(progress * 100).toStringAsFixed(0)}% DV'
        : '';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(item.label, style: AppTextStyles.titleMedium),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress > 1.0 ? 1.0 : progress,
                    color: progress > 1.1
                        ? AppColors.negative
                        : item.color,
                    backgroundColor: AppColors.cardBorder,
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 68,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item.value,
                        style: AppTextStyles.titleMedium
                            .copyWith(color: item.color),
                        textAlign: TextAlign.right),
                    if (percent.isNotEmpty)
                      Text(percent,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textMuted),
                          textAlign: TextAlign.right),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.cardBorder),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          const Text('🥗', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('No food logged today',
              style: AppTextStyles.titleLarge),
          const SizedBox(height: 8),
          Text('Log a meal to see your nutrition breakdown',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
