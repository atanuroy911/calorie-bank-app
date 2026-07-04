import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/chat_message.dart';

/// Represents a failure talking to the custom backend.
/// [type] drives the friendly error message shown in the chat UI.
enum BackendErrorType {
  noUrlConfigured,
  connectionRefused,   // server is down / wrong host
  timeout,             // server is up but slow
  unauthorized,        // 401 – bad token
  serverError,         // 5xx
  invalidResponse,     // server replied but not in expected JSON format
  noNetwork,           // device has no internet
}

class AiBackendException implements Exception {
  final BackendErrorType type;
  final String? detail;
  const AiBackendException(this.type, [this.detail]);

  /// Human-readable message shown in the chat bubble.
  String get userMessage {
    switch (type) {
      case BackendErrorType.noUrlConfigured:
        return '⚙️ No backend server configured. Go to **Settings → AI Provider** and enter your server URL, or enable a direct provider.';
      case BackendErrorType.connectionRefused:
        return '🔌 Can\'t reach your backend server. Check the URL in Settings and make sure the server is running.';
      case BackendErrorType.timeout:
        return '⏱️ Your server took too long to respond. It may be overloaded — try again in a moment.';
      case BackendErrorType.unauthorized:
        return '🔐 Invalid auth token. Update the bearer token in **Settings → AI Provider**.';
      case BackendErrorType.serverError:
        return '🔥 Your server returned an error (${detail ?? '5xx'}). Check your backend logs.';
      case BackendErrorType.invalidResponse:
        return '⚠️ Server replied but the response format is unexpected. Make sure your server returns `{message, action, data}`.';
      case BackendErrorType.noNetwork:
        return '📵 No internet connection. Connect to a network and try again.';
    }
  }

  @override
  String toString() => 'AiBackendException(${type.name}: $detail)';
}

/// Sends the standardised CalBot request to the user's custom backend server.
///
/// **Request body** (POST /your-endpoint):
/// ```json
/// {
///   "session_id": "...",
///   "message": "I had 2 eggs",
///   "history": [{"role":"user","content":"..."}, ...],
///   "user_context": {
///     "daily_budget": 1850,
///     "consumed_today": 320,
///     "bank_balance": 2100
///   },
///   "system_prompt": "..." // full CalBot prompt, server may override/ignore
/// }
/// ```
///
/// **Expected response** (your server decides the model, returns):
/// ```json
/// {
///   "message": "Logged! 2 eggs = 180 kcal",
///   "action": "food_log",
///   "data": { "meal_type": "breakfast", "foods": [...] }
/// }
/// ```
class CustomBackendDataSource {
  final String backendUrl;
  final String? authToken;
  final Dio _dio;

  CustomBackendDataSource({
    required this.backendUrl,
    this.authToken,
  }) : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 15),
          ),
        );

  Future<AiResponse> sendMessage({
    required String sessionId,
    required List<ChatMessage> history,
    required String userMessage,
    Map<String, dynamic>? userContext,
  }) async {
    // 1. Guard: URL must be configured
    if (backendUrl.isEmpty) {
      throw const AiBackendException(BackendErrorType.noUrlConfigured);
    }

    // 2. Build request payload — server gets everything it needs
    final payload = {
      'session_id': sessionId,
      'message': userMessage,
      'history': history
          .where((m) => m.status == ChatMessageStatus.sent)
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList(),
      'user_context': userContext ?? {},
      'system_prompt': AppConstants.aiSystemPrompt,
    };

    // 3. Build headers
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Client': 'CalorieBank/1.0',
    };
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    // 4. POST to backend
    try {
      final response = await _dio.post(
        backendUrl,
        data: jsonEncode(payload),
        options: Options(headers: headers),
      );

      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } on SocketException {
      throw const AiBackendException(BackendErrorType.noNetwork);
    } on AiBackendException {
      rethrow;
    } catch (e) {
      throw AiBackendException(BackendErrorType.serverError, e.toString());
    }
  }

  /// Ping the health endpoint — used by the "Test Connection" button in settings.
  /// Expects any 2xx response from GET `{backendUrl}/health` or `{baseUrl}/health`.
  Future<BackendHealthResult> testConnection() async {
    final healthUrl = _buildHealthUrl(backendUrl);
    final headers = <String, String>{
      'X-Client': 'CalorieBank/1.0',
    };
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    try {
      final response = await _dio.get(
        healthUrl,
        options: Options(headers: headers),
      );
      final latencyMs = (response.extra['latency_ms'] as int?) ?? -1;
      return BackendHealthResult.ok(
        message: 'Connected ✓',
        latencyMs: latencyMs,
      );
    } on DioException catch (e) {
      return BackendHealthResult.fail(_mapDioError(e).userMessage);
    } on SocketException {
      return BackendHealthResult.fail('No network connection');
    } catch (e) {
      return BackendHealthResult.fail(e.toString());
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  AiResponse _parseResponse(dynamic rawData) {
    try {
      final Map<String, dynamic> json =
          rawData is String ? jsonDecode(rawData) : rawData as Map<String, dynamic>;

      final message = json['message'] as String? ?? '';
      final action = json['action'] as String? ?? 'none';
      final data = json['data'] as Map<String, dynamic>?;

      if (message.isEmpty) {
        throw const AiBackendException(BackendErrorType.invalidResponse);
      }

      return AiResponse(message: message, action: action, data: data);
    } catch (e) {
      if (e is AiBackendException) rethrow;
      throw const AiBackendException(BackendErrorType.invalidResponse);
    }
  }

  AiBackendException _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AiBackendException(BackendErrorType.timeout);

      case DioExceptionType.connectionError:
        return const AiBackendException(BackendErrorType.connectionRefused);

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        if (status == 401 || status == 403) {
          return const AiBackendException(BackendErrorType.unauthorized);
        }
        if (status >= 500) {
          return AiBackendException(
              BackendErrorType.serverError, 'HTTP $status');
        }
        return AiBackendException(
            BackendErrorType.serverError, 'HTTP $status');

      default:
        return AiBackendException(
            BackendErrorType.connectionRefused, e.message);
    }
  }

  /// Builds a health check URL from the main endpoint.
  /// e.g. https://api.myserver.com/chat → https://api.myserver.com/health
  String _buildHealthUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.replace(path: '/health').toString();
    } catch (_) {
      return '$url/health';
    }
  }
}

class BackendHealthResult {
  final bool isOk;
  final String message;
  final int? latencyMs;

  const BackendHealthResult._({
    required this.isOk,
    required this.message,
    this.latencyMs,
  });

  factory BackendHealthResult.ok({required String message, int? latencyMs}) =>
      BackendHealthResult._(isOk: true, message: message, latencyMs: latencyMs);

  factory BackendHealthResult.fail(String message) =>
      BackendHealthResult._(isOk: false, message: message);
}
