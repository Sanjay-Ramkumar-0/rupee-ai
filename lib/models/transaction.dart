class Transaction {
  const Transaction({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.category,
    required this.timestamp,
    this.paymentType = 'UPI',
    this.included = true,
    this.isIncome = false,
    this.notes,
    this.source,
  });

  final String id;
  final double amount;
  final String merchant;
  final String category;
  final DateTime timestamp;
  final String paymentType;
  final bool included;
  /// Money received (credit) vs spent (debit).
  final bool isIncome;
  final String? notes;
  final String? source;

  bool get isExpense => !isIncome;

  Transaction copyWith({
    String? id,
    String? category,
    bool? included,
    bool? isIncome,
    String? notes,
    String? paymentType,
    String? merchant,
    double? amount,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      timestamp: timestamp,
      paymentType: paymentType ?? this.paymentType,
      included: included ?? this.included,
      isIncome: isIncome ?? this.isIncome,
      notes: notes ?? this.notes,
      source: source ?? this.source,
    );
  }
}
