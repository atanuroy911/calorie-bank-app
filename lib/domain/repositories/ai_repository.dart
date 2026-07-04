import '../entities/chat_message.dart';

abstract class AiRepository {
  /// Send a message to the configured AI endpoint (custom backend or direct provider).
  ///
  /// [userContext] is optional extra context your server may use for smarter
  /// model routing (e.g. route budget-related questions to a lighter model).
  Future<AiResponse> sendMessage({
    required String sessionId,
    required List<ChatMessage> history,
    required String userMessage,
    Map<String, dynamic>? userContext,
  });
}
