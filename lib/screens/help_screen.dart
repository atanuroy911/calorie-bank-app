import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart'; // TODO: Add url_launcher dependency

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchEmail() async {
    // TODO: Add url_launcher dependency and implement email launch
    // final Uri emailLaunchUri = Uri(
    //   scheme: 'mailto',
    //   path: 'support@caloriebank.app',
    //   query: 'subject=Calorie Bank App Support',
    // );
    //
    // if (await canLaunchUrl(emailLaunchUri)) {
    //   await launchUrl(emailLaunchUri);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'We\'re here to help you succeed on your calorie tracking journey!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Frequently Asked Questions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildFAQItem(
                  context,
                  'How accurate are the calorie calculations?',
                  'Our calculations use the Mifflin-St Jeor equation, which is widely recognized as one of the most accurate formulas for calculating BMR.',
                ),
                const Divider(height: 1),
                _buildFAQItem(
                  context,
                  'How often should I update my weight?',
                  'We recommend updating your weight weekly, ideally at the same time of day for consistency.',
                ),
                const Divider(height: 1),
                _buildFAQItem(
                  context,
                  'Can I change my goal later?',
                  'Yes! You can update your target weight and timeline anytime in the Edit Profile section.',
                ),
                const Divider(height: 1),
                _buildFAQItem(
                  context,
                  'What if I have dietary restrictions?',
                  'The app focuses on calorie tracking. Please consult with a nutritionist or dietitian for specific dietary guidance.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Contact Support',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@caloriebank.app'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: _launchEmail,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Report a Bug'),
                  subtitle: const Text('Help us improve the app'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Bug reporting form coming soon!'),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star_outline),
                  title: const Text('Rate the App'),
                  subtitle: const Text('Share your feedback'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App Store rating coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'App Information',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: const Text('1.0.0'),
                ),
                ListTile(
                  leading: const Icon(Icons.policy_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Privacy policy coming soon!'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terms of service coming soon!'),
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

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(answer, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
