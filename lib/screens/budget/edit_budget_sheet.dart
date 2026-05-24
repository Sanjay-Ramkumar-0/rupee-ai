import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/budget.dart';
import '../../providers/finance_notifier.dart';

void showEditBudgetSheet(
  BuildContext context, {
  Budget? existing,
  String? presetCategory,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _EditBudgetSheet(
      existing: existing,
      presetCategory: presetCategory,
    ),
  );
}

class _EditBudgetSheet extends ConsumerStatefulWidget {
  const _EditBudgetSheet({this.existing, this.presetCategory});

  final Budget? existing;
  final String? presetCategory;

  @override
  ConsumerState<_EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends ConsumerState<_EditBudgetSheet> {
  late String _category;
  late final TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _category = widget.existing?.category ??
        widget.presetCategory ??
        ref.read(financeProvider).allCategories.first;
    _limitController = TextEditingController(
      text: widget.existing != null
          ? widget.existing!.limit.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final limit = double.tryParse(_limitController.text.replaceAll(',', ''));
    if (limit == null || limit <= 0) return;
    await ref.read(financeProvider.notifier).setBudgetLimit(_category, limit);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final isEdit = widget.existing != null;
    final existing = finance.profile.budgetLimits.keys.toSet();
    final categories = isEdit
        ? finance.allCategories
        : finance.allCategories.where((c) => !existing.contains(c)).toList();

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
            isEdit ? 'Edit budget' : 'Add budget',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (categories.isEmpty && !isEdit)
            Text(
              'You already have budgets for all categories.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            DropdownButtonFormField<String>(
              initialValue: categories.contains(_category)
                  ? _category
                  : (categories.isNotEmpty ? categories.first : _category),
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: isEdit
                  ? null
                  : (v) => setState(() => _category = v ?? _category),
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Monthly limit',
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
