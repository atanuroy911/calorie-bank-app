import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../data/datasources/remote/custom_backend_datasource.dart';
import '../shared/widgets/gradient_button.dart';

class AiProviderSettingsScreen extends ConsumerStatefulWidget {
  const AiProviderSettingsScreen({super.key});

  @override
  ConsumerState<AiProviderSettingsScreen> createState() =>
      _AiProviderSettingsScreenState();
}

class _AiProviderSettingsScreenState
    extends ConsumerState<AiProviderSettingsScreen> {
  // Backend fields
  final _backendUrlController = TextEditingController();
  final _backendTokenController = TextEditingController();
  bool _useCustomBackend = false;
  bool _obscureToken = true;

  // Direct provider fallback fields
  late String _selectedProvider;
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;

  // UI state
  bool _isLoading = false;
  bool _saved = false;
  _TestState _testState = _TestState.idle;
  String? _testMessage;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesServiceProvider);
    _useCustomBackend = prefs.useCustomBackend;
    _backendUrlController.text = prefs.backendUrl;
    _selectedProvider = prefs.aiProvider;
    _loadSecrets();
  }

  Future<void> _loadSecrets() async {
    final prefs = ref.read(preferencesServiceProvider);
    final token = await prefs.getBackendToken();
    final apiKey = await prefs.getAiApiKey();
    if (mounted) {
      setState(() {
        if (token != null) _backendTokenController.text = token;
        if (apiKey != null) _apiKeyController.text = apiKey;
      });
    }
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    _backendTokenController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final prefs = ref.read(preferencesServiceProvider);
      await prefs.setUseCustomBackend(_useCustomBackend);
      await prefs.setBackendUrl(_backendUrlController.text.trim());
      if (_backendTokenController.text.isNotEmpty) {
        await prefs.setBackendToken(_backendTokenController.text.trim());
      }
      await prefs.setAiProvider(_selectedProvider);
      if (_apiKeyController.text.isNotEmpty) {
        await prefs.setAiApiKey(_apiKeyController.text.trim());
      }
      setState(() => _saved = true);
      Future.delayed(
          const Duration(seconds: 2), () => setState(() => _saved = false));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _testConnection() async {
    final url = _backendUrlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _testState = _TestState.fail;
        _testMessage = 'Enter a backend URL first.';
      });
      return;
    }

    setState(() {
      _testState = _TestState.loading;
      _testMessage = null;
    });

    final token = _backendTokenController.text.trim();
    final ds = CustomBackendDataSource(
      backendUrl: url,
      authToken: token.isNotEmpty ? token : null,
    );
    final result = await ds.testConnection();

    setState(() {
      _testState = result.isOk ? _TestState.ok : _TestState.fail;
      _testMessage = result.isOk
          ? result.message
          : result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Provider', style: AppTextStyles.headlineSmall),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Section 1: Custom Backend ────────────────────────────────────
          _SectionLabel(
            icon: Icons.dns_rounded,
            label: 'YOUR BACKEND SERVER',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _useCustomBackend
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.cardBorder,
                width: _useCustomBackend ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enable toggle
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Use Custom Backend',
                              style: AppTextStyles.titleMedium),
                          Text(
                            'Your server decides which AI model to use',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _useCustomBackend,
                      onChanged: (v) => setState(() => _useCustomBackend = v),
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ],
                ),

                if (_useCustomBackend) ...[
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.cardBorder, height: 1),
                  const SizedBox(height: 20),

                  // Backend URL
                  _buildField(
                    controller: _backendUrlController,
                    label: 'Backend URL',
                    hint: 'https://api.yourserver.com/chat',
                    icon: Icons.link_rounded,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 14),

                  // Auth token
                  _buildSecretField(
                    controller: _backendTokenController,
                    label: 'Bearer Token (optional)',
                    hint: 'sk-xxxx or your secret key',
                    icon: Icons.key_rounded,
                    obscure: _obscureToken,
                    onToggle: () =>
                        setState(() => _obscureToken = !_obscureToken),
                  ),
                  const SizedBox(height: 16),

                  // Test connection
                  _TestConnectionButton(
                    state: _testState,
                    message: _testMessage,
                    onTap: _testConnection,
                  ),

                  // API contract info
                  const SizedBox(height: 16),
                  _ApiContractCard(),
                ].animate().fadeIn(duration: 300.ms),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Section 2: Direct Provider (fallback) ────────────────────────
          _SectionLabel(
            icon: Icons.auto_awesome_rounded,
            label: 'DIRECT PROVIDER (FALLBACK)',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            'Used only when backend is disabled.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              // Dim fallback section when backend is enabled
            ),
            child: Opacity(
              opacity: _useCustomBackend ? 0.45 : 1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider selector
                  ...AppConstants.supportedProviders.map((provider) {
                    final info = _providerInfo(provider);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: _useCustomBackend
                            ? null
                            : () => setState(() => _selectedProvider = provider),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _selectedProvider == provider
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedProvider == provider
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                              width: _selectedProvider == provider ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(info['emoji']!,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(info['name']!,
                                        style: AppTextStyles.titleMedium),
                                    Text(info['desc']!,
                                        style: AppTextStyles.bodySmall),
                                  ],
                                ),
                              ),
                              if (_selectedProvider == provider)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  _buildSecretField(
                    controller: _apiKeyController,
                    label: 'API Key',
                    hint: 'Paste your provider API key',
                    icon: Icons.key_rounded,
                    obscure: _obscureKey,
                    onToggle: () =>
                        setState(() => _obscureKey = !_obscureKey),
                    enabled: !_useCustomBackend,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          GradientButton(
            label: _saved ? '✓ Saved!' : 'Save Settings',
            onPressed: _isLoading ? null : _save,
            isLoading: _isLoading,
            gradientColors: _saved
                ? [AppColors.positive, const Color(0xFF00A862)]
                : null,
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildSecretField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool obscure,
    required VoidCallback onToggle,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      style: AppTextStyles.bodyMedium
          .copyWith(fontFamily: 'monospace', fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 18,
          ),
        ),
      ),
    );
  }

  Map<String, String> _providerInfo(String provider) {
    switch (provider) {
      case 'gemini':
        return {'emoji': '🤖', 'name': 'Google Gemini', 'desc': 'Gemini Flash / Pro'};
      case 'openai':
        return {'emoji': '⚡', 'name': 'OpenAI', 'desc': 'GPT-4o-mini recommended'};
      case 'claude':
        return {'emoji': '🧠', 'name': 'Anthropic Claude', 'desc': 'Claude Haiku / Sonnet'};
      case 'openrouter':
        return {'emoji': '🔀', 'name': 'OpenRouter', 'desc': 'Access 100+ models'};
      default:
        return {'emoji': '🤖', 'name': provider, 'desc': ''};
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }
}

enum _TestState { idle, loading, ok, fail }

class _TestConnectionButton extends StatelessWidget {
  final _TestState state;
  final String? message;
  final VoidCallback onTap;
  const _TestConnectionButton(
      {required this.state, required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.cardBorder;
    Color bgColor = AppColors.surfaceElevated;
    Color labelColor = AppColors.textSecondary;
    IconData icon = Icons.wifi_find_rounded;
    String label = 'Test Connection';

    if (state == _TestState.loading) {
      label = 'Connecting…';
    } else if (state == _TestState.ok) {
      borderColor = AppColors.positive.withValues(alpha: 0.6);
      bgColor = AppColors.positive.withValues(alpha: 0.08);
      labelColor = AppColors.positive;
      icon = Icons.check_circle_rounded;
      label = message ?? 'Connected';
    } else if (state == _TestState.fail) {
      borderColor = AppColors.negative.withValues(alpha: 0.5);
      bgColor = AppColors.negative.withValues(alpha: 0.08);
      labelColor = AppColors.negative;
      icon = Icons.error_outline_rounded;
      label = message ?? 'Connection failed';
    }

    return GestureDetector(
      onTap: state == _TestState.loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state == _TestState.loading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2),
              )
            else
              Icon(icon, size: 16, color: labelColor),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.titleMedium.copyWith(color: labelColor)),
          ],
        ),
      ),
    );
  }
}

class _ApiContractCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code_rounded, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text('Expected API contract',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          // Request
          Text('POST  →  your URL',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          _CodeBlock(
            '{\n'
            '  "session_id": "...",\n'
            '  "message": "I had 2 eggs",\n'
            '  "history": [...],\n'
            '  "user_context": {\n'
            '    "daily_budget": 1850,\n'
            '    "consumed_today": 320,\n'
            '    "bank_balance": 2100\n'
            '  }\n'
            '}',
          ),
          const SizedBox(height: 10),
          Text('Response  ←  your server',
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          _CodeBlock(
            '{\n'
            '  "message": "Logged! 2 eggs = 180 kcal",\n'
            '  "action": "food_log",\n'
            '  "data": { ... }\n'
            '}',
          ),
          const SizedBox(height: 8),
          Text(
            'action can be: food_log · exercise_log · bank_withdraw · clarify · none',
            style: AppTextStyles.labelSmall
                .copyWith(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  final String code;
  const _CodeBlock(this.code);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: Color(0xFF7FDBCA),
          height: 1.6,
        ),
      ),
    );
  }
}
