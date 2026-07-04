import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/api_constants.dart';
import '../../../domain/entities/chat_message.dart';

class AiDataSource {
  final Dio _dio;
  final String provider;
  final String apiKey;
  final String? model;

  AiDataSource({
    required this.provider,
    required this.apiKey,
    this.model,
  }) : _dio = Dio(BaseOptions(
          connectTimeout:
              const Duration(seconds: ApiConstants.connectTimeoutSeconds),
          receiveTimeout:
              const Duration(seconds: ApiConstants.receiveTimeoutSeconds),
        ));

  Future<AiResponse> sendMessage({
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    switch (provider) {
      case 'gemini':
        return _sendGemini(history, userMessage);
      case 'openai':
      case 'openrouter':
        return _sendOpenAiCompatible(history, userMessage);
      default:
        return _sendGemini(history, userMessage);
    }
  }

  Future<AiResponse> _sendGemini(
      List<ChatMessage> history, String userMessage) async {
    final effectiveModel = model ?? ApiConstants.geminiDefaultModel;
    final url =
        '${ApiConstants.geminiBaseUrl}/models/$effectiveModel:generateContent?key=$apiKey';

    // Build Gemini-format messages
    final contents = <Map<String, dynamic>>[];

    // Add history (skip system messages)
    for (final msg in history.where((m) => !m.role.name.contains('system'))) {
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.content}
        ],
      });
    }

    // Add current user message
    contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ],
    });

    final body = {
      'system_instruction': {
        'parts': [
          {'text': AppConstants.aiSystemPrompt}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.7,
        'maxOutputTokens': 1024,
      },
    };

    final response = await _dio.post(url, data: body);
    final text = response.data['candidates'][0]['content']['parts'][0]['text'] as String;
    return _parseResponse(text);
  }

  Future<AiResponse> _sendOpenAiCompatible(
      List<ChatMessage> history, String userMessage) async {
    final isOpenRouter = provider == 'openrouter';
    final baseUrl = isOpenRouter
        ? ApiConstants.openRouterBaseUrl
        : ApiConstants.openAiBaseUrl;
    final effectiveModel = model ??
        (isOpenRouter
            ? ApiConstants.openRouterDefaultModel
            : ApiConstants.openAiDefaultModel);

    final messages = <Map<String, dynamic>>[
      {'role': 'system', 'content': AppConstants.aiSystemPrompt},
    ];

    for (final msg in history) {
      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      });
    }
    messages.add({'role': 'user', 'content': userMessage});

    final response = await _dio.post(
      '$baseUrl/chat/completions',
      data: {
        'model': effectiveModel,
        'messages': messages,
        'response_format': {'type': 'json_object'},
        'temperature': 0.7,
        'max_tokens': 1024,
      },
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      }),
    );

    final text =
        response.data['choices'][0]['message']['content'] as String;
    return _parseResponse(text);
  }

  AiResponse _parseResponse(String rawText) {
    try {
      final json = jsonDecode(rawText) as Map<String, dynamic>;
      return AiResponse(
        message: json['message'] as String? ?? rawText,
        action: json['action'] as String? ?? 'none',
        data: json['data'] as Map<String, dynamic>?,
      );
    } catch (_) {
      // If JSON parsing fails, treat as plain message
      return AiResponse(
        message: rawText,
        action: 'none',
      );
    }
  }
}
