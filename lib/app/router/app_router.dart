import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/auth/login_screen.dart';
import '../../presentation/onboarding/onboarding_screen.dart';
import '../../presentation/onboarding/intro_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/chat/chat_screen.dart';
import '../../presentation/transactions/transactions_screen.dart';
import '../../presentation/bank/bank_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/profile/edit_profile_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../presentation/settings/ai_provider_settings_screen.dart';
import '../../presentation/premium/premium_screen.dart';
import '../../presentation/manual_entry/manual_food_screen.dart';
import '../../presentation/manual_entry/manual_exercise_screen.dart';
import '../../presentation/manual_entry/manual_bank_withdraw_screen.dart';
import '../../presentation/shared/shell/app_shell.dart';
import '../../presentation/nutrition/nutrition_detail_screen.dart';
import '../../core/di/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      // Determine auth & onboarding state
      final isLoggedIn = prefs.userId != null;
      final isOnboarded = prefs.isOnboardingComplete;
      final isIntroSeen = prefs.isIntroSeen;

      final path = state.uri.path;

      // Intro guard
      if (!isIntroSeen && path != '/intro') {
        return '/intro';
      }

      // Auth guard
      if (!isLoggedIn) {
        if (path == '/login' || path == '/intro') return null;
        return '/login';
      }

      // Onboarding guard
      if (!isOnboarded && !path.startsWith('/onboarding')) {
        return '/onboarding';
      }

      // Already logged in and going to auth screens
      if (isLoggedIn && path == '/login') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/intro', builder: (_, __) => const IntroScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
          GoRoute(
              path: '/transactions',
              builder: (_, __) => const TransactionsScreen()),
          GoRoute(path: '/bank', builder: (_, __) => const BankScreen()),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(
                  path: 'edit',
                  builder: (_, __) => const EditProfileScreen()),
              GoRoute(
                  path: 'settings',
                  builder: (_, __) => const SettingsScreen()),
              GoRoute(
                  path: 'ai-settings',
                  builder: (_, __) => const AiProviderSettingsScreen()),
              GoRoute(
                  path: 'premium',
                  builder: (_, __) => const PremiumScreen()),
            ],
          ),
          GoRoute(
            path: '/nutrition',
            builder: (_, __) => const NutritionDetailScreen(),
          ),
        ],
      ),

      // Modal routes
      GoRoute(
          path: '/manual/food',
          builder: (_, __) => const ManualFoodScreen()),
      GoRoute(
          path: '/manual/exercise',
          builder: (_, __) => const ManualExerciseScreen()),
      GoRoute(
          path: '/manual/bank-withdraw',
          builder: (_, __) => const ManualBankWithdrawScreen()),
    ],
  );
});
