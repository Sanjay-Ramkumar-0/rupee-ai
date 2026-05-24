import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/rupee_card.dart';
import '../../providers/finance_notifier.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final report = ref.watch(insightsReportProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Insights', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Based only on your real spending — nothing made up.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          RupeeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly summary', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ...report.monthlySummaryLines.map(
                  (line) => _bullet(theme, line),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Spending behavior', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          if (report.behaviors.isEmpty)
            RupeeCard(
              child: Text(
                report.hasData
                    ? 'Keep tracking — patterns like weekend or late-night spending will show up here.'
                    : 'Add expenses to discover your spending patterns.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            )
          else
            ...report.behaviors.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _behaviorCard(theme, b.title, b.body),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bullet(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary)),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _behaviorCard(ThemeData theme, String title, String body) {
    return RupeeCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
