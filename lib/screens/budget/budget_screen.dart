import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_format.dart';
import '../../core/widgets/rupee_card.dart';
import '../../models/budget.dart';
import '../../providers/finance_notifier.dart';
import '../../services/insights_analyzer.dart';
import 'edit_budget_sheet.dart';
import 'edit_savings_goal_sheet.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(financeProvider);
    final analyzer = InsightsAnalyzer();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Budget', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Set limits for categories you care about.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (state.budgets.isEmpty)
            RupeeCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No budgets yet',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap below to set a monthly limit for Food, Shopping, or any category.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else ...[
            ...state.budgets.map((b) {
              final prediction = analyzer.budgetPrediction(b);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BudgetTile(
                  budget: b,
                  prediction: prediction,
                  onEdit: () => showEditBudgetSheet(context, existing: b),
                  onDelete: () => _confirmRemoveBudget(context, ref, b.category),
                ),
              );
            }),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => showEditBudgetSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Add budget'),
          ),
          const SizedBox(height: 28),
          Text('Savings goals', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (state.savingsGoals.isEmpty)
            RupeeCard(
              child: Text(
                'Create a goal for a bike, emergency fund, vacation, or anything you\'re saving toward.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...state.savingsGoals.map(
              (g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RupeeCard(
                  onTap: () => showEditSavingsGoalSheet(context, existing: g),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(g.name, style: theme.textTheme.titleMedium),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            onPressed: () =>
                                _confirmRemoveGoal(context, ref, g.name),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: g.progress,
                          minHeight: 8,
                          backgroundColor: AppColors.divider,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatInr(g.savedAmount)} of ${formatInr(g.targetAmount)} • Save ${formatInr(g.monthlyTarget)}/mo',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => showEditSavingsGoalSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('Add savings goal'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemoveBudget(
    BuildContext context,
    WidgetRef ref,
    String category,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove $category budget?'),
        content: const Text('Spending data stays — only the limit is removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(financeProvider.notifier).removeBudget(category);
    }
  }

  Future<void> _confirmRemoveGoal(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(financeProvider.notifier).removeSavingsGoal(name);
    }
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.budget,
    required this.onEdit,
    required this.onDelete,
    this.prediction,
  });

  final Budget budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String? prediction;

  Color get _color => switch (budget.status) {
        BudgetStatus.safe => AppColors.safe,
        BudgetStatus.warning => AppColors.warning,
        BudgetStatus.exceeded => AppColors.danger,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final over = budget.spent > budget.limit;

    return RupeeCard(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(budget.category, style: theme.textTheme.titleMedium),
              ),
              if (over)
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.danger, size: 20),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
          Text(
            '${formatInr(budget.spent)} / ${formatInr(budget.limit)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: budget.progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.divider,
              color: _color,
            ),
          ),
          if (prediction != null) ...[
            const SizedBox(height: 10),
            Text(
              prediction!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
