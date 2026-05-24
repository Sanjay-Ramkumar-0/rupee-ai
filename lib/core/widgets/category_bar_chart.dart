import 'package:flutter/material.dart';

import '../../models/finance_snapshot.dart';
import '../theme/app_theme.dart';
import '../utils/currency_format.dart';
import 'rupee_card.dart';

class CategoryBarChart extends StatelessWidget {
  const CategoryBarChart({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<CategorySpend> categories;
  final void Function(String category)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (categories.isEmpty) {
      return RupeeCard(
        child: Text(
          'Add expenses to see your monthly breakdown.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final maxAmount = categories.map((c) => c.amount).reduce((a, b) => a > b ? a : b);

    return RupeeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This Month by Category', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          ...categories.map((item) {
            final fraction = item.amount / maxAmount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: InkWell(
                onTap: () => onCategoryTap?.call(item.category),
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.category, style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        )),
                        Text(
                          formatInr(item.amount),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 10,
                        backgroundColor: AppColors.divider,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
