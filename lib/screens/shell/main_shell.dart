import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/categorize_transaction_sheet.dart';
import '../../providers/finance_notifier.dart';
import '../budget/budget_screen.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../insights/insights_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.history_rounded, label: 'History'),
    (icon: Icons.pie_chart_rounded, label: 'Budget'),
    (icon: Icons.insights_rounded, label: 'Insights'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen<FinanceState>(financeProvider, (prev, next) {
      final pending = next.pendingCategorization;
      if (pending != null && pending != prev?.pendingCategorization) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showCategorizeSheet(context, transaction: pending);
        });
      }
    });

    final screens = [
      HomeScreen(onNavigate: _goTo),
      const HistoryScreen(),
      const BudgetScreen(),
      const InsightsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _tabs
            .map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }

  void _goTo(int index) => setState(() => _index = index);
}
