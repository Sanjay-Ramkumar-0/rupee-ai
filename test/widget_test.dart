import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rupee_ai/app.dart';
import 'package:rupee_ai/models/budget.dart';
import 'package:rupee_ai/models/user_profile.dart';
import 'package:rupee_ai/providers/finance_notifier.dart';

/// Widget tests cannot load Isar's native library; override with static state.
class _TestFinanceNotifier extends FinanceNotifier {
  @override
  FinanceState build() {
    return FinanceState(
      profile: const UserProfile(
        name: 'Sanjay',
        monthlyIncome: 40000,
        salaryDay: 1,
        setupComplete: true,
      ),
      transactions: const [],
      budgets: const [
        Budget(category: 'Food', limit: 5000, spent: 0),
      ],
      savingsGoals: const [],
      merchantRules: const {},
      isLoading: false,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'rupee_user_profile': jsonEncode({
        'name': 'Sanjay',
        'monthlyIncome': 40000,
        'salaryDay': 1,
        'customCategories': <String>[],
        'languageCode': 'en',
        'darkMode': false,
        'setupComplete': true,
      }),
    });
  });

  testWidgets('Rupee AI home shows financial status', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [financeProvider.overrideWith(_TestFinanceNotifier.new)],
        child: const RupeeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Remaining Balance'), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
  });
}
