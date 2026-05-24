import '../core/utils/currency_format.dart';
import '../models/budget.dart';
import '../models/finance_snapshot.dart';
import '../models/transaction.dart';
import '../models/user_profile.dart';

class BehaviorInsight {
  const BehaviorInsight({required this.title, required this.body});

  final String title;
  final String body;
}

class InsightsReport {
  const InsightsReport({
    required this.hasData,
    this.monthlySummaryLines = const [],
    this.behaviors = const [],
  });

  final bool hasData;
  final List<String> monthlySummaryLines;
  final List<BehaviorInsight> behaviors;
}

class InsightsAnalyzer {
  InsightsReport analyze({
    required UserProfile profile,
    required FinanceSnapshot snapshot,
    required List<Transaction> includedTransactions,
    required List<Budget> budgets,
  }) {
    final now = DateTime.now();
    final thisMonth = includedTransactions.where((t) =>
        t.timestamp.month == now.month && t.timestamp.year == now.year);

    if (thisMonth.isEmpty) {
      return const InsightsReport(
        hasData: false,
        monthlySummaryLines: [
          'No spending tracked this month yet.',
          'Categorize SMS expenses or add cash spending to get started.',
        ],
      );
    }

    return InsightsReport(
      hasData: true,
      monthlySummaryLines:
          _monthlySummary(includedTransactions, now, snapshot),
      behaviors: _behaviors(includedTransactions, now),
    );
  }

  List<String> _monthlySummary(
    List<Transaction> all,
    DateTime now,
    FinanceSnapshot snapshot,
  ) {
    final lines = <String>[];
    lines.add(
      'You\'ve spent ${formatInr(snapshot.monthlySpent)} across ${snapshot.monthlyByCategory.length} categories this month.',
    );

    if (snapshot.monthlyByCategory.isNotEmpty) {
      final top = snapshot.monthlyByCategory.first;
      lines.add(
        'Biggest category: ${top.category} at ${formatInr(top.amount)}.',
      );
    }

    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final prev = all.where((t) =>
        t.timestamp.month == prevMonth.month &&
        t.timestamp.year == prevMonth.year);
    if (prev.isEmpty) {
      lines.add('No data from last month yet — comparisons will appear over time.');
      return lines;
    }

    final prevTotal = prev.fold<double>(0, (s, t) => s + t.amount);
    final thisTotal = snapshot.monthlySpent;
    if (prevTotal > 0) {
      final change = ((thisTotal - prevTotal) / prevTotal * 100).round();
      final dir = change >= 0 ? 'up' : 'down';
      lines.add(
        'Total spending is $dir ${change.abs()}% vs last month (${formatInr(prevTotal)} → ${formatInr(thisTotal)}).',
      );
    }

    return lines;
  }

  List<BehaviorInsight> _behaviors(List<Transaction> all, DateTime now) {
    final behaviors = <BehaviorInsight>[];
    final thisMonth = all.where((t) =>
        t.timestamp.month == now.month && t.timestamp.year == now.year);

    if (thisMonth.length < 3) return behaviors;

    var weekend = 0.0;
    var weekday = 0.0;
    var weekendCount = 0;
    var weekdayCount = 0;
    for (final t in thisMonth) {
      final isWeekend =
          t.timestamp.weekday == DateTime.saturday ||
          t.timestamp.weekday == DateTime.sunday;
      if (isWeekend) {
        weekend += t.amount;
        weekendCount++;
      } else {
        weekday += t.amount;
        weekdayCount++;
      }
    }
    if (weekendCount >= 2 && weekdayCount >= 2) {
      final wAvg = weekend / weekendCount;
      final dAvg = weekday / weekdayCount;
      if (wAvg > dAvg * 1.15) {
        final pct = ((wAvg / dAvg - 1) * 100).round();
        behaviors.add(BehaviorInsight(
          title: 'Weekend spending',
          body:
              'Your average weekend spend is about $pct% higher than weekdays.',
        ));
      }
    }

    final lateNight = thisMonth.where((t) {
      final food = t.category == 'Food' || t.category == 'Snacks';
      return food && t.timestamp.hour >= 22;
    }).length;
    if (lateNight >= 2) {
      behaviors.add(BehaviorInsight(
        title: 'Late-night food',
        body: '$lateNight food/snack expenses after 10 PM this month.',
      ));
    }

    final merchants = <String, int>{};
    for (final t in thisMonth) {
      final key = t.merchant.toLowerCase();
      merchants[key] = (merchants[key] ?? 0) + 1;
    }
    final recurring = merchants.entries.where((e) => e.value >= 2).length;
    if (recurring > 0) {
      behaviors.add(BehaviorInsight(
        title: 'Repeat merchants',
        body:
            '$recurring merchants appear multiple times — check for subscriptions.',
      ));
    }

    return behaviors;
  }

  String? budgetPrediction(Budget budget) {
    if (budget.spent <= 0) return null;
    final now = DateTime.now();
    final day = now.day;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    if (day < 3) return null;
    final daily = budget.spent / day;
    final projected = daily * daysInMonth;
    if (projected <= budget.limit) return null;
    final over = projected - budget.limit;
    return 'At this pace, you may exceed ${budget.category} by ${formatInr(over)}.';
  }
}
