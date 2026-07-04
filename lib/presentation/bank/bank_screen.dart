import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/extensions/num_extensions.dart';
import '../home/providers/home_provider.dart';
import '../shared/widgets/gradient_button.dart';

class BankScreen extends ConsumerStatefulWidget {
  const BankScreen({super.key});

  @override
  ConsumerState<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends ConsumerState<BankScreen> {
  @override
  Widget build(BuildContext context) {
    final bankAsync = ref.watch(bankAccountProvider);
    final txAsync = ref.watch(todaysTransactionsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            title:
                Text('Calorie Bank', style: AppTextStyles.headlineSmall),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),

                // Bank balance card
                bankAsync.when(
                  data: (bank) => _BankBalanceCard(
                    balance: bank.balance,
                    onWithdraw: () => context.push('/manual/bank-withdraw'),
                  ).animate().fadeIn(duration: 500.ms).scale(
                        begin: const Offset(0.97, 0.97),
                      ),
                  loading: () => const SizedBox(height: 200),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                Text('Recent Bank Activity',
                    style: AppTextStyles.titleLarge),
                const SizedBox(height: 12),

                txAsync.when(
                  data: (transactions) {
                    final bankTx = transactions.where((t) =>
                        t.type.name.contains('bank') ||
                        t.type.name.contains('savings')).toList();

                    if (bankTx.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.savings_rounded,
                                  size: 40, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text('No bank activity yet',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.textMuted)),
                              const SizedBox(height: 4),
                              Text(
                                  'Save calories today and they\'ll appear here',
                                  style: AppTextStyles.bodySmall
                                      .copyWith(
                                          color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        children: bankTx
                            .asMap()
                            .entries
                            .map((e) => _BankTxRow(
                                  txType: e.value.type.name,
                                  label: e.value.label,
                                  calories: e.value.calories,
                                  isLast: e.key == bankTx.length - 1,
                                ))
                            .toList(),
                      ),
                    );
                  },
                  loading: () => const CircularProgressIndicator(
                      color: AppColors.primary),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),

                _HowItWorksCard(),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankBalanceCard extends StatelessWidget {
  final int balance;
  final VoidCallback onWithdraw;

  const _BankBalanceCard({
    required this.balance,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1E3D), Color(0xFF091426)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Savings Account',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white60,
                        letterSpacing: 1,
                      )),
                  Text('Calorie Bank',
                      style: AppTextStyles.titleMedium
                          .copyWith(color: Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text('Available Balance',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white60,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance.kcalFormatted,
                style: AppTextStyles.displaySmall.copyWith(
                  color: Colors.white,
                  fontSize: 44,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 6),
                child: Text(
                  'kcal',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white60),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Withdraw Calories',
            onPressed: balance > 0 ? onWithdraw : null,
            gradientColors: [AppColors.accent, const Color(0xFF5A45CC)],
            icon: Icons.account_balance_rounded,
          ),
        ],
      ),
    );
  }
}

class _BankTxRow extends StatelessWidget {
  final String txType;
  final String label;
  final int calories;
  final bool isLast;

  const _BankTxRow({
    required this.txType,
    required this.label,
    required this.calories,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isDeposit = txType.contains('savings') || txType.contains('Deposit');
    final color = isDeposit ? AppColors.positive : AppColors.negative;
    final sign = isDeposit ? '+' : '-';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                isDeposit
                    ? Icons.arrow_circle_down_rounded
                    : Icons.arrow_circle_up_rounded,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              Text(
                '$sign${calories.kcalFormatted} kcal',
                style: AppTextStyles.transactionAmount.copyWith(color: color),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.cardBorder),
      ],
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How the Bank works', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          _Step('1', 'Stay under budget → unused calories are auto-saved',
              AppColors.positive),
          _Step('2', 'Savings accumulate in your bank balance', AppColors.accent),
          _Step('3', 'Withdraw when you want a cheat meal or special occasion',
              AppColors.warning),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String text;
  final Color color;

  const _Step(this.number, this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(number,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
