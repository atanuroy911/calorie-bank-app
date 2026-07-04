import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

class PreferencesService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  PreferencesService(this._prefs, this._secureStorage);

  // --- Onboarding ---
  bool get isOnboardingComplete =>
      _prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(AppConstants.onboardingCompletedKey, value);

  bool get isIntroSeen =>
      _prefs.getBool('intro_seen') ?? false;

  Future<void> setIntroSeen(bool value) =>
      _prefs.setBool('intro_seen', value);

  // --- User ID ---
  String? get userId => _prefs.getString(AppConstants.userIdKey);

  Future<void> setUserId(String id) =>
      _prefs.setString(AppConstants.userIdKey, id);

  // --- AI Settings ---
  String get aiProvider =>
      _prefs.getString(AppConstants.aiProviderKey) ?? AppConstants.defaultAiProvider;

  Future<void> setAiProvider(String provider) =>
      _prefs.setString(AppConstants.aiProviderKey, provider);

  Future<String?> getAiApiKey() =>
      _secureStorage.read(key: AppConstants.aiApiKeyKey);

  Future<void> setAiApiKey(String key) =>
      _secureStorage.write(key: AppConstants.aiApiKeyKey, value: key);

  Future<void> clearAiApiKey() =>
      _secureStorage.delete(key: AppConstants.aiApiKeyKey);

  // --- Custom Backend ---
  bool get useCustomBackend =>
      _prefs.getBool(AppConstants.useCustomBackendKey) ?? false;

  Future<void> setUseCustomBackend(bool value) =>
      _prefs.setBool(AppConstants.useCustomBackendKey, value);

  String get backendUrl =>
      _prefs.getString(AppConstants.backendUrlKey) ?? AppConstants.defaultBackendUrl;

  Future<void> setBackendUrl(String url) =>
      _prefs.setString(AppConstants.backendUrlKey, url.trim());

  Future<String?> getBackendToken() =>
      _secureStorage.read(key: AppConstants.backendTokenKey);

  Future<void> setBackendToken(String token) =>
      _secureStorage.write(key: AppConstants.backendTokenKey, value: token);

  Future<void> clearBackendToken() =>
      _secureStorage.delete(key: AppConstants.backendTokenKey);


  // --- Last Active Date ---
  DateTime? get lastActiveDate {
    final s = _prefs.getString(AppConstants.lastActiveDateKey);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  Future<void> setLastActiveDate(DateTime date) =>
      _prefs.setString(AppConstants.lastActiveDateKey, date.toIso8601String());

  // --- AI usage counter ---
  int get aiUsageToday => _prefs.getInt('ai_usage_today') ?? 0;
  String? get aiUsageDate => _prefs.getString('ai_usage_date');

  Future<void> incrementAiUsage() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (aiUsageDate != today) {
      await _prefs.setString('ai_usage_date', today);
      await _prefs.setInt('ai_usage_today', 1);
    } else {
      await _prefs.setInt('ai_usage_today', aiUsageToday + 1);
    }
  }

  Future<void> resetAiUsage() async {
    await _prefs.remove('ai_usage_today');
    await _prefs.remove('ai_usage_date');
  }

  // --- Clear all ---
  Future<void> clear() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
  }
}
