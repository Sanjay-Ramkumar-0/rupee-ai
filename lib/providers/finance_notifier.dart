import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/categories.dart';
import '../models/budget.dart';
import '../models/finance_snapshot.dart';
import '../models/transaction.dart';
import '../models/transaction_mapper.dart';
import '../models/user_profile.dart';
import '../services/insights_analyzer.dart';
import '../services/isar_service.dart';

const _profileKey = 'rupee_user_profile';

final financeProvider =
    NotifierProvider<FinanceNotifier, FinanceState>(FinanceNotifier.new);

class FinanceState {
  const FinanceState({
    required this.profile,
    required this.transactions,
    required this.budgets,
    required this.savingsGoals,
    required this.merchantRules,
    this.pendingCategorization,
    this.isLoading = false,
  });

  final UserProfile profile;
  final List<Transaction> transactions;
  final List<Budget> budgets;
  final List<SavingsGoal> savingsGoals;
  final Map<String, String> merchantRules;
  final Transaction? pendingCategorization;
  final bool isLoading;

  List<Transaction> get includedTransactions => transactions
      .where((t) => t.included && t.category != 'Do Not Include')
      .toList();

  List<Transaction> get expenseTransactions =>
      includedTransactions.where((t) => !t.isIncome).toList();

  /// All tracked payments for history (spending + received).
  List<Transaction> get historyTransactions => includedTransactions;

  List<Transaction> get excludedTransactions => transactions
      .where((t) => !t.included || t.category == 'Do Not Include')
      .toList();

  List<String> get allCategories => [
        ...defaultExpenseCategories.where((c) => c != 'Do Not Include'),
        ...profile.customCategories,
      ];

  FinanceState copyWith({
    UserProfile? profile,
    List<Transaction>? transactions,
    List<Budget>? budgets,
    List<SavingsGoal>? savingsGoals,
    Map<String, String>? merchantRules,
    Transaction? pendingCategorization,
    bool? isLoading,
    bool clearPending = false,
  }) {
    return FinanceState(
      profile: profile ?? this.profile,
      transactions: transactions ?? this.transactions,
      budgets: budgets ?? this.budgets,
      savingsGoals: savingsGoals ?? this.savingsGoals,
      merchantRules: merchantRules ?? this.merchantRules,
      pendingCategorization:
          clearPending ? null : (pendingCategorization ?? this.pendingCategorization),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FinanceNotifier extends Notifier<FinanceState> {
  IsarService get _db => IsarService.instance;

  @override
  FinanceState build() {
    Future.microtask(_bootstrap);
    return _emptyState();
  }

  FinanceState _emptyState() {
    return const FinanceState(
      profile: UserProfile(
        name: 'Friend',
        monthlyIncome: 0,
        salaryDay: 1,
        setupComplete: false,
      ),
      transactions: [],
      budgets: [],
      savingsGoals: [],
      merchantRules: {},
      isLoading: true,
    );
  }

  Future<void> _bootstrap() async {
    final profile = await _loadProfile();
    final transactions = await _loadTransactionsFromDb();
    _applyData(profile: profile, transactions: transactions, isLoading: false);
  }

  void _applyData({
    required UserProfile profile,
    required List<Transaction> transactions,
    bool isLoading = false,
  }) {
    state = state.copyWith(
      profile: profile,
      transactions: transactions,
      budgets: _budgetsFrom(transactions, profile.budgetLimits),
      savingsGoals: profile.savingsGoals,
      isLoading: isLoading,
    );
  }

  Future<UserProfile> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return state.profile;
    return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<List<Transaction>> _loadTransactionsFromDb() async {
    final models = await _db.getTransactions();
    return TransactionMapper.toDomainList(models);
  }

  Future<Transaction> _persist(Transaction transaction) async {
    final model = TransactionMapper.toModel(transaction);
    final id = await _db.saveTransaction(model);
    return transaction.copyWith(id: id.toString());
  }

  Future<void> _replaceTransactions(List<Transaction> transactions) async {
    state = state.copyWith(
      transactions: transactions,
      budgets: _budgetsFrom(transactions, state.profile.budgetLimits),
    );
  }

  List<Budget> _budgetsFrom(
    List<Transaction> transactions,
    Map<String, double> limits,
  ) {
    if (limits.isEmpty) return [];

    final now = DateTime.now();
    final spentByCategory = <String, double>{};
    for (final t in transactions) {
      if (!t.included || t.category == 'Do Not Include' || t.isIncome) continue;
      if (t.timestamp.month == now.month && t.timestamp.year == now.year) {
        spentByCategory[t.category] =
            (spentByCategory[t.category] ?? 0) + t.amount;
      }
    }

    return limits.entries
        .map(
          (e) => Budget(
            category: e.key,
            limit: e.value,
            spent: spentByCategory[e.key] ?? 0,
          ),
        )
        .toList()
      ..sort((a, b) => a.category.compareTo(b.category));
  }

  Future<void> _persistProfile(UserProfile profile) async {
    await _saveProfile(profile);
    state = state.copyWith(
      profile: profile,
      budgets: _budgetsFrom(state.transactions, profile.budgetLimits),
      savingsGoals: profile.savingsGoals,
    );
  }

  Future<void> completeSetup({
    required String name,
    required double monthlyIncome,
    required int salaryDay,
  }) async {
    await updateProfile(
      name: name,
      monthlyIncome: monthlyIncome,
      salaryDay: salaryDay,
      setupComplete: true,
    );
  }

  Future<void> updateProfile({
    required String name,
    required double monthlyIncome,
    required int salaryDay,
    bool? setupComplete,
  }) async {
    final updated = state.profile.copyWith(
      name: name,
      monthlyIncome: monthlyIncome,
      salaryDay: salaryDay,
      setupComplete: setupComplete ?? state.profile.setupComplete,
    );
    await _persistProfile(updated);
  }

  Future<void> setBudgetLimit(String category, double limit) async {
    final limits = Map<String, double>.from(state.profile.budgetLimits);
    limits[category] = limit;
    await _persistProfile(state.profile.copyWith(budgetLimits: limits));
  }

  Future<void> removeBudget(String category) async {
    final limits = Map<String, double>.from(state.profile.budgetLimits)
      ..remove(category);
    await _persistProfile(state.profile.copyWith(budgetLimits: limits));
  }

  Future<void> upsertSavingsGoal(SavingsGoal goal) async {
    final goals = [...state.profile.savingsGoals];
    final index = goals.indexWhere((g) => g.name == goal.name);
    if (index >= 0) {
      goals[index] = goal;
    } else {
      goals.add(goal);
    }
    await _persistProfile(state.profile.copyWith(savingsGoals: goals));
  }

  Future<void> removeSavingsGoal(String name) async {
    final goals =
        state.profile.savingsGoals.where((g) => g.name != name).toList();
    await _persistProfile(state.profile.copyWith(savingsGoals: goals));
  }

  void addCustomCategory(String name) {
    if (state.profile.customCategories.contains(name)) return;
    final updated = state.profile.copyWith(
      customCategories: [...state.profile.customCategories, name],
    );
    _saveProfile(updated);
    state = state.copyWith(profile: updated);
  }

  Future<void> removeCustomCategory(String name) async {
    if (!state.profile.customCategories.contains(name)) return;

    final updatedProfile = state.profile.copyWith(
      customCategories:
          state.profile.customCategories.where((c) => c != name).toList(),
    );
    await _saveProfile(updatedProfile);

    final transactions = <Transaction>[];
    for (final t in state.transactions) {
      if (t.category == name) {
        transactions.add(await _persist(t.copyWith(category: 'Others')));
      } else {
        transactions.add(t);
      }
    }

    state = state.copyWith(profile: updatedProfile);
    await _replaceTransactions(transactions);
  }

  Future<void> categorizeTransaction(String transactionId, String category) async {
    final included = category != 'Do Not Include';
    Transaction updated;

    if (transactionId.startsWith('pending_')) {
      final pending = state.pendingCategorization;
      if (pending == null || pending.id != transactionId) return;
      updated = pending.copyWith(category: category, included: included);
    } else {
      final index =
          state.transactions.indexWhere((t) => t.id == transactionId);
      if (index < 0) return;
      updated = state.transactions[index]
          .copyWith(category: category, included: included);
    }

    final saved = await _persist(updated);
    final rules = Map<String, String>.from(state.merchantRules);
    if (category != 'Do Not Include' && category != 'Others') {
      rules[updated.merchant.split(' ').first] = category;
    }

    final transactions = transactionId.startsWith('pending_')
        ? [saved, ...state.transactions]
        : state.transactions
            .map((t) => t.id == transactionId ? saved : t)
            .toList();

    await _replaceTransactions(transactions);
    state = state.copyWith(merchantRules: rules, clearPending: true);
  }

  Future<void> handleNotificationTransaction(Transaction txn) async {
    if (_isDuplicate(txn)) return;

    if (!txn.isIncome && txn.category.isEmpty) {
      state = state.copyWith(pendingCategorization: txn);
      return;
    }

    final toSave = txn.isIncome
        ? txn.copyWith(category: receivedCategory)
        : txn;
    final saved = await _persist(toSave);
    await _replaceTransactions([saved, ...state.transactions]);
  }

  bool _isDuplicate(Transaction txn) {
    return state.transactions.any((t) {
      return t.amount == txn.amount &&
          t.merchant == txn.merchant &&
          t.isIncome == txn.isIncome &&
          t.timestamp.difference(txn.timestamp).inMinutes.abs() < 3;
    });
  }

  Future<void> setRemainingBalance(double targetRemaining) async {
    final base = computedRemainingWithoutAdjustment();
    final adjustment = targetRemaining - base;
    await _persistProfile(
      state.profile.copyWith(balanceAdjustment: adjustment),
    );
  }

  double computedRemainingWithoutAdjustment() {
    final now = DateTime.now();
    final totals = _totalsForMonth(state.includedTransactions, now);
    return state.profile.monthlyIncome -
        totals.expenses +
        totals.received;
  }

  Future<void> updateTransactionNotes(String transactionId, String notes) async {
    final index = state.transactions.indexWhere((t) => t.id == transactionId);
    if (index < 0) return;
    final updated =
        state.transactions[index].copyWith(notes: notes.trim().isEmpty ? null : notes.trim());
    final saved = await _persist(updated);
    final list = [...state.transactions];
    list[index] = saved;
    await _replaceTransactions(list);
  }

  Future<void> deleteSelectedTransactions(Set<String> ids) async {
    await _deleteByIds(ids.toList());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _deleteByIds([transactionId]);
  }

  Future<void> deleteTransactionsInLastDays(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final ids = state.transactions
        .where((t) => !t.timestamp.isBefore(cutoff))
        .map((t) => t.id)
        .toList();
    await _deleteByIds(ids);
  }

  Future<void> deleteTransactionsByCategory(String category) async {
    final ids = state.transactions
        .where((t) => t.category == category)
        .map((t) => t.id)
        .toList();
    await _deleteByIds(ids);
  }

  Future<void> deleteLastTransactions(int count) async {
    final sorted = [...state.transactions]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final ids = sorted.take(count).map((t) => t.id).toList();
    await _deleteByIds(ids);
  }

  Future<void> deleteAllTransactions() async {
    await _db.deleteAllTransactions();
    await _replaceTransactions([]);
  }

  Future<void> _deleteByIds(List<String> ids) async {
    if (ids.isEmpty) return;
    final isarIds = ids.map(int.tryParse).whereType<int>().toList();
    await _db.deleteTransactions(isarIds);
    final idSet = ids.toSet();
    final remaining =
        state.transactions.where((t) => !idSet.contains(t.id)).toList();
    await _replaceTransactions(remaining);
  }

  Future<void> addManualTransaction({
    required double amount,
    required String category,
    required bool isIncome,
    String merchant = 'Cash expense',
  }) async {
    final txn = Transaction(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      merchant: isIncome ? (merchant == 'Cash expense' ? 'Cash received' : merchant) : merchant,
      category: isIncome ? receivedCategory : category,
      timestamp: DateTime.now(),
      paymentType: isIncome ? 'Received' : 'Cash',
      isIncome: isIncome,
    );
    final saved = await _persist(txn);
    await _replaceTransactions([saved, ...state.transactions]);
  }

  FinanceSnapshot computeSnapshot() {
    final profile = state.profile;
    final included = state.includedTransactions;
    final today = DateTime.now();
    final monthTotals = _totalsForMonth(included, today);
    final remaining = profile.monthlyIncome -
        monthTotals.expenses +
        monthTotals.received +
        profile.balanceAdjustment;
    final estimatedSavings = remaining > 0 ? remaining * 0.32 : 0.0;

    final todayTotals = _totalsForDay(included, today);
    final todayMap = _categoryMapForDay(included, today, expensesOnly: true);

    final monthMap = <String, double>{};
    for (final t in included) {
      if (t.isIncome) continue;
      if (t.timestamp.month == today.month && t.timestamp.year == today.year) {
        monthMap[t.category] = (monthMap[t.category] ?? 0) + t.amount;
      }
    }

    return FinanceSnapshot(
      remainingBalance: remaining,
      monthlySpent: monthTotals.expenses,
      monthlyReceived: monthTotals.received,
      estimatedSavings: estimatedSavings,
      daysUntilSalary: _daysUntilSalary(profile.salaryDay),
      todaySpent: todayTotals.expenses,
      todayByCategory: todayMap,
      monthlyByCategory: monthMap.entries
          .map((e) => CategorySpend(category: e.key, amount: e.value))
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount)),
      alerts: _alertsFrom(state.budgets, included.isEmpty),
      balanceAdjustment: profile.balanceAdjustment,
    );
  }

  ({double expenses, double received}) _totalsForMonth(
    List<Transaction> txns,
    DateTime now,
  ) {
    var expenses = 0.0;
    var received = 0.0;
    for (final t in txns) {
      if (t.timestamp.month != now.month || t.timestamp.year != now.year) {
        continue;
      }
      if (t.isIncome) {
        received += t.amount;
      } else {
        expenses += t.amount;
      }
    }
    return (expenses: expenses, received: received);
  }

  ({double expenses, double received}) _totalsForDay(
    List<Transaction> txns,
    DateTime day,
  ) {
    var expenses = 0.0;
    var received = 0.0;
    for (final t in txns) {
      if (t.timestamp.year != day.year ||
          t.timestamp.month != day.month ||
          t.timestamp.day != day.day) {
        continue;
      }
      if (t.isIncome) {
        received += t.amount;
      } else {
        expenses += t.amount;
      }
    }
    return (expenses: expenses, received: received);
  }

  List<CategorySpend> _categoryMapForDay(
    List<Transaction> txns,
    DateTime day, {
    required bool expensesOnly,
  }) {
    final map = <String, double>{};
    for (final t in txns) {
      if (expensesOnly && t.isIncome) continue;
      if (t.timestamp.year != day.year ||
          t.timestamp.month != day.month ||
          t.timestamp.day != day.day) {
        continue;
      }
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map.entries
        .map((e) => CategorySpend(category: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  List<SmartAlert> _alertsFrom(List<Budget> budgets, bool noTransactions) {
    if (noTransactions) {
      return const [
        SmartAlert(
          message: 'No expenses tracked yet this month',
          type: AlertType.info,
        ),
      ];
    }
    if (budgets.isEmpty) {
      return const [
        SmartAlert(
          message: 'Add budgets in the Budget tab to get spending alerts',
          type: AlertType.info,
        ),
      ];
    }
    final alerts = <SmartAlert>[];
    for (final b in budgets) {
      if (b.status == BudgetStatus.exceeded) {
        alerts.add(SmartAlert(
          message: '${b.category} budget exceeded',
          type: AlertType.warning,
        ));
      } else if (b.status == BudgetStatus.warning) {
        alerts.add(SmartAlert(
          message: '${b.category} budget almost exceeded',
          type: AlertType.warning,
        ));
      }
    }
    if (alerts.isEmpty) {
      alerts.add(const SmartAlert(
        message: 'Spending is within your budgets',
        type: AlertType.success,
      ));
    }
    return alerts;
  }

  int _daysUntilSalary(int salaryDay) {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, salaryDay);
    if (!next.isAfter(now)) {
      next = DateTime(now.year, now.month + 1, salaryDay);
    }
    return next.difference(now).inDays;
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

final financeSnapshotProvider = Provider<FinanceSnapshot>((ref) {
  ref.watch(financeProvider);
  return ref.read(financeProvider.notifier).computeSnapshot();
});

final insightsReportProvider = Provider<InsightsReport>((ref) {
  final state = ref.watch(financeProvider);
  final snapshot = ref.watch(financeSnapshotProvider);
  return InsightsAnalyzer().analyze(
    profile: state.profile,
    snapshot: snapshot,
    includedTransactions: state.includedTransactions,
    budgets: state.budgets,
  );
});
