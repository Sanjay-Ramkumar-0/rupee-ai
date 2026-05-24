import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/savings_goal_config.dart';
import '../../providers/finance_notifier.dart';

void showEditSavingsGoalSheet(BuildContext context, {SavingsGoal? existing}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _EditSavingsGoalSheet(existing: existing),
  );
}

class _EditSavingsGoalSheet extends ConsumerStatefulWidget {
  const _EditSavingsGoalSheet({this.existing});

  final SavingsGoal? existing;

  @override
  ConsumerState<_EditSavingsGoalSheet> createState() =>
      _EditSavingsGoalSheetState();
}

class _EditSavingsGoalSheetState extends ConsumerState<_EditSavingsGoalSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _savedController;
  late final TextEditingController _monthlyController;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameController = TextEditingController(text: e?.name ?? '');
    _targetController = TextEditingController(
      text: e != null ? e.targetAmount.toStringAsFixed(0) : '',
    );
    _savedController = TextEditingController(
      text: e != null ? e.savedAmount.toStringAsFixed(0) : '0',
    );
    _monthlyController = TextEditingController(
      text: e != null ? e.monthlyTarget.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _savedController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final target = double.tryParse(_targetController.text.replaceAll(',', ''));
    final saved = double.tryParse(_savedController.text.replaceAll(',', '')) ?? 0;
    final monthly =
        double.tryParse(_monthlyController.text.replaceAll(',', ''));
    if (name.isEmpty || target == null || target <= 0 || monthly == null) {
      return;
    }
    await ref.read(financeProvider.notifier).upsertSavingsGoal(
          SavingsGoal(
            name: name,
            targetAmount: target,
            savedAmount: saved,
            monthlyTarget: monthly,
          ),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing != null ? 'Edit savings goal' : 'Add savings goal',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Goal name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target amount',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _savedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Already saved',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _monthlyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Save per month',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
