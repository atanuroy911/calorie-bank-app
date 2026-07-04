import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoadingAuth = false;

  Future<void> _linkGoogleAccount() async {
    setState(() => _isLoadingAuth = true);
    try {
      await ref.read(authActionsProvider).signInWithGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account linked successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error linking account: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAuth = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authActions = ref.watch(authActionsProvider);
    final isGuest = authActions.isGuest;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.headlineSmall),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        children: [
          if (isGuest) ...[
            ListTile(
              leading: const Icon(Icons.account_circle_rounded, color: Colors.blue),
              title: const Text('Sign in with Google'),
              subtitle: const Text('Link your account to save data'),
              trailing: _isLoadingAuth 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              onTap: _isLoadingAuth ? null : _linkGoogleAccount,
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
          ],
          ListTile(
            leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent),
            title: const Text('AI Provider'),
            subtitle: const Text('Configure your AI API key'),
            trailing: const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted),
            onTap: () => Navigator.pushNamed(context, '/profile/ai-settings'),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          ListTile(
            leading: const Icon(Icons.notifications_rounded,
                color: AppColors.primary),
            title: const Text('Notifications'),
            subtitle: const Text('End-of-day reminders'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded,
                color: AppColors.textSecondary),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
