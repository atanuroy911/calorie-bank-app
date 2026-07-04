import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/di/providers.dart';
import '../../domain/entities/food_entry.dart';
import '../../domain/entities/nutrition.dart';
import '../../domain/entities/calorie_transaction.dart';
import '../../domain/entities/daily_summary.dart';
import '../shared/widgets/gradient_button.dart';

class ManualFoodScreen extends ConsumerStatefulWidget {
  const ManualFoodScreen({super.key});

  @override
  ConsumerState<ManualFoodScreen> createState() => _ManualFoodScreenState();
}

class _ManualFoodScreenState extends ConsumerState<ManualFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1 serving');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');
  String _mealType = 'lunch';
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(preferencesServiceProvider).userId ?? 'unknown';
      final calories = int.tryParse(_caloriesController.text) ?? 0;
      final protein = double.tryParse(_proteinController.text) ?? 0;
      final carbs = double.tryParse(_carbsController.text) ?? 0;
      final fat = double.tryParse(_fatController.text) ?? 0;

      final food = FoodItem(
        name: _nameController.text.trim(),
        quantity: _quantityController.text.trim(),
        calories: calories,
        macros: Macros(
          proteinG: protein,
          carbsG: carbs,
          fatG: fat,
        ),
      );

      final entry = FoodEntry.fromFoods(
        id: _uuid.v4(),
        mealType: _mealType,
        foods: [food],
        userId: userId,
      );

      await ref.read(foodLogRepositoryProvider).addFoodEntry(entry);

      final tx = CalorieTransaction(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        type: TransactionType.foodWithdrawal,
        calories: calories,
        label: '$_mealType • ${_nameController.text.trim()}',
        foodEntryId: entry.id,
        userId: userId,
        date: _dateKey(DateTime.now()),
      );
      await ref.read(transactionRepositoryProvider).addTransaction(tx);

      // Update daily summary
      final summaryRepo = ref.read(dailySummaryRepositoryProvider);
      final profile =
          await ref.read(userProfileRepositoryProvider).getProfile(userId);
      final today = DateTime.now();
      var summary = await summaryRepo.getSummaryForDate(userId, today);
      if (summary == null) {
        summary = DailySummary(
            userId: userId, date: today, budget: profile?.dailyCalorieBudget ?? 2000);
        await summaryRepo.saveSummary(summary.copyWith(
          consumed: calories,
          proteinConsumedG: protein,
          carbsConsumedG: carbs,
          fatConsumedG: fat,
        ));
      } else {
        await summaryRepo.updateSummary(summary.copyWith(
          consumed: summary.consumed + calories,
          proteinConsumedG: summary.proteinConsumedG + protein,
          carbsConsumedG: summary.carbsConsumedG + carbs,
          fatConsumedG: summary.fatConsumedG + fat,
        ));
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

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Food', style: AppTextStyles.headlineSmall),
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
            // Meal type selector
            Text('Meal Type', style: AppTextStyles.inputLabel),
            const SizedBox(height: 8),
            Row(
              children: ['breakfast', 'lunch', 'dinner', 'snack']
                  .map((type) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _mealType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 40,
                              decoration: BoxDecoration(
                                color: _mealType == type
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _mealType == type
                                      ? AppColors.primary
                                      : AppColors.cardBorder,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  type[0].toUpperCase() + type.substring(1),
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: _mealType == type
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _field('Food Name', _nameController,
                hint: 'e.g. Chicken Biryani',
                validator: (v) => v?.isEmpty == true ? 'Required' : null),
            const SizedBox(height: 16),
            _field('Quantity', _quantityController, hint: 'e.g. 1 plate'),
            const SizedBox(height: 16),
            _field('Calories (kcal)', _caloriesController,
                hint: '0',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty == true) return 'Required';
                  if (int.tryParse(v!) == null) return 'Enter a number';
                  return null;
                }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _field('Protein (g)', _proteinController,
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field('Carbs (g)', _carbsController,
                        keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field('Fat (g)', _fatController,
                        keyboardType: TextInputType.number)),
              ],
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Log Food',
              onPressed: _isLoading ? null : _save,
              isLoading: _isLoading,
              icon: Icons.add_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller,
      {String? hint,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator,
    );
  }
}
