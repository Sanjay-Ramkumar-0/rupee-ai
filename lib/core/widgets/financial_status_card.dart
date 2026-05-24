import 'package:flutter/material.dart';

import '../../models/finance_snapshot.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import 'rupee_card.dart';

class FinancialStatusCard extends StatelessWidget {
  const FinancialStatusCard({
    super.key,
    required this.snapshot,
    this.onAdjustBalance,
  });

  final FinanceSnapshot snapshot;
  final VoidCallback? onAdjustBalance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RupeeCard(
      onTap: onAdjustBalance,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _metric(
                  context,
                  label: 'Remaining Balance',
                  value: formatInr(snapshot.remainingBalance),
                  emphasized: true,
                ),
              ),
              if (onAdjustBalance != null)
                const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primary),
            ],
          ),
          if (onAdjustBalance != null) ...[
            const SizedBox(height: 4),
            Text(
              'Tap to adjust without changing salary',
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _metric(
                  context,
                  label: 'Spent This Month',
                  value: formatInr(snapshot.monthlySpent),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _metric(
                  context,
                  label: 'Received',
                  value: formatInr(snapshot.monthlyReceived),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${snapshot.daysUntilSalary} days until next salary',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(
    BuildContext context, {
    required String label,
    required String value,
    bool emphasized = false,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: emphasized
              ? theme.textTheme.headlineLarge
              : theme.textTheme.titleLarge,
        ),
      ],
    );
  }
}
