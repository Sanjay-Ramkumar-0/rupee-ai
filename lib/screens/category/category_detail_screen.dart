import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_format.dart';
import '../../core/widgets/rupee_card.dart';
import '../../providers/finance_notifier.dart';

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final txns = ref.watch(financeProvider).expenseTransactions
        .where((t) => t.category == category)
        .toList();
    final total = txns.fold<double>(0, (s, t) => s + t.amount);

    final merchants = <String, double>{};
    for (final t in txns) {
      merchants[t.merchant] = (merchants[t.merchant] ?? 0) + t.amount;
    }
    final topMerchants = merchants.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          RupeeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total spent this month', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(formatInr(total), style: theme.textTheme.headlineMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: AppColors.warning, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Weekend dining caused most increase.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Top merchants', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...topMerchants.take(5).map(
                (e) => RupeeCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      )),
                      Text(
                        formatInr(e.value),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 20),
          Text('AI suggestion', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          RupeeCard(
            child: Text(
              'Try setting a weekly limit for $category to stay within budget.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
