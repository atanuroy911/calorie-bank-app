import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  final String apiKey;
  
  GenerativeModel? _model;
  ChatSession? _chatSession;
  
  // A simple list to keep track of mock chat history if API key is not provided
  final List<String> _mockHistory = [];

  AIService({required this.apiKey}) {
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system('''
You are an expert nutritionist and friendly AI assistant for a calorie tracking app. 
Converse with the user to understand what they ate and estimate the calories.
If the user's input is vague (like "biryani"), ask clarifying questions (e.g. "Was it chicken or veg? How large was the portion?").
Once you and the user have agreed on the food and calorie estimate, ask if they want to log it.
If they confirm they want to log it, you MUST output ONLY a valid JSON object in the exact format below and nothing else:
{
  "status": "CONFIRMED",
  "title": "Name of the meal",
  "calories": 500
}
Otherwise, respond with normal conversational text.
'''),
      );
      _chatSession = _model!.startChat();
    }
  }

  Future<String> sendMessage(String text) async {
    if (apiKey.isEmpty) {
      // Mock logic for demonstration
      await Future.delayed(const Duration(seconds: 1));
      final lower = text.toLowerCase();
      
      if (_mockHistory.isEmpty) {
        _mockHistory.add(text);
        if (lower.contains('biryani')) {
          return "Yum! Biryani is great. Was it chicken or veg? And was it a full plate or half plate?";
        }
        return "Got it. That sounds like around 300 calories. Should I log that for you?";
      } else {
        if (lower.contains('yes') || lower.contains('log') || lower.contains('confirm')) {
          // Send the mock JSON
          return '{"status": "CONFIRMED", "title": "Mock Meal", "calories": 450}';
        }
        return "Okay, I've updated the estimate to 450 calories based on that. Ready to log?";
      }
    }

    // Real API logic
    try {
      final response = await _chatSession!.sendMessage(Content.text(text));
      return response.text?.trim() ?? "I'm sorry, I couldn't process that.";
    } catch (e) {
      print("AI Chat Error: $e");
      return "There was an error communicating with the AI. Please try again.";
    }
  }
}
