import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/extensions/num_extensions.dart';
import '../home/providers/home_provider.dart';
import '../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final bankAsync = ref.watch(bankAccountProvider);
    final summaryAsync = ref.watch(todaysSummaryProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: Text('Profile', style: AppTextStyles.headlineSmall),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Avatar + name
                profileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: Colors.white, size: 40),
                          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(profile.displayName,
                              style: AppTextStyles.headlineMedium),
                        ),
                        Center(
                          child: Text(profile.email,
                              style: AppTextStyles.bodySmall),
                        ),
                        if (profile.isPremium) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Premium',
                                style: AppTextStyles.labelMedium
                                    .copyWith(color: Colors.white)),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Stats row
                        Row(
                          children: [
                            summaryAsync.when(
                              data: (s) => _StatCard('Today',
                                  '${(s?.consumed ?? 0).kcalFormatted} kcal',
                                  AppColors.primary),
                              loading: () => const _StatCard('Today', '—', AppColors.primary),
                              error: (_, __) => const _StatCard('Today', '—', AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            bankAsync.when(
                              data: (b) => _StatCard('Bank',
                                  '${b.balance.kcalFormatted} kcal',
                                  AppColors.accent),
                              loading: () => const _StatCard('Bank', '—', AppColors.accent),
                              error: (_, __) => const _StatCard('Bank', '—', AppColors.accent),
                            ),
                            const SizedBox(width: 12),
                            _StatCard('Budget',
                                '${profile.dailyCalorieBudget.kcalFormatted} kcal',
                                AppColors.positive),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.primary)),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 28),

                // Menu items
                _MenuSection(title: 'Account', items: [
                  _MenuItem(
                    icon: Icons.edit_rounded,
                    label: 'Edit Profile',
                    onTap: () => context.push('/profile/edit'),
                  ),
                  _MenuItem(
                    icon: Icons.star_rounded,
                    label: 'Upgrade to Premium',
                    color: AppColors.accent,
                    onTap: () => context.push('/profile/premium'),
                  ),
                ]),

                const SizedBox(height: 16),

                _MenuSection(title: 'App', items: [
                  _MenuItem(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Provider Settings',
                    onTap: () => context.push('/profile/ai-settings'),
                  ),
                  _MenuItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    onTap: () => context.push('/profile/settings'),
                  ),
                ]),

                const SizedBox(height: 16),

                _MenuSection(title: 'Account', items: [
                  _MenuItem(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    color: AppColors.negative,
                    onTap: () async {
                      await ref.read(authActionsProvider).signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                ]),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style:
                    AppTextStyles.titleMedium.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label, style: AppTextStyles.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
              style: AppTextStyles.labelSmall
                  .copyWith(letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((e) => Column(children: [
                      e.value,
                      if (e.key < items.length - 1)
                        const Divider(
                            height: 1, color: AppColors.cardBorder),
                    ]))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 20),
      title: Text(label, style: AppTextStyles.titleMedium.copyWith(color: c)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}
