import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/category_avatar.dart';
import '../../core/utils/currency_format.dart';
import '../../core/widgets/rupee_card.dart';
import '../../models/transaction.dart';
import '../../providers/finance_notifier.dart';
import '../transaction/transaction_detail_screen.dart';
import 'manage_data_sheet.dart';

enum HistoryFilter { today, week, month, all }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryFilter _filter = HistoryFilter.month;
  String _search = '';
  bool _selectMode = false;
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final txns = ref.watch(financeProvider).historyTransactions;
    final filtered = _applyFilters(txns);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('History', style: theme.textTheme.headlineMedium),
                ),
                if (_selectMode) ...[
                  TextButton(
                    onPressed: () => setState(() {
                      _selectMode = false;
                      _selected.clear();
                    }),
                    child: const Text('Cancel'),
                  ),
                  IconButton(
                    tooltip: 'Delete selected',
                    onPressed: _selected.isEmpty ? null : _deleteSelected,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ] else ...[
                  IconButton(
                    tooltip: 'Select payments',
                    onPressed: () => setState(() => _selectMode = true),
                    icon: const Icon(Icons.checklist),
                  ),
                  IconButton(
                    tooltip: 'Manage data',
                    onPressed: () => showManageDataSheet(context),
                    icon: const Icon(Icons.storage_outlined),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search merchant or category…',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v.toLowerCase()),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _chip('Today', _filter == HistoryFilter.today,
                    () => setState(() => _filter = HistoryFilter.today)),
                _chip('Week', _filter == HistoryFilter.week,
                    () => setState(() => _filter = HistoryFilter.week)),
                _chip('Month', _filter == HistoryFilter.month,
                    () => setState(() => _filter = HistoryFilter.month)),
                _chip('All', _filter == HistoryFilter.all,
                    () => setState(() => _filter = HistoryFilter.all)),
              ],
            ),
          ),
          if (_selectMode && _selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                '${_selected.length} selected',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No payments match your filters.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final t = filtered[i];
                      final selected = _selected.contains(t.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RupeeCard(
                          onTap: () {
                            if (_selectMode) {
                              setState(() {
                                if (selected) {
                                  _selected.remove(t.id);
                                } else {
                                  _selected.add(t.id);
                                }
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      TransactionDetailScreen(transaction: t),
                                ),
                              );
                            }
                          },
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              if (_selectMode)
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    selected
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              CategoryAvatar(category: t.category.isEmpty
                                  ? (t.isIncome ? 'Received' : '?')
                                  : t.category),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.isIncome
                                          ? 'Received'
                                          : (t.category.isEmpty
                                              ? 'Uncategorized'
                                              : t.category),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Text(
                                      t.merchant,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    Text(
                                      '${t.paymentType} • ${DateFormat.jm().format(t.timestamp)}',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${t.isIncome ? '+' : ''}${formatInr(t.amount)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: t.isIncome
                                      ? AppColors.safe
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSelected() async {
    final count = _selected.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete $count payment${count == 1 ? '' : 's'}?'),
        content: const Text('This cannot be undone.'),
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
    if (ok == true) {
      await ref
          .read(financeProvider.notifier)
          .deleteSelectedTransactions(_selected);
      setState(() {
        _selectMode = false;
        _selected.clear();
      });
    }
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  List<Transaction> _applyFilters(List<Transaction> txns) {
    final now = DateTime.now();
    return txns.where((t) {
      if (_search.isNotEmpty &&
          !t.merchant.toLowerCase().contains(_search) &&
          !t.category.toLowerCase().contains(_search)) {
        return false;
      }
      switch (_filter) {
        case HistoryFilter.today:
          return t.timestamp.year == now.year &&
              t.timestamp.month == now.month &&
              t.timestamp.day == now.day;
        case HistoryFilter.week:
          return now.difference(t.timestamp).inDays <= 7;
        case HistoryFilter.month:
          return t.timestamp.month == now.month && t.timestamp.year == now.year;
        case HistoryFilter.all:
          return true;
      }
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
