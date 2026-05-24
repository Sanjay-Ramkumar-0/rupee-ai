import 'package:flutter/material.dart';

import '../../models/finance_snapshot.dart';
import '../theme/app_theme.dart';
import 'rupee_card.dart';

class SmartAlertsSection extends StatelessWidget {
  const SmartAlertsSection({super.key, required this.alerts});

  final List<SmartAlert> alerts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Smart Alerts', style: theme.textTheme.titleMedium),
        ),
        ...alerts.map((alert) {
          final (icon, color) = switch (alert.type) {
            AlertType.warning => (Icons.warning_amber_rounded, AppColors.warning),
            AlertType.success => (Icons.check_circle_outline, AppColors.safe),
            AlertType.info => (Icons.info_outline, AppColors.textSecondary),
          };
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: RupeeCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
