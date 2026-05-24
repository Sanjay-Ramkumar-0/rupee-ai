import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({
    super.key,
    required this.onAddExpense,
    required this.onSetBudget,
    required this.onViewReports,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onSetBudget;
  final VoidCallback onViewReports;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add Cash\nExpense',
                onTap: onAddExpense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.pie_chart_outline,
                label: 'Set\nBudget',
                onTap: onSetBudget,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActionButton(
          icon: Icons.bar_chart_rounded,
          label: 'View Reports',
          onTap: onViewReports,
          filled: true,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 88,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: filled ? null : Border.all(color: AppColors.divider),
            boxShadow: filled
                ? null
                : const [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: filled ? Colors.white : AppColors.primary,
                size: 26,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 13,
                  color: filled ? Colors.white : AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
