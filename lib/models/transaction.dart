class CalorieTransaction {
  final String id;
  final String title;
  final int amount;
  final DateTime timestamp;
  final bool isExpense; // true if food (expense), false if exercise/reward (deposit/spending)

  CalorieTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.timestamp,
    this.isExpense = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'isExpense': isExpense,
    };
  }

  factory CalorieTransaction.fromJson(Map<String, dynamic> json) {
    return CalorieTransaction(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: json['amount'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isExpense: json['isExpense'] as bool? ?? true,
    );
  }
}
