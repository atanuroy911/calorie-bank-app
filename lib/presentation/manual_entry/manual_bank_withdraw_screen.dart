import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/providers.dart';
import '../../core/extensions/num_extensions.dart';
import '../home/providers/home_provider.dart';
import '../shared/widgets/gradient_button.dart';

class ManualBankWithdrawScreen extends ConsumerStatefulWidget {
  const ManualBankWithdrawScreen({super.key});

  @override
  ConsumerState<ManualBankWithdrawScreen> createState() =>
      _ManualBankWithdrawScreenState();
}

class _ManualBankWithdrawScreenState
    extends ConsumerState<ManualBankWithdrawScreen> {
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController(text: 'Cheat meal');
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final bank = await ref
        .read(bankRepositoryProvider)
        .getBankAccount(ref.read(preferencesServiceProvider).userId ?? '');

    if (amount > bank.balance) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Insufficient bank balance')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userId = ref.read(preferencesServiceProvider).userId ?? '';
      await ref.read(bankRepositoryProvider).withdraw(
            userId,
            amount,
            _reasonController.text.trim(),
          );

      // Update daily summary
      final summaryRepo = ref.read(dailySummaryRepositoryProvider);
      final summary =
          await summaryRepo.getSummaryForDate(userId, DateTime.now());
      if (summary != null) {
        await summaryRepo
            .updateSummary(summary.copyWith(bankBonus: summary.bankBonus + amount));
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bankAsync = ref.watch(bankAccountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bank Withdrawal', style: AppTextStyles.headlineSmall),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: bankAsync.when(
        data: (bank) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('Available Balance',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: Colors.white60)),
                  const SizedBox(height: 8),
                  Text('${bank.balance.kcalFormatted} kcal',
                      style: AppTextStyles.displaySmall
                          .copyWith(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Withdraw Amount (kcal)',
                hintText: 'e.g. 500',
                prefixIcon: Icon(Icons.account_balance_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasonController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Reason',
                hintText: 'e.g. Cheat meal, Birthday party',
              ),
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Withdraw from Bank',
              onPressed: _isLoading ? null : _withdraw,
              isLoading: _isLoading,
              icon: Icons.account_balance_rounded,
              gradientColors: [AppColors.accent, const Color(0xFF5A45CC)],
            ),
          ],
        ),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (_, __) =>
            const Center(child: Text('Error loading bank balance')),
      ),
    );
  }
}
