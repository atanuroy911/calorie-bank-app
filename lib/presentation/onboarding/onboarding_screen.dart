import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../shared/widgets/gradient_button.dart';
import 'providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final notifier = ref.read(onboardingProvider.notifier);
    final state = ref.read(onboardingProvider);

    if (state.currentPage == 0 && state.name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: AppColors.negative,
        ),
      );
      return;
    }

    if (state.currentPage < 3) {
      notifier.nextPage();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _prevPage() {
    final notifier = ref.read(onboardingProvider.notifier);
    final state = ref.read(onboardingProvider);
    if (state.currentPage > 0) {
      notifier.prevPage();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submit() async {
    final success = await ref.read(onboardingProvider.notifier).submit();
    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);

    return PopScope(
      canPop: state.currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _prevPage();
      },
      child: Scaffold(
        body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E1A), Color(0xFF0D1526)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(state),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _PersonalInfoPage(notifier: ref.read(onboardingProvider.notifier)),
                    _BodyMetricsPage(notifier: ref.read(onboardingProvider.notifier)),
                    _GoalPage(notifier: ref.read(onboardingProvider.notifier)),
                    _SummaryPage(state: state),
                  ],
                ),
              ),
              _buildFooter(state),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildHeader(OnboardingState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (state.currentPage > 0)
                GestureDetector(
                  onTap: _prevPage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 18, color: AppColors.textPrimary),
                  ),
                )
              else
                const SizedBox(width: 36),
              const Spacer(),
              Text(
                '${state.currentPage + 1} / 4',
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (state.currentPage + 1) / 4,
              minHeight: 4,
              backgroundColor: AppColors.cardBorder,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(OnboardingState state) {
    final isLast = state.currentPage == 3;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: GradientButton(
        label: isLast ? 'Get Started 🚀' : 'Continue',
        onPressed: state.isSubmitting ? null : _nextPage,
        isLoading: state.isSubmitting,
      ),
    );
  }
}

// --- Page 1: Personal Info ---
class _PersonalInfoPage extends StatefulWidget {
  final OnboardingNotifier notifier;
  const _PersonalInfoPage({required this.notifier});

  @override
  State<_PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<_PersonalInfoPage> {
  final _nameController = TextEditingController();
  int _age = 25;
  String _gender = 'male';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Tell us about\nyourself', style: AppTextStyles.displaySmall)
              .animate()
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          Text('This helps us calculate your daily calorie budget',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary))
              .animate()
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            onChanged: widget.notifier.updateName,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          Text('Age', style: AppTextStyles.inputLabel),
          const SizedBox(height: 12),
          _AgeSelector(
            value: _age,
            onChanged: (v) {
              setState(() => _age = v);
              widget.notifier.updateAge(v);
            },
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          Text('Gender', style: AppTextStyles.inputLabel),
          const SizedBox(height: 12),
          _GenderSelector(
            value: _gender,
            onChanged: (v) {
              setState(() => _gender = v);
              widget.notifier.updateGender(v);
            },
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _AgeSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _AgeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleButton(
          icon: Icons.remove,
          onTap: () => onChanged((value - 1).clamp(10, 100)),
        ),
        Expanded(
          child: Center(
            child: Text(
              '$value',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        _CircleButton(
          icon: Icons.add,
          onTap: () => onChanged((value + 1).clamp(10, 100)),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

class _GenderSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _GenderSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final gender in ['male', 'female', 'other'])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(gender),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 48,
                  decoration: BoxDecoration(
                    color: value == gender
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: value == gender
                          ? AppColors.primary
                          : AppColors.cardBorder,
                      width: value == gender ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      gender[0].toUpperCase() + gender.substring(1),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: value == gender
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BodyMetricsPage extends ConsumerStatefulWidget {
  final OnboardingNotifier notifier;
  const _BodyMetricsPage({required this.notifier});

  @override
  ConsumerState<_BodyMetricsPage> createState() => _BodyMetricsPageState();
}

class _BodyMetricsPageState extends ConsumerState<_BodyMetricsPage> {
  // Always store underlying values in metric to match provider
  double _heightCm = 170;
  double _currentWeightKg = 70;
  double _goalWeightKg = 65;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final isMetric = state.unitSystem == 'metric';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your measurements', style: AppTextStyles.displaySmall),
                    const SizedBox(height: 8),
                    Text('We\'ll use these to calculate your TDEE',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              _UnitToggle(
                isMetric: isMetric,
                onChanged: (metric) {
                  widget.notifier.updateUnitSystem(metric ? 'metric' : 'imperial');
                },
              ),
            ],
          ).animate().fadeIn(),
          const SizedBox(height: 32),
          _MetricSlider(
            label: 'Height',
            value: isMetric ? _heightCm : (_heightCm / 2.54), // inches
            min: isMetric ? 140 : (140 / 2.54),
            max: isMetric ? 220 : (220 / 2.54),
            formatValue: isMetric
                ? (v) => '${v.toStringAsFixed(1)} cm'
                : (v) {
                    final totalInches = v.round();
                    final feet = totalInches ~/ 12;
                    final inches = totalInches % 12;
                    return '$feet\'$inches"';
                  },
            onChanged: (v) {
              final newCm = isMetric ? v : (v * 2.54);
              setState(() => _heightCm = newCm);
              widget.notifier.updateHeight(newCm);
            },
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 28),
          _MetricSlider(
            label: 'Current Weight',
            value: isMetric ? _currentWeightKg : (_currentWeightKg * 2.20462),
            min: isMetric ? 40 : (40 * 2.20462),
            max: isMetric ? 200 : (200 * 2.20462),
            formatValue: isMetric
                ? (v) => '${v.toStringAsFixed(1)} kg'
                : (v) => '${v.toStringAsFixed(1)} lbs',
            onChanged: (v) {
              final newKg = isMetric ? v : (v / 2.20462);
              setState(() => _currentWeightKg = newKg);
              widget.notifier.updateCurrentWeight(newKg);
            },
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 28),
          _MetricSlider(
            label: 'Goal Weight',
            value: isMetric ? _goalWeightKg : (_goalWeightKg * 2.20462),
            min: isMetric ? 40 : (40 * 2.20462),
            max: isMetric ? 200 : (200 * 2.20462),
            formatValue: isMetric
                ? (v) => '${v.toStringAsFixed(1)} kg'
                : (v) => '${v.toStringAsFixed(1)} lbs',
            onChanged: (v) {
              final newKg = isMetric ? v : (v / 2.20462);
              setState(() => _goalWeightKg = newKg);
              widget.notifier.updateGoalWeight(newKg);
            },
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final bool isMetric;
  final ValueChanged<bool> onChanged;
  
  const _UnitToggle({required this.isMetric, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            label: 'Metric',
            isSelected: isMetric,
            onTap: () => onChanged(true),
          ),
          _ToggleBtn(
            label: 'US',
            isSelected: !isMetric,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleBtn({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MetricSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String Function(double) formatValue;
  final ValueChanged<double> onChanged;

  const _MetricSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.formatValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // split formatted value into number and unit if possible, for styling
    final formatted = formatValue(value);
    final parts = formatted.split(' ');
    final numPart = parts.first;
    final unitPart = parts.length > 1 ? ' ${parts.sublist(1).join(' ')}' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.titleMedium),
            const Spacer(),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: numPart,
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.primary),
                ),
                TextSpan(
                  text: unitPart,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.cardBorder,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.15),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// --- Page 3: Goal ---
class _GoalPage extends StatefulWidget {
  final OnboardingNotifier notifier;
  const _GoalPage({required this.notifier});

  @override
  State<_GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<_GoalPage> {
  String _goal = 'weight_loss';
  String _activityLevel = 'moderate';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Your goal', style: AppTextStyles.displaySmall)
              .animate()
              .fadeIn(),
          const SizedBox(height: 8),
          Text('What are you working towards?',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary))
              .animate()
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 32),
          ..._GoalOption.goals.asMap().entries.map((e) {
            final delay = Duration(milliseconds: 200 + e.key * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectableCard(
                isSelected: _goal == e.value.value,
                onTap: () {
                  setState(() => _goal = e.value.value);
                  widget.notifier.updateGoal(e.value.value);
                },
                child: Row(
                  children: [
                    Text(e.value.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.value.label,
                              style: AppTextStyles.titleMedium),
                          Text(e.value.description,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: delay).slideX(begin: 0.1),
            );
          }),
          const SizedBox(height: 24),
          Text('Activity Level', style: AppTextStyles.titleMedium)
              .animate()
              .fadeIn(delay: 600.ms),
          const SizedBox(height: 12),
          ..._ActivityOption.levels.asMap().entries.map((e) {
            final delay = Duration(milliseconds: 700 + e.key * 80);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SelectableCard(
                isSelected: _activityLevel == e.value.value,
                onTap: () {
                  setState(() => _activityLevel = e.value.value);
                  widget.notifier.updateActivityLevel(e.value.value);
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Text(e.value.label,
                          style: AppTextStyles.titleMedium),
                    ),
                    Text(e.value.description,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary)),
                  ],
                ),
              ).animate().fadeIn(delay: delay),
            );
          }),
        ],
      ),
    );
  }
}

class _GoalOption {
  final String value;
  final String label;
  final String description;
  final String emoji;

  const _GoalOption(this.value, this.label, this.description, this.emoji);

  static const goals = [
    _GoalOption('weight_loss', 'Lose Weight', 'Calorie deficit • -500 kcal/day', '🔥'),
    _GoalOption('maintenance', 'Maintain Weight', 'Balanced intake • No adjustment', '⚖️'),
    _GoalOption('weight_gain', 'Gain Weight', 'Calorie surplus • +300 kcal/day', '💪'),
  ];
}

class _ActivityOption {
  final String value;
  final String label;
  final String description;

  const _ActivityOption(this.value, this.label, this.description);

  static const levels = [
    _ActivityOption('sedentary', 'Sedentary', 'Desk job, no exercise'),
    _ActivityOption('light', 'Light', '1-3 days/week'),
    _ActivityOption('moderate', 'Moderate', '3-5 days/week'),
    _ActivityOption('active', 'Active', '6-7 days/week'),
    _ActivityOption('very_active', 'Very Active', 'Physical job + exercise'),
  ];
}

class _SelectableCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _SelectableCard({
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

// --- Page 4: Summary ---
class _SummaryPage extends StatelessWidget {
  final OnboardingState state;
  const _SummaryPage({required this.state});

  @override
  Widget build(BuildContext context) {
    final goals = state.calculatedGoals;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Your calorie\nbudget', style: AppTextStyles.displaySmall)
              .animate()
              .fadeIn(),
          const SizedBox(height: 8),
          Text('Here\'s your personalised daily target',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary))
              .animate()
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D4AA), Color(0xFF00A882)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text('Daily Calorie Budget',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.textOnPrimary.withValues(alpha: 0.8))),
                const SizedBox(height: 8),
                Text('${goals.dailyCalories}',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: AppColors.textOnPrimary,
                      fontSize: 56,
                    )),
                Text('calories / day',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textOnPrimary.withValues(alpha: 0.8))),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
          const SizedBox(height: 24),
          Row(
            children: [
              _MacroCard('Protein', '${goals.proteinG.toStringAsFixed(0)}g',
                  AppColors.protein),
              const SizedBox(width: 12),
              _MacroCard('Carbs', '${goals.carbsG.toStringAsFixed(0)}g',
                  AppColors.carbs),
              const SizedBox(width: 12),
              _MacroCard(
                  'Fat', '${goals.fatG.toStringAsFixed(0)}g', AppColors.fat),
            ],
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _InfoRow('Goal', state.goal.replaceAll('_', ' ')),
                _InfoRow('Activity', state.activityLevel.replaceAll('_', ' ')),
                _InfoRow('Current', '${state.currentWeightKg} kg'),
                _InfoRow('Target', '${state.goalWeightKg} kg'),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.headlineSmall.copyWith(color: color)),
            Text(label,
                style: AppTextStyles.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            value[0].toUpperCase() + value.substring(1),
            style: AppTextStyles.titleMedium,
          ),
        ],
      ),
    );
  }
}
