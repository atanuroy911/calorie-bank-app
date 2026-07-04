import 'package:flutter/material.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final bool _isBackingUp = false;
  final bool _isRestoring = false;
  DateTime? _lastBackup;

  @override
  void initState() {
    super.initState();
    // TODO: Load last backup date from preferences
    _lastBackup = DateTime.now().subtract(const Duration(days: 2));
  }

  String _formatLastBackup() {
    if (_lastBackup == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(_lastBackup!);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Backup & Restore'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Upcoming',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Keep your data safe by backing up to Google Drive. You can restore your data on any device.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Backup Status',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_done,
                        color: _lastBackup != null ? Colors.green : Colors.grey,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Backup',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              _formatLastBackup(),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Backup Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: _isBackingUp
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  title: const Text('Backup Now'),
                  subtitle: const Text(
                    'Save your current data to Google Drive',
                  ),
                  trailing: _isBackingUp
                      ? null
                      : const Icon(Icons.chevron_right),
                  onTap: _isBackingUp
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Backup is marked Upcoming and will be enabled in a future update.',
                              ),
                            ),
                          );
                        },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: _isRestoring
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_download_outlined),
                  title: const Text('Restore from Backup'),
                  subtitle: const Text(
                    'Replace current data with backed up data',
                  ),
                  trailing: _isRestoring
                      ? null
                      : const Icon(Icons.chevron_right),
                  onTap: _isRestoring
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Restore is marked Upcoming and will be enabled in a future update.',
                              ),
                            ),
                          );
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Automatic Backup',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Backup'),
                  subtitle: const Text('Automatically backup daily'),
                  value: true, // TODO: Connect to actual setting
                  onChanged: (value) {
                    // TODO: Implement auto backup toggle
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Auto backup enabled'
                              : 'Auto backup disabled',
                        ),
                      ),
                    );
                  },
                  secondary: const Icon(Icons.schedule),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.wifi_outlined),
                  title: const Text('Wi-Fi Only'),
                  subtitle: const Text('Only backup when connected to Wi-Fi'),
                  trailing: Switch(
                    value: true, // TODO: Connect to actual setting
                    onChanged: (value) {
                      // TODO: Implement Wi-Fi only toggle
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'What gets backed up?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackupItem('Profile information (name, age, goals)'),
                  _buildBackupItem('Daily calorie entries and meal logs'),
                  _buildBackupItem('Weight tracking history'),
                  _buildBackupItem('App settings and preferences'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
