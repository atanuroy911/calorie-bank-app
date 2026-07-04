import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/datasources/local/preferences_service.dart';
import '../../data/repositories/food_log_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/bank_repository_impl.dart';
import '../../data/repositories/daily_summary_repository_impl.dart';
import '../../data/repositories/ai_repository_impl.dart';
import '../../data/repositories/user_profile_repository_impl.dart';
import '../../domain/repositories/food_log_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/bank_repository.dart';
import '../../domain/repositories/daily_summary_repository.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/repositories/user_profile_repository.dart';

// --- Infrastructure ---

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize with ProviderScope overrides');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final secure = ref.watch(secureStorageProvider);
  return PreferencesService(prefs, secure);
});

// --- Repositories ---

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepositoryImpl();
});

final foodLogRepositoryProvider = Provider<FoodLogRepository>((ref) {
  return FoodLogRepositoryImpl();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl();
});

final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepositoryImpl();
});

final dailySummaryRepositoryProvider = Provider<DailySummaryRepository>((ref) {
  return DailySummaryRepositoryImpl();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return AiRepositoryImpl(prefs);
});
