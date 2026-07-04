import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../shared/widgets/gradient_button.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Upgrade to Premium', style: AppTextStyles.headlineSmall),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1035), Color(0xFF0F0A2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.star_rounded,
                      color: Colors.white, size: 32),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text('Premium', style: AppTextStyles.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'Unlimited AI logging, no ads, full access',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),

          const SizedBox(height: 28),

          ..._features.asMap().entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(e.value['icon'] as IconData,
                        color: AppColors.accent, size: 18),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.value['title'] as String,
                            style: AppTextStyles.titleMedium),
                        Text(e.value['desc'] as String,
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(
                    delay: Duration(milliseconds: 200 + e.key * 80),
                  ),
            );
          }),

          const SizedBox(height: 32),

          GradientButton(
            label: 'Subscribe — \$4.99 / month',
            onPressed: () {
              // TODO: Trigger Google Play Billing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Play Billing integration coming soon')),
              );
            },
            gradientColors: [AppColors.accent, const Color(0xFF5A45CC)],
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 12),
          Center(
            child: Text(
              'Cancel anytime. Billed monthly via Google Play.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  static const _features = [
    {
      'icon': Icons.auto_awesome_rounded,
      'title': 'Unlimited AI Messages',
      'desc': 'Log as much as you want, every day',
    },
    {
      'icon': Icons.block_rounded,
      'title': 'No Advertisements',
      'desc': 'Clean, distraction-free experience',
    },
    {
      'icon': Icons.analytics_rounded,
      'title': 'Advanced Analytics',
      'desc': 'Weekly and monthly calorie trends',
    },
    {
      'icon': Icons.cloud_sync_rounded,
      'title': 'Cloud Backup',
      'desc': 'Your data synced across devices',
    },
    {
      'icon': Icons.priority_high_rounded,
      'title': 'Priority Support',
      'desc': 'Get help when you need it',
    },
  ];
}
