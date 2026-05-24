import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/finance_notifier.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _nameController = TextEditingController();
  final _incomeController = TextEditingController(text: '40000');
  int _salaryDay = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim().isEmpty
        ? 'Friend'
        : _nameController.text.trim();
    final income = double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0;
    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your monthly income')),
      );
      return;
    }
    await ref.read(financeProvider.notifier).completeSetup(
          name: name,
          monthlyIncome: income,
          salaryDay: _salaryDay,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text('Welcome to\nRupee AI', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(
                'Tell us about your income so we can track what matters — without connecting your bank.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your name (optional)',
                  hintText: 'Sanjay',
                ),
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
                value: _salaryDay,
                decoration: const InputDecoration(),
                items: List.generate(
                  28,
                  (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                ),
                onChanged: (v) => setState(() => _salaryDay = v ?? 1),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Remaining balance = Income − included expenses. No bank login needed.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
