import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final PageController _pageController = PageController();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _daysController = TextEditingController();

  Sex _selectedSex = Sex.male;
  ExerciseLevel _selectedExerciseLevel = ExerciseLevel.moderate;
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _finishSetup();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    if (_currentPage == 0) {
      if (_nameController.text.trim().isEmpty) {
        _showError('Please enter your name');
        return false;
      }
      if (_ageController.text.trim().isEmpty) {
        _showError('Please enter your age');
        return false;
      }
      int? age = int.tryParse(_ageController.text);
      if (age == null || age < 10 || age > 120) {
        _showError('Please enter a valid age between 10 and 120');
        return false;
      }
    } else if (_currentPage == 1) {
      if (_weightController.text.trim().isEmpty) {
        _showError('Please enter your weight');
        return false;
      }
      if (_heightController.text.trim().isEmpty) {
        _showError('Please enter your height');
        return false;
      }
      double? weight = double.tryParse(_weightController.text);
      double? height = double.tryParse(_heightController.text);
      if (weight == null || weight < 20 || weight > 300) {
        _showError('Please enter a valid weight between 20 and 300 kg');
        return false;
      }
      if (height == null || height < 100 || height > 250) {
        _showError('Please enter a valid height between 100 and 250 cm');
        return false;
      }
    } else if (_currentPage == 2) {
      if (_targetWeightController.text.trim().isEmpty) {
        _showError('Please enter your target weight');
        return false;
      }
      if (_daysController.text.trim().isEmpty) {
        _showError('Please enter number of days');
        return false;
      }
      double? targetWeight = double.tryParse(_targetWeightController.text);
      int? days = int.tryParse(_daysController.text);
      if (targetWeight == null || targetWeight < 20 || targetWeight > 300) {
        _showError('Please enter a valid target weight between 20 and 300 kg');
        return false;
      }
      if (days == null || days < 1 || days > 365) {
        _showError('Please enter a valid number of days between 1 and 365');
        return false;
      }
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorRed),
    );
  }

  Future<void> _finishSetup() async {
    if (!_validateCurrentPage()) return;

    final profile = UserProfile(
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      sex: _selectedSex,
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      targetWeight: double.parse(_targetWeightController.text),
      daysToTarget: int.parse(_daysController.text),
      exerciseLevel: _selectedExerciseLevel,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', profile.toJsonString());
    await prefs.setBool('profile_completed', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffixText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
          suffixText: suffixText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppTheme.primaryGradient)),
        foregroundColor: Colors.white,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect(
                  dotColor: AppTheme.lightGray,
                  activeDotColor: AppTheme.primaryGreen,
                  dotHeight: 12,
                  dotWidth: 12,
                  spacing: 16,
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildBasicInfoPage(),
                  _buildMeasurementsPage(),
                  _buildGoalsPage(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ]
              ),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _previousPage,
                        child: const Text('Back', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == 2 ? 'Complete Setup' : 'Continue',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person_pin, size: 64, color: AppTheme.primaryBlue),
          const SizedBox(height: 16),
          Text('Tell us about yourself', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('This helps our AI precisely calculate your daily calorie budget.', style: TextStyle(color: AppTheme.mediumGray, fontSize: 16)),
          const SizedBox(height: 40),

          _buildTextField(
            controller: _nameController,
            label: 'Your Name',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _ageController,
            label: 'Age',
            icon: Icons.cake_outlined,
            suffixText: 'years',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sex', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen)),
                const SizedBox(height: 8),
                ...Sex.values.map((sex) {
                  return RadioListTile<Sex>(
                    activeColor: AppTheme.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                    title: Text(sex.label),
                    value: sex,
                    groupValue: _selectedSex,
                    onChanged: (Sex? value) {
                      if (value != null) setState(() => _selectedSex = value);
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMeasurementsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.straighten, size: 64, color: AppTheme.primaryBlue),
          const SizedBox(height: 16),
          Text('Your body profile', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Accurate measurements mean better bank goals.', style: TextStyle(color: AppTheme.mediumGray, fontSize: 16)),
          const SizedBox(height: 40),

          _buildTextField(
            controller: _weightController,
            label: 'Current Weight',
            icon: Icons.monitor_weight_outlined,
            suffixText: 'kg',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _heightController,
            label: 'Height',
            icon: Icons.height,
            suffixText: 'cm',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.flag_circle_outlined, size: 64, color: AppTheme.primaryBlue),
          const SizedBox(height: 16),
          Text('Set your goals', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Let\'s set your targets so you can start saving.', style: TextStyle(color: AppTheme.mediumGray, fontSize: 16)),
          const SizedBox(height: 40),

          _buildTextField(
            controller: _targetWeightController,
            label: 'Target Weight',
            icon: Icons.flag_outlined,
            suffixText: 'kg',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _daysController,
            label: 'Timeline',
            icon: Icons.calendar_today_outlined,
            suffixText: 'days',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Activity Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen)),
                const SizedBox(height: 8),
                ...ExerciseLevel.values.map((level) {
                  return RadioListTile<ExerciseLevel>(
                    activeColor: AppTheme.primaryGreen,
                    contentPadding: EdgeInsets.zero,
                    title: Text(level.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(level.description, style: const TextStyle(fontSize: 12)),
                    value: level,
                    groupValue: _selectedExerciseLevel,
                    onChanged: (ExerciseLevel? value) {
                      if (value != null) setState(() => _selectedExerciseLevel = value);
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
