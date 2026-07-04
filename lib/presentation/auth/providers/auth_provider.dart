import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';

// Simple auth state using preferences (Firebase stubs)
final authStateProvider = StateProvider<AuthState>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  if (prefs.userId != null) {
    return AuthState.authenticated(prefs.userId!);
  }
  return const AuthState.unauthenticated();
});

class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? error;

  const AuthState._({
    required this.isAuthenticated,
    this.userId,
    this.error,
  });

  const factory AuthState.authenticated(String userId) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  factory AuthState.error(String error) => AuthState._(
        isAuthenticated: false,
        error: error,
      );
}

class _Authenticated extends AuthState {
  const _Authenticated(String userId)
      : super._(isAuthenticated: true, userId: userId);
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated() : super._(isAuthenticated: false);
}

// Auth actions provider
final authActionsProvider = Provider<AuthActions>((ref) {
  return AuthActions(ref);
});

class AuthActions {
  final Ref _ref;
  AuthActions(this._ref);

  Future<void> signInWithGoogle() async {
    final prefs = _ref.read(preferencesServiceProvider);
    
    // TODO: Replace with real GoogleSignIn when OAuth is configured in Cloud Console
    /*
    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account != null) {
      await prefs.setUserId(account.id);
      _ref.invalidate(authStateProvider);
    } else {
      throw Exception('Sign in aborted by user');
    }
    */

    // Simulated network delay for smooth UX during mock phase
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock user ID
    final userId = 'google_user_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setUserId(userId);
    _ref.invalidate(authStateProvider);
  }

  Future<void> continueAsGuest() async {
    final prefs = _ref.read(preferencesServiceProvider);
    // Prefix with guest_ to identify guest accounts
    final userId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setUserId(userId);
    _ref.invalidate(authStateProvider);
  }

  bool get isGuest {
    final prefs = _ref.read(preferencesServiceProvider);
    return prefs.userId?.startsWith('guest_') ?? false;
  }

  Future<void> signOut() async {
    final prefs = _ref.read(preferencesServiceProvider);
    
    // TODO: Real Google Sign out
    /*
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    */
    
    await prefs.clear();
    _ref.invalidate(authStateProvider);
  }
}
