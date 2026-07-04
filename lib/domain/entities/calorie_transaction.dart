import 'package:equatable/equatable.dart';

enum TransactionType {
  foodWithdrawal,
  exerciseDeposit,
  bankWithdrawal,
  bankDeposit,
  dailySavingsDeposit,
  manualAdjustment,
}

extension TransactionTypeExtension on TransactionType {
  bool get isPositive {
    switch (this) {
      case TransactionType.exerciseDeposit:
      case TransactionType.bankWithdrawal: // bank→daily = adds to daily
      case TransactionType.dailySavingsDeposit:
        return true;
      case TransactionType.foodWithdrawal:
      case TransactionType.bankDeposit: // daily→bank = removes from daily
      case TransactionType.manualAdjustment:
        return false;
    }
  }

  String get label {
    switch (this) {
      case TransactionType.foodWithdrawal:
        return 'Food';
      case TransactionType.exerciseDeposit:
        return 'Exercise';
      case TransactionType.bankWithdrawal:
        return 'Bank Withdrawal';
      case TransactionType.bankDeposit:
        return 'Savings Deposit';
      case TransactionType.dailySavingsDeposit:
        return 'Daily Savings';
      case TransactionType.manualAdjustment:
        return 'Manual Adjustment';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.foodWithdrawal:
        return '🍽️';
      case TransactionType.exerciseDeposit:
        return '🏃';
      case TransactionType.bankWithdrawal:
        return '🏦';
      case TransactionType.bankDeposit:
        return '💰';
      case TransactionType.dailySavingsDeposit:
        return '📈';
      case TransactionType.manualAdjustment:
        return '✏️';
    }
  }
}

class CalorieTransaction extends Equatable {
  final String id;
  final DateTime timestamp;
  final TransactionType type;
  final int calories; // Always positive; direction derived from type
  final String label;
  final String? foodEntryId;
  final String? exerciseEntryId;
  final String userId;
  final String date; // 'YYYY-MM-DD' for daily grouping

  const CalorieTransaction({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.calories,
    required this.label,
    this.foodEntryId,
    this.exerciseEntryId,
    required this.userId,
    required this.date,
  });

  /// The signed value for daily balance calculation
  int get signedCalories {
    switch (type) {
      case TransactionType.foodWithdrawal:
        return -calories;
      case TransactionType.exerciseDeposit:
        return calories;
      case TransactionType.bankWithdrawal:
        return calories; // adds to daily balance
      case TransactionType.bankDeposit:
        return -calories; // removes from daily balance
      case TransactionType.dailySavingsDeposit:
        return 0; // bank-only, doesn't affect daily
      case TransactionType.manualAdjustment:
        return calories;
    }
  }

  /// The signed value for bank balance calculation
  int get bankSignedCalories {
    switch (type) {
      case TransactionType.bankWithdrawal:
        return -calories;
      case TransactionType.bankDeposit:
        return calories;
      case TransactionType.dailySavingsDeposit:
        return calories;
      default:
        return 0;
    }
  }

  @override
  List<Object?> get props => [id, timestamp, type, calories];
}
