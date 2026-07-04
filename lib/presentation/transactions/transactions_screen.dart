import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/extensions/num_extensions.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/entities/calorie_transaction.dart';
import '../home/providers/home_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(todaysTransactionsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title: Text('Transaction Ledger', style: AppTextStyles.headlineSmall),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_balance_rounded,
                    color: AppColors.textSecondary),
                onPressed: () => context.go('/bank'),
              ),
            ],
          ),
          txAsync.when(
            data: (transactions) {
              if (transactions.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyLedger(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),
                    _DailySummaryBanner(transactions: transactions),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: transactions
                            .asMap()
                            .entries
                            .map((e) => _LedgerRow(
                                  tx: e.value,
                                  isLast: e.key == transactions.length - 1,
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailySummaryBanner extends StatelessWidget {
  final List<CalorieTransaction> transactions;
  const _DailySummaryBanner({required this.transactions});

  @override
  Widget build(BuildContext context) {
    int totalIn = 0;
    int totalOut = 0;
    for (final tx in transactions) {
      if (tx.type.isPositive) {
        totalIn += tx.calories;
      } else {
        totalOut += tx.calories;
      }
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.positive.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.positive.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded,
                        color: AppColors.positive, size: 14),
                    const SizedBox(width: 4),
                    Text('Earned',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.positive)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(totalIn.kcalFormatted,
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.positive)),
                Text('kcal', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.negative.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.negative.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_downward_rounded,
                        color: AppColors.negative, size: 14),
                    const SizedBox(width: 4),
                    Text('Spent',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.negative)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(totalOut.kcalFormatted,
                    style: AppTextStyles.headlineSmall
                        .copyWith(color: AppColors.negative)),
                Text('kcal', style: AppTextStyles.labelSmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final CalorieTransaction tx;
  final bool isLast;
  const _LedgerRow({required this.tx, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isPositive = tx.type.isPositive;
    final color = isPositive ? AppColors.positive : AppColors.negative;
    final sign = isPositive ? '+' : '-';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(tx.type.icon,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.label,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(tx.timestamp.timeLabel,
                        style: AppTextStyles.labelSmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${tx.calories.kcalFormatted}',
                    style: AppTextStyles.transactionAmount
                        .copyWith(color: color),
                  ),
                  Text('kcal', style: AppTextStyles.labelSmall),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 70,
            color: AppColors.cardBorder,
          ),
      ],
    );
  }
}

class _EmptyLedger extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.receipt_long_rounded,
            size: 48, color: AppColors.textMuted),
        const SizedBox(height: 16),
        Text('No transactions today',
            style: AppTextStyles.headlineSmall
                .copyWith(color: AppColors.textMuted)),
        const SizedBox(height: 8),
        Text('Log food or exercise to see transactions',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}
