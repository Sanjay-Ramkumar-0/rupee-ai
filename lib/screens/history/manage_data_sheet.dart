import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/finance_notifier.dart';

void showManageDataSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _ManageDataSheet(),
  );
}

class _ManageDataSheet extends ConsumerWidget {
  const _ManageDataSheet();

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
    return result == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financeProvider);
    final categories = state.includedTransactions
        .map((t) => t.category)
        .toSet()
        .toList()
      ..sort();
    final txnCount = state.transactions.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Manage your data', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '$txnCount transactions stored on this device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete last 5 payments'),
              onTap: () async {
                if (!context.mounted) return;
                if (await _confirm(
                  context,
                  title: 'Delete last 5?',
                  message: 'These expenses will be removed permanently.',
                )) {
                  await ref.read(financeProvider.notifier).deleteLastTransactions(5);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range_outlined),
              title: const Text('Delete last 5 days'),
              onTap: () async {
                if (!context.mounted) return;
                if (await _confirm(
                  context,
                  title: 'Delete last 5 days?',
                  message: 'All expenses from the past 5 days will be removed.',
                )) {
                  await ref
                      .read(financeProvider.notifier)
                      .deleteTransactionsInLastDays(5);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
            if (categories.isNotEmpty) ...[
              const Divider(),
              Text('By category', style: Theme.of(context).textTheme.titleMedium),
              ...categories.map(
                (cat) => ListTile(
                  title: Text('Delete all $cat'),
                  leading: const Icon(Icons.category_outlined),
                  onTap: () async {
                    if (!context.mounted) return;
                    final count =
                        state.transactions.where((t) => t.category == cat).length;
                    if (await _confirm(
                      context,
                      title: 'Delete $cat?',
                      message: '$count transaction(s) will be removed.',
                    )) {
                      await ref
                          .read(financeProvider.notifier)
                          .deleteTransactionsByCategory(cat);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete all transactions'),
              titleTextStyle: const TextStyle(color: Colors.red),
              onTap: () async {
                if (!context.mounted) return;
                if (await _confirm(
                  context,
                  title: 'Delete everything?',
                  message:
                      'All $txnCount transactions will be removed. Your profile, budgets, and goals stay.',
                )) {
                  await ref.read(financeProvider.notifier).deleteAllTransactions();
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
