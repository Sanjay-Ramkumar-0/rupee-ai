export 'savings_goal_config.dart' show SavingsGoal;

enum BudgetStatus { safe, warning, exceeded }

class Budget {
  const Budget({
    required this.category,
    required this.limit,
    required this.spent,
  });

  final String category;
  final double limit;
  final double spent;

  double get remaining => limit - spent;
  double get progress => limit > 0 ? (spent / limit).clamp(0.0, 2.0) : 0;

  BudgetStatus get status {
    if (spent > limit) return BudgetStatus.exceeded;
    if (spent >= limit * 0.8) return BudgetStatus.warning;
    return BudgetStatus.safe;
  }
}
