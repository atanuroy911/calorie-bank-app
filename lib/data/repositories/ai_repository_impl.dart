import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/local/preferences_service.dart';
import '../datasources/remote/ai_datasource.dart';
import '../datasources/remote/custom_backend_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final PreferencesService _prefs;

  AiRepositoryImpl(this._prefs);

  @override
  Future<AiResponse> sendMessage({
    required String sessionId,
    required List<ChatMessage> history,
    required String userMessage,
    Map<String, dynamic>? userContext,
  }) async {
    // ── Route 1: Custom backend (preferred) ──────────────────────────────────
    // If the user has enabled a custom backend URL, ALL traffic goes through it.
    // The server decides which model/provider to use.
    if (_prefs.useCustomBackend && _prefs.backendUrl.isNotEmpty) {
      final token = await _prefs.getBackendToken();
      final dataSource = CustomBackendDataSource(
        backendUrl: _prefs.backendUrl,
        authToken: token,
      );
      // Let AiBackendException propagate — the chat provider catches and shows
      // the .userMessage to the user.
      return dataSource.sendMessage(
        sessionId: sessionId,
        history: history,
        userMessage: userMessage,
        userContext: userContext,
      );
    }

    // ── Route 2: Direct provider (fallback / dev mode) ───────────────────────
    // Used when no custom backend is configured. Still calls the AI API
    // directly with the user-supplied API key.
    final apiKey = await _prefs.getAiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      // Neither backend nor direct key → guide user to settings
      throw const AiBackendException(
        BackendErrorType.noUrlConfigured,
      );
    }

    final dataSource = AiDataSource(
      provider: _prefs.aiProvider,
      apiKey: apiKey,
    );
    return dataSource.sendMessage(history: history, userMessage: userMessage);
  }
}
