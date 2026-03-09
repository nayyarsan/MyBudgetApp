import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../goals/goals_screen.dart';
import 'budget_calculator.dart';
import 'budget_providers.dart';
import '../../core/services/rollover_provider.dart';
import 'rebalance_provider.dart';
import 'widgets/category_row.dart';
import 'widgets/rebalance_sheet.dart';
import 'widgets/recurring_due_banner.dart';
import 'widgets/tbb_banner.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final groupsAsync = ref.watch(categoryGroupsProvider);
    final budgetsAsync = ref.watch(monthlyBudgetsProvider);
    final txAsync = ref.watch(transactionsForMonthProvider);
    final incomeAsync = ref.watch(monthlyIncomeProvider);
    final assignedAsync = ref.watch(totalAssignedProvider);

    final tbbCents = incomeAsync.whenOrNull(
          data: (income) => assignedAsync.whenOrNull(
            data: (assigned) => BudgetCalculator.toBeBudgeted(
              totalIncomeCents: income,
              totalAssignedCents: assigned,
            ),
          ),
        ) ??
        0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous month',
              onPressed: () =>
                  ref.read(selectedMonthProvider.notifier).state =
                      DateTime(month.year, month.month - 1),
            ),
            Text(
              '${_monthName(month.month)} ${month.year}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next month',
              onPressed: () =>
                  ref.read(selectedMonthProvider.notifier).state =
                      DateTime(month.year, month.month + 1),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final suggestionsAsync =
                  ref.watch(rebalanceSuggestionsProvider);
              final hasOverages =
                  suggestionsAsync.valueOrNull?.isNotEmpty ?? false;
              if (!hasOverages) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.balance),
                tooltip: 'Rebalance budget',
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const RebalanceSheet(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            tooltip: 'Goals',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GoalsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ToBeBudgetedBanner(tbbCents: tbbCents),
          const RecurringDueBanner(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'CATEGORY',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'BUDGETED',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SPENT',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'AVAILABLE',
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: groupsAsync.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No budget categories yet.\nTap + to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                final budgets = budgetsAsync.valueOrNull ?? [];
                final transactions = txAsync.valueOrNull ?? [];

                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, i) => _GroupTile(
                    group: groups[i],
                    budgets: budgets,
                    transactions: transactions,
                    month: monthKey(month),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Something went wrong. Please try again.', style: TextStyle(color: Colors.grey))),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_budget',
        onPressed: () => _showAddCategoryDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final groupCtrl = TextEditingController();
    final catCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: groupCtrl,
              decoration: const InputDecoration(
                labelText: 'Group (e.g. Housing)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: catCtrl,
              decoration: const InputDecoration(
                labelText: 'Category name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (groupCtrl.text.isNotEmpty &&
                  catCtrl.text.isNotEmpty) {
                final db = ref.read(databaseProvider);
                final groupId = await db.categoriesDao
                    .insertGroup(groupCtrl.text.trim());
                await db.categoriesDao.insertCategory(
                  CategoriesCompanion.insert(
                    groupId: groupId,
                    name: catCtrl.text.trim(),
                  ),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[m - 1];
  }
}

/// Collapsible group tile that lists its categories with budget columns.
class _GroupTile extends ConsumerWidget {
  final CategoryGroup group;
  final List<MonthlyBudget> budgets;
  final List<Transaction> transactions;
  final String month;

  const _GroupTile({
    required this.group,
    required this.budgets,
    required this.transactions,
    required this.month,
  });

  Future<void> _confirmDeleteGroup(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete group?'),
        content: Text(
          'Delete "${group.name}" and all its categories? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(databaseProvider)
          .categoriesDao
          .softDeleteGroup(group.id);
    }
  }

  int _spentForCategory(int categoryId) {
    var total = 0;
    for (final t in transactions) {
      if (t.categoryId == categoryId && t.amountCents < 0) {
        total += t.amountCents.abs();
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final rolloverAmounts =
        ref.watch(rolloverAmountsProvider).valueOrNull ?? {};
    return StreamBuilder<List<Category>>(
      stream: db.categoriesDao.watchCategoriesForGroup(group.id),
      builder: (context, snapshot) {
        final cats = snapshot.data ?? [];

        var groupAvailable = 0;
        for (final cat in cats) {
          final budget =
              budgets.where((b) => b.categoryId == cat.id).firstOrNull;
          final assigned = budget?.assignedCents ?? 0;
          final spent = _spentForCategory(cat.id);
          groupAvailable += BudgetCalculator.available(
            assignedCents: assigned,
            spentCents: spent,
            rolledOverCents: rolloverAmounts[cat.id] ?? 0,
            rollover: cat.rollover,
          );
        }

        return ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            group.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cats.isNotEmpty)
                Text(
                  '\$${(groupAvailable / 100).toStringAsFixed(0)}',
                  style: TextStyle(
                    color:
                        groupAvailable < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18),
                onSelected: (v) {
                  if (v == 'delete') {
                    _confirmDeleteGroup(context, ref);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Delete group',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: cats.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      'No categories in this group.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ]
              : cats.map((cat) {
                  final budget = budgets
                      .where((b) => b.categoryId == cat.id)
                      .firstOrNull;
                  final assigned = budget?.assignedCents ?? 0;
                  final spent = _spentForCategory(cat.id);
                  final available = BudgetCalculator.available(
                    assignedCents: assigned,
                    spentCents: spent,
                    rolledOverCents: rolloverAmounts[cat.id] ?? 0,
                    rollover: cat.rollover,
                  );

                  return CategoryRow(
                    name: cat.name,
                    assignedCents: assigned,
                    spentCents: spent,
                    availableCents: available,
                    onTap: () =>
                        _showBudgetDialog(context, ref, cat, assigned),
                    onLongPress: () =>
                        _confirmDeleteCategory(context, ref, cat),
                  );
                }).toList(),
        );
      },
    );
  }

  Future<void> _showBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    Category cat,
    int currentCents,
  ) async {
    final ctrl = TextEditingController(
      text: currentCents == 0 ? '' : (currentCents / 100).toStringAsFixed(2),
    );
    var rolloverOverride = cat.rollover;

    final globalEnabled =
        await ref.read(globalRolloverEnabledProvider.future);

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Budget: ${cat.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
              ),
              if (globalEnabled) ...[
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Roll over unused'),
                  value: rolloverOverride,
                  onChanged: (v) => setState(() => rolloverOverride = v),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final dollars =
                    double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0;
                final cents = (dollars * 100).round();
                final db = ref.read(databaseProvider);
                await db.budgetDao.upsertBudget(
                  MonthlyBudgetsCompanion.insert(
                    categoryId: cat.id,
                    month: month,
                    assignedCents: Value(cents),
                  ),
                );
                if (globalEnabled) {
                  await db.categoriesDao
                      .updateRollover(cat.id, rolloverOverride);
                }
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    Category cat,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Delete "${cat.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(databaseProvider)
          .categoriesDao
          .softDeleteCategory(cat.id);
    }
  }
}
