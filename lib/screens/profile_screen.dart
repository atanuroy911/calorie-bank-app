import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      setState(() {
        _userProfile = UserProfile.fromJsonString(profileJson);
      });
    }
  }

  Future<void> _clearProfileAndRestart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('profile_completed');
    await prefs.setBool('first_time', true);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.splash,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar and Name Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar Placeholder
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userProfile?.name ?? 'Loading...',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userProfile != null
                                ? '${_userProfile!.age} years • ${_userProfile!.sex.label}'
                                : '',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Calorie Targets Section
            if (_userProfile != null) ...[
              Text(
                'Daily Targets',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildCalorieRow(
                        'BMR (Basal Metabolic Rate)',
                        '${_userProfile!.bmr.toStringAsFixed(0)} cal',
                        Icons.favorite_outline,
                      ),
                      const SizedBox(height: 16),
                      _buildCalorieRow(
                        'TDEE (Total Daily Energy)',
                        '${_userProfile!.tdee.toStringAsFixed(0)} cal',
                        Icons.local_fire_department_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildCalorieRow(
                        'Daily Calorie Target',
                        '${_userProfile!.dailyCalorieTarget.toStringAsFixed(0)} cal',
                        Icons.flag_outlined,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // Menu Items
            Text(
              'Menu',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _buildMenuItem(
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    icon: Icons.edit_outlined,
                    onTap: () async {
                      if (_userProfile != null) {
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.editProfile,
                          arguments: _userProfile,
                        );
                        if (result == true) {
                          _loadProfile();
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    title: 'Settings',
                    subtitle: 'App theme and preferences',
                    icon: Icons.settings_outlined,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.settings),
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    icon: Icons.help_outline,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.help),
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    title: 'Backup & Restore',
                    subtitle: 'Sync data with Google Drive',
                    icon: Icons.cloud_outlined,
                    badgeText: 'Upcoming',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.backup),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Reset Profile Button
            OutlinedButton.icon(
              onPressed: () => _showResetDialog(),
              icon: const Icon(Icons.refresh, color: Colors.red),
              label: const Text(
                'Reset Profile',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    String? badgeText,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badgeText != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.warningOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.warningOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Profile'),
        content: const Text(
          'Are you sure you want to reset your profile? This will delete all your data and you\'ll need to set up your profile again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearProfileAndRestart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
