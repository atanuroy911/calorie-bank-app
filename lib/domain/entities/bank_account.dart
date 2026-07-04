import 'package:equatable/equatable.dart';

class BankAccount extends Equatable {
  final String userId;
  final int balance; // total saved calories
  final DateTime lastUpdated;

  const BankAccount({
    required this.userId,
    required this.balance,
    required this.lastUpdated,
  });

  BankAccount copyWith({int? balance}) {
    return BankAccount(
      userId: userId,
      balance: balance ?? this.balance,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [userId, balance];
}
