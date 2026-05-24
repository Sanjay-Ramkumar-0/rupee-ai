import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/rupee_card.dart';
import '../../providers/finance_notifier.dart';
import '../../services/payment_notification_service.dart';
import '../history/manage_data_sheet.dart';
import 'edit_profile_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteCategory(String name) async {
    final count = ref
        .read(financeProvider)
        .transactions
        .where((t) => t.category == name)
        .length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "$name"?'),
        content: Text(
          count > 0
              ? '$count transaction(s) using this category will move to Others.'
              : 'This category will be removed from your list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(financeProvider.notifier).removeCustomCategory(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(financeProvider);
    final excluded = state.excludedTransactions;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Text('Profile', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 20),
          RupeeCard(
            child: Column(
              children: [
                _tile(
                  Icons.person_outline,
                  'Name',
                  state.profile.name,
                  onTap: () => showEditProfileSheet(context, state.profile),
                ),
                _tile(
                  Icons.payments_outlined,
                  'Monthly income',
                  '₹${state.profile.monthlyIncome.toStringAsFixed(0)}',
                  onTap: () => showEditProfileSheet(context, state.profile),
                ),
                _tile(
                  Icons.calendar_month_outlined,
                  'Salary day',
                  '${state.profile.salaryDay} of each month',
                  onTap: () => showEditProfileSheet(context, state.profile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => showEditProfileSheet(context, state.profile),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit income & salary'),
            ),
          ),
          const SizedBox(height: 12),
          Text('Custom categories', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Create Tea, College, Hostel, Bike… Others & Do Not Include stay fixed.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: const InputDecoration(hintText: 'New category'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  final name = _categoryController.text.trim();
                  if (name.isEmpty || permanentCategories.contains(name)) {
                    return;
                  }
                  if (defaultExpenseCategories.contains(name)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('That category already exists'),
                      ),
                    );
                    return;
                  }
                  ref.read(financeProvider.notifier).addCustomCategory(name);
                  _categoryController.clear();
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...state.profile.customCategories.map(
                (c) => InputChip(
                  label: Text(c),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _confirmDeleteCategory(c),
                ),
              ),
              ...permanentCategories.map(
                (c) => Chip(
                  label: Text(c),
                  backgroundColor: AppColors.divider.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Your data', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          RupeeCard(
            child: ListTile(
              leading: const Icon(Icons.storage_outlined, color: AppColors.primary),
              title: const Text('Manage transactions'),
              subtitle: const Text(
                'Delete recent payments, by category, or all data',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showManageDataSheet(context),
            ),
          ),
          const SizedBox(height: 24),
          Text('Settings', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          RupeeCard(
            child: Column(
              children: [
                _settingsTile(
                  Icons.notifications_active_outlined,
                  'Notification access',
                  'Required — reads UPI/bank alerts, not SMS',
                  onTap: () async {
                    final service =
                        ref.read(paymentNotificationServiceProvider);
                    final ok = await service.hasPermission;
                    if (!ok) {
                      await service.openPermissionSettings();
                    } else {
                      await service.startListening();
                    }
                  },
                ),
                _settingsTile(Icons.language, 'Language',
                    'English • Tamil • Hindi soon'),
                _settingsTile(
                    Icons.dark_mode_outlined, 'Dark mode', 'Coming soon'),
                _settingsTile(Icons.shield_outlined, 'Privacy',
                    'Local encryption • No data selling'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ExpansionTile(
            title: Text(
              'Excluded transactions (${excluded.length})',
              style: theme.textTheme.titleMedium,
            ),
            subtitle: Text(
              'Salary, refunds, ignored payments',
              style: theme.textTheme.bodyMedium,
            ),
            children: excluded
                .map(
                  (t) => ListTile(
                    title: Text(t.merchant),
                    subtitle: Text(t.category),
                    trailing: Text('₹${t.amount.toStringAsFixed(0)}'),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _settingsTile(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
