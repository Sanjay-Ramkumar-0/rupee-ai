import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/categories.dart';
import '../../providers/finance_notifier.dart';

void showAddPaymentSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => const _AddPaymentSheet(),
  );
}

class _AddPaymentSheet extends ConsumerStatefulWidget {
  const _AddPaymentSheet();

  @override
  ConsumerState<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends ConsumerState<_AddPaymentSheet> {
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  bool _isIncome = false;
  String _category = 'Food';

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;
    await ref.read(financeProvider.notifier).addManualTransaction(
          amount: amount,
          category: _isIncome ? receivedCategory : _category,
          isIncome: _isIncome,
          merchant: _merchantController.text.trim().isEmpty
              ? (_isIncome ? 'Cash received' : 'Cash expense')
              : _merchantController.text.trim(),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(financeProvider).allCategories
        .where((c) => c != 'Do Not Include' && c != receivedCategory)
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add payment', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Spent')),
              ButtonSegment(value: true, label: Text('Received')),
            ],
            selected: {_isIncome},
            onSelectionChanged: (s) => setState(() => _isIncome = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _merchantController,
            decoration: InputDecoration(
              labelText: _isIncome ? 'From (optional)' : 'Merchant (optional)',
              hintText: _isIncome ? 'Friend, Employer…' : 'Shop name',
            ),
          ),
          if (!_isIncome) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'Food'),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
