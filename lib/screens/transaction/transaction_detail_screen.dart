import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_format.dart';
import '../../core/widgets/rupee_card.dart';
import '../../models/transaction.dart';
import '../../providers/finance_notifier.dart';

class TransactionDetailScreen extends ConsumerStatefulWidget {
  const TransactionDetailScreen({super.key, required this.transaction});

  final Transaction transaction;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  late final TextEditingController _notesController;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.transaction.notes ?? '');
    _notesController.addListener(() => _dirty = true);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Transaction get _txn {
    final list = ref.watch(financeProvider).transactions;
    return list.firstWhere(
      (t) => t.id == widget.transaction.id,
      orElse: () => widget.transaction,
    );
  }

  Future<void> _saveNotes() async {
    await ref
        .read(financeProvider.notifier)
        .updateTransactionNotes(_txn.id, _notesController.text);
    _dirty = false;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved')),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this payment?'),
        content: Text(
          '${formatInr(_txn.amount)} at ${_txn.merchant} will be removed.',
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
    if (ok == true && mounted) {
      await ref.read(financeProvider.notifier).deleteTransaction(_txn.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txn = _txn;
    final isCredit = txn.isIncome;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Text(
              '${isCredit ? '+' : '-'}${formatInr(txn.amount)}',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: isCredit ? AppColors.safe : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${txn.category.isEmpty ? (isCredit ? 'Received' : 'Uncategorized') : txn.category}',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 24),
          RupeeCard(
            child: Column(
              children: [
                _row(theme, 'Type', isCredit ? 'Money received' : 'Expense'),
                _row(theme, 'Merchant', txn.merchant),
                _row(theme, 'Payment', txn.paymentType),
                _row(
                  theme,
                  'Date',
                  DateFormat('d MMM yyyy, h:mm a').format(txn.timestamp),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Your note', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Add anything you want to remember about this payment…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveNotes,
            child: Text(_dirty ? 'Save note' : 'Save note'),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            label: const Text(
              'Delete payment',
              style: TextStyle(color: AppColors.danger),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
