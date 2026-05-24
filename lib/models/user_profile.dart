import 'savings_goal_config.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.monthlyIncome,
    required this.salaryDay,
    this.customCategories = const [],
    this.budgetLimits = const {},
    this.savingsGoals = const [],
    this.balanceAdjustment = 0,
    this.languageCode = 'en',
    this.darkMode = false,
    this.setupComplete = false,
  });

  final String name;
  final double monthlyIncome;
  final int salaryDay;
  final List<String> customCategories;
  final Map<String, double> budgetLimits;
  final List<SavingsGoal> savingsGoals;
  /// Manual tweak so displayed balance matches wallet without changing salary.
  final double balanceAdjustment;
  final String languageCode;
  final bool darkMode;
  final bool setupComplete;

  UserProfile copyWith({
    String? name,
    double? monthlyIncome,
    int? salaryDay,
    List<String>? customCategories,
    Map<String, double>? budgetLimits,
    List<SavingsGoal>? savingsGoals,
    double? balanceAdjustment,
    String? languageCode,
    bool? darkMode,
    bool? setupComplete,
  }) {
    return UserProfile(
      name: name ?? this.name,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      salaryDay: salaryDay ?? this.salaryDay,
      customCategories: customCategories ?? this.customCategories,
      budgetLimits: budgetLimits ?? this.budgetLimits,
      savingsGoals: savingsGoals ?? this.savingsGoals,
      balanceAdjustment: balanceAdjustment ?? this.balanceAdjustment,
      languageCode: languageCode ?? this.languageCode,
      darkMode: darkMode ?? this.darkMode,
      setupComplete: setupComplete ?? this.setupComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'monthlyIncome': monthlyIncome,
        'salaryDay': salaryDay,
        'customCategories': customCategories,
        'budgetLimits': budgetLimits,
        'savingsGoals': savingsGoals.map((g) => g.toJson()).toList(),
        'balanceAdjustment': balanceAdjustment,
        'languageCode': languageCode,
        'darkMode': darkMode,
        'setupComplete': setupComplete,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final limitsRaw = json['budgetLimits'] as Map<String, dynamic>?;
    final budgetLimits = <String, double>{};
    if (limitsRaw != null) {
      limitsRaw.forEach((k, v) {
        budgetLimits[k] = (v as num).toDouble();
      });
    }

    final goalsRaw = json['savingsGoals'] as List<dynamic>?;
    final savingsGoals = goalsRaw
            ?.map((e) => SavingsGoal.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return UserProfile(
      name: json['name'] as String? ?? 'Friend',
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0,
      salaryDay: json['salaryDay'] as int? ?? 1,
      customCategories: (json['customCategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      budgetLimits: budgetLimits,
      savingsGoals: savingsGoals,
      balanceAdjustment: (json['balanceAdjustment'] as num?)?.toDouble() ?? 0,
      languageCode: json['languageCode'] as String? ?? 'en',
      darkMode: json['darkMode'] as bool? ?? false,
      setupComplete: json['setupComplete'] as bool? ?? false,
    );
  }
}
