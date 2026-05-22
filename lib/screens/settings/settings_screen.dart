import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _soundEffects = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Theme',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      ...AppThemeMode.values.map(
                        (mode) => RadioListTile<AppThemeMode>(
                          title: Text(mode.label),
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
          Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive calorie reminders'),
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() => _pushNotifications = value);
                  },
                  secondary: const Icon(Icons.notifications_outlined),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Sound Effects'),
                  subtitle: const Text('Play sounds for interactions'),
                  value: _soundEffects,
                  onChanged: (value) {
                    setState(() => _soundEffects = value);
                  },
                  secondary: const Icon(Icons.volume_up_outlined),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.straighten_outlined),
                  title: const Text('Units'),
                  subtitle: const Text('Metric (kg, cm)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Units selection coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
