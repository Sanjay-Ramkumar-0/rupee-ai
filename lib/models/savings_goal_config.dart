class SavingsGoal {
  const SavingsGoal({
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.monthlyTarget,
  });

  final String name;
  final double targetAmount;
  final double savedAmount;
  final double monthlyTarget;

  double get progress =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0;

  SavingsGoal copyWith({
    String? name,
    double? targetAmount,
    double? savedAmount,
    double? monthlyTarget,
  }) {
    return SavingsGoal(
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'targetAmount': targetAmount,
        'savedAmount': savedAmount,
        'monthlyTarget': monthlyTarget,
      };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      name: json['name'] as String? ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0,
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
      monthlyTarget: (json['monthlyTarget'] as num?)?.toDouble() ?? 0,
    );
  }
}
