import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/theme_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _soundEffects = false;
  String _apiKey = '';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('pref_push') ?? true;
      _soundEffects = prefs.getBool('pref_sound') ?? false;
      _apiKey = prefs.getString('gemini_api_key') ?? '';
    });
  }

  Future<void> _togglePush(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_push', val);
    setState(() => _pushNotifications = val);
  }

  Future<void> _toggleSound(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pref_sound', val);
    setState(() => _soundEffects = val);
  }

  void _clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gemini_api_key');
    setState(() => _apiKey = '');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key cleared. Open chat to set up again.'), backgroundColor: AppTheme.primaryGreen)
      );
    }
  }

  void _resetApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? AppTheme.darkGray,
        title: const Text('Reset App Data?', style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
        content: const Text('This will wipe your profile, settings, and calorie bank. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false);
              }
            },
            child: const Text('Reset Everything', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...AppThemeMode.values.map(
                        (mode) => RadioListTile<AppThemeMode>(
                          activeColor: AppTheme.primaryGreen,
                          title: Text(mode.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            mode == AppThemeMode.system
                                ? 'Follow system settings'
                                : mode == AppThemeMode.light
                                ? 'Use light theme'
                                : 'Use dark theme',
                          ),
                          value: mode,
                          groupValue: themeProvider.themeMode,
                          onChanged: (value) {
                            if (value != null) {
                              themeProvider.setThemeMode(value);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          Text('AI Assistant', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 32),
              title: const Text('Gemini API Key', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                _apiKey.isNotEmpty ? 'Linked: ...${_apiKey.substring(_apiKey.length - 4)}' : 'Not linked yet',
              ),
              trailing: _apiKey.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                      tooltip: 'Remove Key',
                      onPressed: _clearApiKey,
                    )
                  : const Icon(Icons.chevron_right),
            ),
          ),

          const SizedBox(height: 24),
          Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  activeThumbColor: AppTheme.primaryGreen,
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Receive calorie reminders'),
                  value: _pushNotifications,
                  onChanged: _togglePush,
                  secondary: const Icon(Icons.notifications_outlined),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  activeThumbColor: AppTheme.primaryGreen,
                  title: const Text('Sound Effects', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Play sounds for interactions'),
                  value: _soundEffects,
                  onChanged: _toggleSound,
                  secondary: const Icon(Icons.volume_up_outlined),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text('Danger Zone', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.errorRed)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.3), width: 2),
            ),
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: AppTheme.errorRed, size: 32),
              title: const Text('Reset App Data', style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
              subtitle: const Text('Clear all data and restart'),
              onTap: _resetApp,
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
