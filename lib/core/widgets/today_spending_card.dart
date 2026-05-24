import 'package:flutter/material.dart';

import '../../models/finance_snapshot.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import 'rupee_card.dart';

class TodaySpendingCard extends StatelessWidget {
  const TodaySpendingCard({super.key, required this.snapshot});

  final FinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxAmount = snapshot.todayByCategory.isEmpty
        ? 1.0
        : snapshot.todayByCategory.map((c) => c.amount).reduce((a, b) => a > b ? a : b);

    return RupeeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today You Spent', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            formatInr(snapshot.todaySpent),
            style: theme.textTheme.headlineMedium,
          ),
          if (snapshot.todayByCategory.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'No spending recorded today yet.',
              style: theme.textTheme.bodyMedium,
            ),
          ] else ...[
            const SizedBox(height: 16),
            ...snapshot.todayByCategory.map((item) {
              final fraction = item.amount / maxAmount;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Text(
                      item.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 6,
                          backgroundColor: AppColors.divider,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatInr(item.amount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
