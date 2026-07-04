class ApiConstants {
  ApiConstants._();

  // Gemini
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiDefaultModel = 'gemini-2.0-flash';
  static const String geminiGenerateContentPath = '/models/{model}:generateContent';

  // OpenAI
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String openAiDefaultModel = 'gpt-4o-mini';
  static const String openAiChatPath = '/chat/completions';

  // Anthropic (Claude)
  static const String claudeBaseUrl = 'https://api.anthropic.com/v1';
  static const String claudeDefaultModel = 'claude-3-haiku-20240307';
  static const String claudeMessagesPath = '/messages';
  static const String claudeVersion = '2023-06-01';

  // OpenRouter
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterDefaultModel = 'openai/gpt-4o-mini';

  // Timeouts
  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 60;
  static const int sendTimeoutSeconds = 30;

  // Retry
  static const int maxRetries = 3;
}
