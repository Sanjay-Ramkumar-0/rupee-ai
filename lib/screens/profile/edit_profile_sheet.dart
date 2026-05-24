import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_profile.dart';
import '../../providers/finance_notifier.dart';

void showEditProfileSheet(BuildContext context, UserProfile profile) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _EditProfileSheet(profile: profile),
  );
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _incomeController;
  late int _salaryDay;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _incomeController = TextEditingController(
      text: widget.profile.monthlyIncome > 0
          ? widget.profile.monthlyIncome.toStringAsFixed(0)
          : '',
    );
    _salaryDay = widget.profile.salaryDay;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim().isEmpty
        ? 'Friend'
        : _nameController.text.trim();
    final income =
        double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0;
    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your monthly income')),
      );
      return;
    }
    await ref.read(financeProvider.notifier).updateProfile(
          name: name,
          monthlyIncome: income,
          salaryDay: _salaryDay,
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Text('Edit profile', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Your name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _incomeController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly salary / income',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 16),
          Text('Salary credited on day of month', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _salaryDay,
            decoration: const InputDecoration(),
            items: List.generate(
              28,
              (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
            ),
            onChanged: (v) => setState(() => _salaryDay = v ?? 1),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _save, child: const Text('Save changes')),
        ],
      ),
    );
  }
}
