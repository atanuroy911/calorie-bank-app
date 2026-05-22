import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile_setup/profile_setup_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/help_screen.dart';
import '../screens/backup_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../models/user_profile.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String backup = '/backup';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      profileSetup: (context) => const ProfileSetupScreen(),
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),
      settings: (context) => const SettingsScreen(),
      help: (context) => const HelpScreen(),
      backup: (context) => const BackupScreen(),
      // editProfile requires arguments, handled in generateRoute
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/':
        page = const SplashScreen();
        break;
      case '/onboarding':
        page = const OnboardingScreen();
        break;
      case '/profile-setup':
        page = const ProfileSetupScreen();
        break;
      case '/home':
        page = const HomeScreen();
        break;
      case '/profile':
        page = const ProfileScreen();
        break;
      case '/settings':
        page = const SettingsScreen();
        break;
      case '/help':
        page = const HelpScreen();
        break;
      case '/backup':
        page = const BackupScreen();
        break;
      case '/edit-profile':
        final profile = settings.arguments as UserProfile?;
        if (profile == null) {
          page = Scaffold(
            body: Center(
              child: Text('Error: Profile data required for edit screen'),
            ),
          );
        } else {
          page = EditProfileScreen(profile: profile);
        }
        break;
      default:
        page = Scaffold(
          body: Center(child: Text('Route not found: ${settings.name}')),
        );
    }

    return _buildRoute(page);
  }

  static PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
