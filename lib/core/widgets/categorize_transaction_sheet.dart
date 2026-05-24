import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/transaction.dart';
import '../../providers/finance_notifier.dart';
import '../constants/categories.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';

void showCategorizeSheet(
  BuildContext context, {
  required Transaction transaction,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _CategorizeSheet(transaction: transaction),
  );
}

class _CategorizeSheet extends ConsumerWidget {
  const _CategorizeSheet({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);
    final categories = [
      ...state.allCategories.where((c) => !permanentCategories.contains(c)),
      ...permanentCategories,
    ];
    final learned = state.merchantRules[transaction.merchant.split(' ').first];

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                formatInr(transaction.amount),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 4),
              Text(
                transaction.isIncome
                    ? 'received from ${transaction.merchant}'
                    : 'at ${transaction.merchant}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (learned != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Usually categorized as $learned. Tap to confirm?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: categories.map((cat) {
                  final isPermanent = permanentCategories.contains(cat);
                  return ActionChip(
                    label: Text(cat),
                    onPressed: () async {
                      await ref
                          .read(financeProvider.notifier)
                          .categorizeTransaction(transaction.id, cat);
                      if (context.mounted) Navigator.pop(context);
                      if (learned == null && cat != 'Do Not Include' && cat != 'Others') {
                        _maybeShowLearnPrompt(context, transaction.merchant, cat);
                      }
                    },
                    backgroundColor:
                        isPermanent ? AppColors.background : AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: isPermanent ? AppColors.textSecondary : AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeShowLearnPrompt(BuildContext context, String merchant, String category) {
    final key = merchant.split(' ').first;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Auto-categorize $key as $category next time?'),
          action: SnackBarAction(
            label: 'Yes',
            onPressed: () {},
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
