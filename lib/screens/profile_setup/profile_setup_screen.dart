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

  // Form controllers
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
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
              padding: const EdgeInsets.all(20.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect(
                  dotColor: Colors.grey.shade300,
                  activeDotColor: AppTheme.primaryGreen,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 16,
                ),
                onDotClicked: (index) {
                  // Optionally allow clicking on dots to navigate
                },
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildBasicInfoPage(),
                  _buildMeasurementsPage(),
                  _buildGoalsPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: _currentPage == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(_currentPage == 2 ? 'Finish' : 'Next'),
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us calculate your daily calorie target',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Name Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Age Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Enter your age',
                      prefixIcon: Icon(Icons.cake_outlined),
                      suffixText: 'years',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sex Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sex', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...Sex.values.map((sex) {
                    return RadioListTile<Sex>(
                      title: Text(sex.label),
                      value: sex,
                      groupValue: _selectedSex,
                      onChanged: (Sex? value) {
                        if (value != null) {
                          setState(() {
                            _selectedSex = value;
                          });
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your measurements',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'We need these to calculate your calorie needs',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Weight Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monitor_weight_outlined, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Current Weight',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your weight',
                      suffixText: 'kg',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Height Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.height, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Height',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your height',
                      suffixText: 'cm',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your goals', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Tell us what you want to achieve',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Target Weight Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Target Weight',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _targetWeightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter your target weight',
                      suffixText: 'kg',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Timeline Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Timeline',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _daysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Days to reach your goal',
                      suffixText: 'days',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Exercise Level Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.fitness_center_outlined, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Exercise Level',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...ExerciseLevel.values.map((level) {
                    return RadioListTile<ExerciseLevel>(
                      title: Text(level.label),
                      subtitle: Text(
                        level.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      value: level,
                      groupValue: _selectedExerciseLevel,
                      onChanged: (ExerciseLevel? value) {
                        if (value != null) {
                          setState(() {
                            _selectedExerciseLevel = value;
                          });
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
