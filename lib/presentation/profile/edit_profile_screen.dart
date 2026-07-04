import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../shared/widgets/gradient_button.dart';

// Stub — wire up real edit logic connected to UserProfileRepository
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.headlineSmall),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Edit profile coming soon.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
          GradientButton(
            label: 'Save Changes',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
