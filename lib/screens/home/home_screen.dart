import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../models/user_profile.dart';
import '../../providers/bank_provider.dart';
import '../../providers/food_db_provider.dart';
import '../../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  UserProfile? _userProfile;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      setState(() {
        _userProfile = UserProfile.fromJsonString(profileJson);
        _userName = _userProfile!.name;
      });
    }
  }

  void _showWithdrawalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WithdrawalSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildDashboard(), _buildBankScreen()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Bank'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile).then((_) {
                _loadUserData();
              });
            },
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: _userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _showWithdrawalSheet,
        backgroundColor: AppTheme.primaryGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.account_balance_wallet,
                color: _currentIndex == 0 ? AppTheme.primaryGreen : AppTheme.mediumGray,
                size: 32,
              ),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            const SizedBox(width: 48), // Space for FAB
            IconButton(
              icon: Icon(
                Icons.account_balance,
                color: _currentIndex == 1 ? AppTheme.primaryGreen : AppTheme.mediumGray,
                size: 32,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Consumer<BankProvider>(
      builder: (context, bankProvider, child) {
        final dailyBudget = _userProfile!.dailyCalorieTarget.toInt();
        final expensesToday = bankProvider.todayExpenses;
        final availableBalance = dailyBudget - expensesToday;
        final transactions = bankProvider.todayTransactions;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $_userName',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // Neon Bank Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.neonGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DAILY CALORIE ACCOUNT',
                          style: TextStyle(color: Colors.white70, letterSpacing: 1.5, fontSize: 12),
                        ),
                        const Icon(Icons.nfc, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Available Balance',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      '$availableBalance cal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daily Budget', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('$dailyBudget', style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Expenses Today', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('$expensesToday', style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              if (transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryGreen.withValues(alpha: 0.2)),
                  ),
                  child: const Text('No transactions today. Enjoy your budget!'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: tx.isExpense ? AppTheme.errorRed.withValues(alpha: 0.1) : AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            tx.isExpense ? Icons.restaurant : Icons.savings,
                            color: tx.isExpense ? AppTheme.errorRed : AppTheme.primaryGreen,
                          ),
                        ),
                        title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${tx.timestamp.hour.toString().padLeft(2, '0')}:${tx.timestamp.minute.toString().padLeft(2, '0')}'),
                        trailing: Text(
                          '${tx.isExpense ? '-' : '+'}${tx.amount} cal',
                          style: TextStyle(
                            color: tx.isExpense ? AppTheme.errorRed : AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBankScreen() {
    return Consumer<BankProvider>(
      builder: (context, bankProvider, child) {
        final vaultBalance = bankProvider.vaultBalance;
        String saverLevel = 'Bronze Saver';
        Color levelColor = const Color(0xFFCD7F32);
        if (vaultBalance > 10000) {
          saverLevel = 'Gold Saver';
          levelColor = const Color(0xFFFFD700);
        } else if (vaultBalance > 5000) {
          saverLevel = 'Silver Saver';
          levelColor = const Color(0xFFC0C0C0);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.account_balance, size: 64, color: AppTheme.primaryBlue),
              const SizedBox(height: 16),
              const Text('The Vault', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Your accumulated calorie deficit', style: TextStyle(color: AppTheme.mediumGray)),
              const SizedBox(height: 32),
              
              // Big Balance Neon
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryGreen, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '$vaultBalance',
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                    const Text('CREDITS', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: levelColor, width: 2),
                ),
                child: Text(
                  saverLevel,
                  style: TextStyle(fontWeight: FontWeight.bold, color: levelColor, fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 48),
              
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Rewards Store', style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: 16),
              
              _buildRewardItem(context, bankProvider, 'Small Treat', 'Enjoy a guilt-free snack!', 500, Icons.cookie),
              _buildRewardItem(context, bankProvider, 'Cheat Meal', 'Go all out on a meal!', 2000, Icons.local_pizza),
              _buildRewardItem(context, bankProvider, 'Rest Day', 'Skip the gym today!', 1000, Icons.weekend),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardItem(BuildContext context, BankProvider provider, String title, String subtitle, int cost, IconData icon) {
    final canAfford = provider.vaultBalance >= cost;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: canAfford ? AppTheme.primaryGreen.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: ListTile(
        leading: Icon(icon, size: 40, color: canAfford ? AppTheme.primaryGreen : AppTheme.mediumGray),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canAfford ? AppTheme.primaryGreen : AppTheme.mediumGray.withValues(alpha: 0.2),
            foregroundColor: Colors.white,
            elevation: canAfford ? 2 : 0,
          ),
          onPressed: canAfford ? () async {
            final success = await provider.spendCredits(title, cost);
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Purchased $title! Enjoy!'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            }
          } : null,
          child: Text('$cost CR', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class WithdrawalSheet extends StatefulWidget {
  const WithdrawalSheet({super.key});

  @override
  State<WithdrawalSheet> createState() => _WithdrawalSheetState();
}

class _WithdrawalSheetState extends State<WithdrawalSheet> {
  final _inputController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AIService _aiService;
  
  bool _isLoading = true;
  String _apiKey = '';

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hi! I'm your AI nutritionist. What did you eat today?",
      isUser: false,
    )
  ];
  
  bool _isProcessing = false;
  bool _isManual = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('gemini_api_key') ?? '';
    if (mounted) {
      setState(() {
        _apiKey = key;
        if (key.isNotEmpty) {
          _aiService = AIService(apiKey: key);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
    if (mounted) {
      setState(() {
        _apiKey = key;
        _aiService = AIService(apiKey: key);
      });
    }
  }

  void _launchGoogleAIStudio() async {
    final url = Uri.parse('https://aistudio.google.com/app/apikey');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open browser.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _apiKeyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isProcessing = true;
    });
    
    // Auto-scroll after adding user message
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    final aiResponse = await _aiService.sendMessage(text);

    if (!mounted) return;

    // Try intercepting structured JSON output
    try {
      // Sometimes models wrap JSON in markdown block: ```json ... ```
      final cleanJson = aiResponse.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> data = jsonDecode(cleanJson);
      
      if (data['status'] == 'CONFIRMED') {
        final title = data['title'] ?? 'Meal';
        final calories = (data['calories'] as num).toInt();
        
        Provider.of<BankProvider>(context, listen: false).addExpense(title, calories);
        Navigator.pop(context); // Close sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Awesome! Logged $title ($calories cal)'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        return;
      }
    } catch (e) {
      // Normal text response (Not JSON) - just continue and display it
    }

    setState(() {
      _messages.add(ChatMessage(text: aiResponse, isUser: false));
      _isProcessing = false;
    });
    
    // Auto-scroll after adding AI message
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _showConfirmationDialog(String title, int amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? AppTheme.darkGray,
        title: const Text('Confirm Expense'),
        content: Text('Log "$title" for $amount calories?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
            onPressed: () {
              Provider.of<BankProvider>(context, listen: false).addExpense(title, amount);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Expense logged: $amount cal'), backgroundColor: AppTheme.primaryGreen),
              );
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      padding: EdgeInsets.only(bottom: bottomPadding, left: 16, right: 16, top: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppTheme.mediumGray, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          
          if (_apiKey.isEmpty) ...[
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.vpn_key, size: 64, color: AppTheme.primaryGreen),
                      const SizedBox(height: 16),
                      const Text('Setup AI Nutritionist', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Text(
                        'To use the AI chat, please provide a free Gemini API Key from Google AI Studio.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.mediumGray),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Get Free API Key'),
                        onPressed: _launchGoogleAIStudio,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          hintText: 'Paste your API Key here...',
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _saveApiKey,
                          child: const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isManual ? 'Manual Food Database' : 'AI Assistant',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => _isManual = !_isManual),
                child: Text(
                  _isManual ? 'Use Chat' : 'Search Database',
                  style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const Divider(),
          
          if (!_isManual) ...[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg.isUser;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: 12,
                        left: isMe ? 60 : 0,
                        right: isMe ? 0 : 60,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? AppTheme.primaryGreen : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16).copyWith(
                          bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
                          bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: isMe ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isProcessing)
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: AppTheme.primaryGreen, strokeWidth: 2),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Type your meal here...',
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isProcessing ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ] else ...[
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search food database...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGreen),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer<FoodDbProvider>(
                builder: (context, db, child) {
                  final results = db.searchFoods(_searchQuery);
                  if (results.isEmpty) {
                    return const Center(child: Text('No foods found.'));
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final item = results[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('${item.servingSize} • ${item.caloriesPerServing} cal'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: AppTheme.primaryGreen),
                          onPressed: () => _showConfirmationDialog(item.name, item.caloriesPerServing),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ], // Closes the else ...[ from _apiKey.isEmpty
        const SizedBox(height: 16),
      ], // Closes the Column children
      ),
    );
  }
}
