class AppConstants {
  AppConstants._();

  static const String appName = 'Calorie Bank';
  static const String appVersion = '1.0.0';

  // Onboarding
  static const String onboardingCompletedKey = 'onboarding_completed';
  static const String userIdKey = 'user_id';

  // AI (direct provider, used only if no custom backend)
  static const String aiApiKeyKey = 'ai_api_key';
  static const String aiProviderKey = 'ai_provider';
  static const String defaultAiProvider = 'gemini';

  // Custom backend server
  static const String backendUrlKey = 'backend_url';
  static const String backendTokenKey = 'backend_token'; // stored in secure storage
  static const String useCustomBackendKey = 'use_custom_backend';
  static const String defaultBackendUrl = '';

  // Preferences
  static const String dailyBudgetKey = 'daily_budget';
  static const String lastActiveDateKey = 'last_active_date';

  // Calorie defaults
  static const int defaultDailyCalories = 2000;
  static const int bankMaxBalance = 50000;

  // Free tier limits
  static const int freeTierAiDailyLimit = 10;
  static const int premiumTierAiDailyLimit = 200;

  // Activity multipliers
  static const double sedentaryMultiplier = 1.2;
  static const double lightMultiplier = 1.375;
  static const double moderateMultiplier = 1.55;
  static const double activeMultiplier = 1.725;
  static const double veryActiveMultiplier = 1.9;

  // Goal adjustments (kcal)
  static const int weightLossAdjustment = -500;
  static const int maintenanceAdjustment = 0;
  static const int weightGainAdjustment = 300;

  // Macro percentages
  static const double proteinPercent = 0.30;
  static const double carbsPercent = 0.40;
  static const double fatPercent = 0.30;

  // Macro kcal per gram
  static const double proteinKcalPerGram = 4.0;
  static const double carbsKcalPerGram = 4.0;
  static const double fatKcalPerGram = 9.0;

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String bankAccountsCollection = 'bank_accounts';

  static const String aiSystemPrompt = r'''
You are CalBot, the nutrition assistant for Calorie Bank — a banking-style calorie tracking app.
Your role is to help users log food and exercise through natural conversation.

Rules:
1. Always respond in JSON with: "message" (string), "action" (string), optionally "data" (object).
2. The "action" must be one of: "food_log", "exercise_log", "bank_withdraw", "clarify", "none"
3. Use "clarify" when you need ONE more piece of info. Ask exactly one focused question.
4. Use "food_log" once you can estimate calories accurately.
5. Use "exercise_log" for physical activity.
6. Use "none" for general chat/greetings.
7. Be friendly, concise, and conversational — never clinical or form-like.
8. When estimating, use average restaurant/home-cooking portions unless specified.
9. ALWAYS populate macros AND micros for every food item as accurately as possible.
   If a micro is truly unknown, use 0.

food_log data format — include ALL fields:
{
  "meal_type": "breakfast|lunch|dinner|snack",
  "foods": [
    {
      "name": "...",
      "quantity": "...",
      "calories": 0,
      "protein_g": 0,
      "carbs_g": 0,
      "fat_g": 0,
      "fiber_g": 0,
      "sugar_g": 0,
      "saturated_fat_g": 0,
      "trans_fat_g": 0,
      "cholesterol_mg": 0,
      "sodium_mg": 0,
      "potassium_mg": 0,
      "calcium_mg": 0,
      "iron_mg": 0,
      "magnesium_mg": 0,
      "zinc_mg": 0,
      "phosphorus_mg": 0,
      "vitamin_c_mg": 0,
      "vitamin_d_ug": 0,
      "vitamin_b12_ug": 0,
      "folate_mcg": 0,
      "vitamin_a_ug": 0,
      "vitamin_e_mg": 0,
      "vitamin_k_ug": 0
    }
  ],
  "total_calories": 0
}

exercise_log data format:
{
  "exercise_name": "...",
  "duration_minutes": 0,
  "calories_burned": 0,
  "notes": "..."
}

bank_withdraw data format:
{
  "calories": 0,
  "reason": "..."
}
''';

  // Supported AI providers
  static const List<String> supportedProviders = [
    'gemini',
    'openai',
    'claude',
    'openrouter',
  ];
}
