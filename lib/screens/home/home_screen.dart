import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/category_bar_chart.dart';
import '../../core/widgets/rupee_card.dart';
import '../../core/widgets/financial_status_card.dart';
import '../../core/widgets/quick_action_buttons.dart';
import '../../core/widgets/smart_alerts_section.dart';
import '../../core/widgets/today_spending_card.dart';
import '../../providers/finance_notifier.dart';
import '../../services/payment_notification_service.dart';
import '../category/category_detail_screen.dart';
import 'add_payment_sheet.dart';
import 'adjust_balance_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.onNavigate});

  final void Function(int tabIndex) onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);
    final snapshot = ref.watch(financeSnapshotProvider);
    final notifier = ref.read(financeProvider.notifier);
    final greeting = notifier.greeting();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting, ${state.profile.name}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  FinancialStatusCard(
                    snapshot: snapshot,
                    onAdjustBalance: () => showAdjustBalanceSheet(
                      context,
                      snapshot.remainingBalance,
                    ),
                  ),
                  const SizedBox(height: 20),
                  QuickActionButtons(
                    onAddExpense: () => showAddPaymentSheet(context),
                    onSetBudget: () => onNavigate(2),
                    onViewReports: () => onNavigate(3),
                  ),
                  const SizedBox(height: 20),
                  TodaySpendingCard(snapshot: snapshot),
                  const SizedBox(height: 20),
                  CategoryBarChart(
                    categories: snapshot.monthlyByCategory,
                    onCategoryTap: (cat) {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => CategoryDetailScreen(category: cat),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SmartAlertsSection(alerts: snapshot.alerts),
                  const SizedBox(height: 12),
                  _NotificationSetupCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSetupCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RupeeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined,
                  color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Payment notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rupee AI reads UPI and bank alerts (not SMS). Enable notification access for GPay, PhonePe, Paytm, and your bank.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              final service = ref.read(paymentNotificationServiceProvider);
              final ok = await service.hasPermission;
              if (!ok) {
                await service.openPermissionSettings();
                return;
              }
              final started = await service.startListening();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      started
                          ? 'Listening for payment notifications'
                          : 'Could not start listener',
                    ),
                  ),
                );
              }
            },
            child: const Text('Enable notification tracking'),
          ),
        ],
      ),
    );
  }
}
