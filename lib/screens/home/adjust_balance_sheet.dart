import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/currency_format.dart';
import '../../providers/finance_notifier.dart';

void showAdjustBalanceSheet(BuildContext context, double currentRemaining) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _AdjustBalanceSheet(currentRemaining: currentRemaining),
  );
}

class _AdjustBalanceSheet extends ConsumerStatefulWidget {
  const _AdjustBalanceSheet({required this.currentRemaining});

  final double currentRemaining;

  @override
  ConsumerState<_AdjustBalanceSheet> createState() =>
      _AdjustBalanceSheetState();
}

class _AdjustBalanceSheetState extends ConsumerState<_AdjustBalanceSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentRemaining.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = double.tryParse(_controller.text.replaceAll(',', ''));
    if (value == null) return;
    await ref.read(financeProvider.notifier).setRemainingBalance(value);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _reset() async {
    final calculated =
        ref.read(financeProvider.notifier).computedRemainingWithoutAdjustment();
    await ref.read(financeProvider.notifier).setRemainingBalance(calculated);
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
          Text('Adjust remaining balance', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Change what you have left without editing your monthly salary. '
            'Current: ${formatInr(widget.currentRemaining)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Remaining balance',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _reset,
            child: const Text('Reset to calculated amount'),
          ),
        ],
      ),
    );
  }
}
