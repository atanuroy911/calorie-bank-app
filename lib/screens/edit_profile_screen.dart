import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _daysController;

  late Sex _selectedSex;
  late ExerciseLevel _selectedExerciseLevel;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _ageController = TextEditingController(text: widget.profile.age.toString());
    _weightController = TextEditingController(
      text: widget.profile.weight.toString(),
    );
    _heightController = TextEditingController(
      text: widget.profile.height.toString(),
    );
    _targetWeightController = TextEditingController(
      text: widget.profile.targetWeight.toString(),
    );
    _daysController = TextEditingController(
      text: widget.profile.daysToTarget.toString(),
    );

    _selectedSex = widget.profile.sex;
    _selectedExerciseLevel = widget.profile.exerciseLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name');
      return false;
    }

    final age = int.tryParse(_ageController.text);
    if (age == null || age < 10 || age > 120) {
      _showError('Please enter a valid age between 10 and 120');
      return false;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight < 20 || weight > 300) {
      _showError('Please enter a valid weight between 20 and 300 kg');
      return false;
    }

    final height = double.tryParse(_heightController.text);
    if (height == null || height < 100 || height > 250) {
      _showError('Please enter a valid height between 100 and 250 cm');
      return false;
    }

    final targetWeight = double.tryParse(_targetWeightController.text);
    if (targetWeight == null || targetWeight < 20 || targetWeight > 300) {
      _showError('Please enter a valid target weight between 20 and 300 kg');
      return false;
    }

    final days = int.tryParse(_daysController.text);
    if (days == null || days < 1 || days > 365) {
      _showError('Please enter a valid number of days between 1 and 365');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorRed),
    );
  }

  Future<void> _saveProfile() async {
    if (!_validateInputs()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedProfile = UserProfile(
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
      await prefs.setString('user_profile', updatedProfile.toJsonString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Failed to save profile. Please try again.');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(onPressed: _saveProfile, child: const Text('Save')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        prefixIcon: Icon(Icons.cake_outlined),
                        suffixText: 'years',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Sex', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    ...Sex.values.map((sex) {
                      return RadioListTile<Sex>(
                        title: Text(sex.label),
                        value: sex,
                        groupValue: _selectedSex,
                        onChanged: (value) {
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
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Physical Measurements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Current Weight',
                        prefixIcon: Icon(Icons.monitor_weight_outlined),
                        suffixText: 'kg',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        prefixIcon: Icon(Icons.height),
                        suffixText: 'cm',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Goals',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _targetWeightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target Weight',
                        prefixIcon: Icon(Icons.flag_outlined),
                        suffixText: 'kg',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Days to Target',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        suffixText: 'days',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ExerciseLevel>(
                      initialValue: _selectedExerciseLevel,
                      decoration: const InputDecoration(
                        labelText: 'Exercise Level',
                        prefixIcon: Icon(Icons.fitness_center_outlined),
                      ),
                      isExpanded: true,
                      items: ExerciseLevel.values.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(
                            level.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedExerciseLevel = value;
                          });
                        }
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return ExerciseLevel.values.map((level) {
                          return Text(
                            level.label,
                            overflow: TextOverflow.ellipsis,
                          );
                        }).toList();
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedExerciseLevel.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
