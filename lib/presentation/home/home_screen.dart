import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/extensions/num_extensions.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/entities/calorie_transaction.dart';
import '../../domain/entities/food_entry.dart';
import '../shared/widgets/section_header.dart';
import 'providers/home_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/macro_progress_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger end-of-day check
    ref.watch(endOfDayCheckerProvider);

    final summaryAsync = ref.watch(todaysSummaryProvider);
    final bankAsync = ref.watch(bankAccountProvider);
    final foodAsync = ref.watch(todaysFoodEntriesProvider);
    final txAsync = ref.watch(todaysTransactionsProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, profileAsync),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),

                // Balance overview card
                summaryAsync.when(
                  data: (summary) => bankAsync.when(
                    data: (bank) => BalanceCard(
                      summary: summary,
                      bankBalance: bank.balance,
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                    loading: () => const _LoadingCard(height: 180),
                    error: (_, __) => const _ErrorCard(),
                  ),
                  loading: () => const _LoadingCard(height: 180),
                  error: (_, __) => const _ErrorCard(),
                ),

                const SizedBox(height: 20),

                // Macro progress
                profileAsync.when(
                  data: (profile) => summaryAsync.when(
                    data: (summary) {
                      if (profile == null || summary == null) {
                        return const SizedBox.shrink();
                      }
                      return MacroProgressCard(
                        profile: profile,
                        summary: summary,
                      ).animate().fadeIn(delay: 100.ms, duration: 500.ms);
                    },
                    loading: () => const _LoadingCard(height: 120),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  loading: () => const _LoadingCard(height: 120),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // AI Chat quick access
                _AiChatBanner(onTap: () => context.go('/chat'))
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms),

                const SizedBox(height: 24),

                // Today's meals
                foodAsync.when(
                  data: (foods) {
                    if (foods.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: "Today's Meals",
                          actionLabel: 'Add',
                          onAction: () => context.go('/chat'),
                        ),
                        const SizedBox(height: 12),
                        ...foods.map((entry) => _FoodEntryTile(entry: entry)),
                      ],
                    ).animate().fadeIn(delay: 300.ms);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                // Recent transactions
                txAsync.when(
                  data: (transactions) {
                    if (transactions.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Transactions',
                          actionLabel: 'All',
                          onAction: () => context.go('/transactions'),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            children: transactions
                                .take(5)
                                .toList()
                                .asMap()
                                .entries
                                .map((e) => _TransactionTile(
                                      tx: e.value,
                                      isLast:
                                          e.key == transactions.length - 1 ||
                                              e.key == 4,
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 400.ms);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _ManualEntryFAB(
        onFoodTap: () => context.push('/manual/food'),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, WidgetRef ref,
      AsyncValue profileAsync) {
    final greeting = _getGreeting();

    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.textSecondary)),
                      profileAsync.when(
                        data: (profile) => Text(
                          profile?.displayName ?? 'Calorie Banker',
                          style: AppTextStyles.headlineMedium,
                        ),
                        loading: () =>
                            Text('Loading…', style: AppTextStyles.headlineMedium),
                        error: (_, __) => Text('Hello',
                            style: AppTextStyles.headlineMedium),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }
}

// ── Balance Card is in its own file ─────────────────────────────────────────

// ── AI Chat Banner ────────────────────────────────────────────────────────────
class _AiChatBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AiChatBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1035), Color(0xFF0F0A2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Log with CalBot',
                      style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary)),
                  Text('Just tell me what you ate',
                      style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.accent, size: 24),
          ],
        ),
      ),
    );
  }
}

// ── Food Entry Tile ──────────────────────────────────────────────────────────
class _FoodEntryTile extends StatelessWidget {
  final FoodEntry entry;
  const _FoodEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(_mealEmoji(entry.mealType),
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.mealTypeLabel, style: AppTextStyles.titleMedium),
                Text(
                  entry.foods.map((f) => f.name).join(', '),
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${entry.totalCalories.kcalFormatted}',
                style: AppTextStyles.transactionAmount
                    .copyWith(color: AppColors.negative),
              ),
              Text('kcal', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  String _mealEmoji(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '☀️';
      case 'dinner':
        return '🌙';
      default:
        return '🍎';
    }
  }
}

// ── Transaction Tile ─────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final CalorieTransaction tx;
  final bool isLast;
  const _TransactionTile({required this.tx, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.type.isPositive;
    final color = isPositive ? AppColors.positive : AppColors.negative;
    final sign = isPositive ? '+' : '-';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(tx.type.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.label, style: AppTextStyles.titleMedium),
                    Text(tx.timestamp.timeLabel,
                        style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              Text(
                '$sign${tx.calories.kcalFormatted} kcal',
                style: AppTextStyles.transactionAmount.copyWith(color: color),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

// ── Loading / Error placeholders ──────────────────────────────────────────────
class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.negative.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.negative.withValues(alpha: 0.3)),
      ),
      child: const Center(
        child: Text('Failed to load data',
            style: TextStyle(color: AppColors.negative)),
      ),
    );
  }
}

class _ManualEntryFAB extends StatelessWidget {
  final VoidCallback onFoodTap;
  const _ManualEntryFAB({required this.onFoodTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onFoodTap,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.primary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      icon: const Icon(Icons.add_rounded),
      label: Text('Manual Log', style: AppTextStyles.titleMedium.copyWith(
        color: AppColors.primary,
      )),
    );
  }
}
