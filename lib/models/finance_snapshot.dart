class SmartAlert {
  const SmartAlert({
    required this.message,
    required this.type,
  });

  final String message;
  final AlertType type;
}

enum AlertType { warning, success, info }

class CategorySpend {
  const CategorySpend({
    required this.category,
    required this.amount,
  });

  final String category;
  final double amount;
}

class FinanceSnapshot {
  const FinanceSnapshot({
    required this.remainingBalance,
    required this.monthlySpent,
    required this.monthlyReceived,
    required this.estimatedSavings,
    required this.daysUntilSalary,
    required this.todaySpent,
    required this.todayByCategory,
    required this.monthlyByCategory,
    required this.alerts,
    required this.balanceAdjustment,
  });

  final double remainingBalance;
  final double monthlySpent;
  final double monthlyReceived;
  final double estimatedSavings;
  final int daysUntilSalary;
  final double todaySpent;
  final List<CategorySpend> todayByCategory;
  final List<CategorySpend> monthlyByCategory;
  final List<SmartAlert> alerts;
  final double balanceAdjustment;
}
