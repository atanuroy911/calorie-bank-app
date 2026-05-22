import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/user_profile.dart';

class BankProvider with ChangeNotifier {
  List<CalorieTransaction> _transactions = [];
  int _vaultBalance = 0;
  DateTime _currentDate = DateTime.now();

  List<CalorieTransaction> get todayTransactions {
    return _transactions.where((t) {
      return t.timestamp.year == _currentDate.year &&
          t.timestamp.month == _currentDate.month &&
          t.timestamp.day == _currentDate.day;
    }).toList();
  }

  int get vaultBalance => _vaultBalance;

  // Expenses are food logs, Deposits could be exercises (though optional)
  int get todayExpenses {
    return todayTransactions
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  BankProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _vaultBalance = prefs.getInt('vault_balance') ?? 0;
    
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final List<dynamic> decoded = jsonDecode(transactionsJson);
      _transactions = decoded.map((json) => CalorieTransaction.fromJson(json)).toList();
    }
    
    final lastDateStr = prefs.getString('last_date');
    if (lastDateStr != null) {
      final lastDate = DateTime.parse(lastDateStr);
      final now = DateTime.now();
      
      // If we are on a new day, we need to process the previous day's deficit
      if (lastDate.year != now.year || lastDate.month != now.month || lastDate.day != now.day) {
        _processEndOfDay(lastDate);
      }
    } else {
      prefs.setString('last_date', DateTime.now().toIso8601String());
    }
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vault_balance', _vaultBalance);
    
    final transactionsJson = jsonEncode(_transactions.map((t) => t.toJson()).toList());
    await prefs.setString('transactions', transactionsJson);
    await prefs.setString('last_date', _currentDate.toIso8601String());
  }

  Future<void> _processEndOfDay(DateTime lastDate) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    
    if (profileJson != null) {
      final profile = UserProfile.fromJsonString(profileJson);
      final dailyTarget = profile.dailyCalorieTarget.toInt();
      
      // Find expenses for the lastDate
      final lastDateExpenses = _transactions.where((t) {
        return t.timestamp.year == lastDate.year &&
            t.timestamp.month == lastDate.month &&
            t.timestamp.day == lastDate.day &&
            t.isExpense;
      }).fold(0, (sum, t) => sum + t.amount);
      
      // Calculate deficit
      final deficit = dailyTarget - lastDateExpenses;
      
      if (deficit > 0) {
        _vaultBalance += deficit; // Deposit to vault!
        
        // Log a transaction for the deposit
        _transactions.add(CalorieTransaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Daily Deficit Deposit',
          amount: deficit,
          timestamp: lastDate, // Log it for the end of the previous day
          isExpense: false,
        ));
      }
    }
    
    _currentDate = DateTime.now();
    await _saveData();
    notifyListeners();
  }

  Future<void> addExpense(String title, int amount) async {
    final transaction = CalorieTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      timestamp: DateTime.now(),
      isExpense: true,
    );
    _transactions.insert(0, transaction); // Add to top
    await _saveData();
    notifyListeners();
  }

  Future<bool> spendCredits(String title, int amount) async {
    if (_vaultBalance >= amount) {
      _vaultBalance -= amount;
      
      final transaction = CalorieTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount, // The amount spent
        timestamp: DateTime.now(),
        isExpense: false, // It's spending from vault, not a calorie expense
      );
      
      _transactions.insert(0, transaction);
      await _saveData();
      notifyListeners();
      return true;
    }
    return false;
  }
}
