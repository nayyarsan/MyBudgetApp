import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/database.dart';
import '../../../core/database/providers.dart';
import '../budget_providers.dart';
import '../rebalance_provider.dart';

class RebalanceSheet extends ConsumerStatefulWidget {
  const RebalanceSheet({super.key});

  @override
  ConsumerState<RebalanceSheet> createState() => _RebalanceSheetState();
}

class _RebalanceSheetState extends ConsumerState<RebalanceSheet> {
  List<RebalanceSuggestion>? _editable;

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = ref.watch(rebalanceSuggestionsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rebalance Budget',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Move money from surplus categories to cover overages.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const Divider(),
          Expanded(
            child: suggestionsAsync.when(
              data: (suggestions) {
                _editable ??= List.of(suggestions);
                if (_editable!.isEmpty) {
                  return const Center(
                    child: Text('No overages to rebalance.'),
                  );
                }
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._editable!.map((s) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'From: ${s.fromCategoryName}',
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,),
                                          ),
                                          Text(
                                            'To: ${s.toCategoryName}',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        initialValue: (s.amountCents / 100)
                                            .toStringAsFixed(2),
                                        decoration: const InputDecoration(
                                          prefixText: '\$',
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                                decimal: true,),
                                        onChanged: (v) {
                                          final cents =
                                              ((double.tryParse(v) ?? 0) * 100)
                                                  .round();
                                          setState(
                                              () => s.amountCents = cents,);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _applyAll(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve All'),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Something went wrong. Please try again.', style: TextStyle(color: Colors.grey))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyAll(BuildContext context) async {
    if (_editable == null) return;
    final db = ref.read(databaseProvider);
    final month = ref.read(selectedMonthProvider);
    final monthStr = monthKey(month);
    final budgets =
        await db.budgetDao.watchBudgetsForMonth(monthStr).first;

    for (final s in _editable!) {
      if (s.amountCents <= 0) continue;

      // Reduce source
      final fromBudget =
          budgets.where((b) => b.categoryId == s.fromCategoryId).firstOrNull;
      final fromAssigned = (fromBudget?.assignedCents ?? 0) - s.amountCents;
      await db.budgetDao.upsertBudget(
        MonthlyBudgetsCompanion.insert(
          categoryId: s.fromCategoryId,
          month: monthStr,
          assignedCents: Value(fromAssigned < 0 ? 0 : fromAssigned),
        ),
      );

      // Increase destination
      final toBudget =
          budgets.where((b) => b.categoryId == s.toCategoryId).firstOrNull;
      final toAssigned = (toBudget?.assignedCents ?? 0) + s.amountCents;
      await db.budgetDao.upsertBudget(
        MonthlyBudgetsCompanion.insert(
          categoryId: s.toCategoryId,
          month: monthStr,
          assignedCents: Value(toAssigned),
        ),
      );
    }

    if (context.mounted) Navigator.of(context).pop();
    ref.invalidate(rebalanceSuggestionsProvider);
  }
}
