import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/calorie_transaction.dart';
import '../shared/widgets/gradient_button.dart';

class ManualExerciseScreen extends ConsumerStatefulWidget {
  const ManualExerciseScreen({super.key});

  @override
  ConsumerState<ManualExerciseScreen> createState() =>
      _ManualExerciseScreenState();
}

class _ManualExerciseScreenState extends ConsumerState<ManualExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _caloriesController = TextEditingController(text: '200');
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(preferencesServiceProvider).userId ?? 'unknown';
      final calories = int.tryParse(_caloriesController.text) ?? 0;
      final duration = int.tryParse(_durationController.text) ?? 0;

      final tx = CalorieTransaction(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        type: TransactionType.exerciseDeposit,
        calories: calories,
        label: '${_nameController.text.trim()} • $duration min',
        userId: userId,
        date: _dateKey(DateTime.now()),
      );
      await ref.read(transactionRepositoryProvider).addTransaction(tx);

      // Update daily summary
      final summaryRepo = ref.read(dailySummaryRepositoryProvider);
      final today = DateTime.now();
      final summary = await summaryRepo.getSummaryForDate(userId, today);
      if (summary != null) {
        await summaryRepo.updateSummary(
          summary.copyWith(
              exerciseBonus: summary.exerciseBonus + calories),
        );
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Exercise', style: AppTextStyles.headlineSmall),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                labelText: 'Exercise',
                hintText: 'e.g. Running, Walking, Gym',
                prefixIcon: Icon(Icons.fitness_center_rounded, size: 20),
              ),
              validator: (v) =>
                  v?.isEmpty == true ? 'Exercise name is required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(
                        labelText: 'Duration (min)', hintText: '30'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyMedium,
                    decoration: const InputDecoration(
                        labelText: 'Calories Burned', hintText: '200'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Log Exercise',
              onPressed: _isLoading ? null : _save,
              isLoading: _isLoading,
              icon: Icons.fitness_center_rounded,
              gradientColors: [AppColors.positive, const Color(0xFF00A862)],
            ),
          ],
        ),
      ),
    );
  }
}
