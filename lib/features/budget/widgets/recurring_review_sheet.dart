import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/database.dart';
import '../../../core/database/providers.dart';
import '../../../core/services/month_boundary_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../recurring_providers.dart';

class RecurringReviewSheet extends ConsumerWidget {
  const RecurringReviewSheet({super.key});

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    PendingRecurringQueueData item,
    Transaction sourceTx,
  ) async {
    final db = ref.read(databaseProvider);
    // Insert new transaction cloned from template, dated today
    await db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        accountId: sourceTx.accountId,
        categoryId: Value(sourceTx.categoryId),
        amountCents: sourceTx.amountCents,
        payee: sourceTx.payee,
        date: item.dueDate,
        memo: Value(sourceTx.memo),
        type: sourceTx.type,
        toAccountId: Value(sourceTx.toAccountId),
      ),
    );
    // Advance nextDueDate on template
    final nextDue = MonthBoundaryService.computeNextDueDate(
      item.dueDate,
      sourceTx.recurringInterval ?? 'monthly',
    );
    await db.transactionsDao.updateTransaction(
      sourceTx.id,
      TransactionsCompanion(nextDueDate: Value(nextDue)),
    );
    // Remove from queue
    await db.recurringQueueDao.removeFromQueue(item.id);
  }

  Future<void> _skip(
    WidgetRef ref,
    PendingRecurringQueueData item,
    Transaction sourceTx,
  ) async {
    final db = ref.read(databaseProvider);
    // Advance nextDueDate without creating transaction
    final nextDue = MonthBoundaryService.computeNextDueDate(
      item.dueDate,
      sourceTx.recurringInterval ?? 'monthly',
    );
    await db.transactionsDao.updateTransaction(
      sourceTx.id,
      TransactionsCompanion(nextDueDate: Value(nextDue)),
    );
    await db.recurringQueueDao.removeFromQueue(item.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRecurringProvider);
    final db = ref.watch(databaseProvider);

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
                  'Recurring Transactions Due',
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
          const Divider(),
          Expanded(
            child: pendingAsync.when(
              data: (pending) {
                if (pending.isEmpty) {
                  return const Center(child: Text('All caught up!'));
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: pending.length + 1,
                  itemBuilder: (context, i) {
                    if (i == pending.length) {
                      // Confirm All button
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: FilledButton.icon(
                          onPressed: () async {
                            for (final item in [...pending]) {
                              final sourceTx = await db.transactionsDao
                                  .getTransaction(item.sourceTransactionId);
                              if (sourceTx != null && context.mounted) {
                                await _confirm(context, ref, item, sourceTx);
                              }
                            }
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.check_circle),
                          label: Text('Confirm All (${pending.length})'),
                        ),
                      );
                    }
                    final item = pending[i];
                    return FutureBuilder<Transaction?>(
                      future: db.transactionsDao
                          .getTransaction(item.sourceTransactionId),
                      builder: (context, snap) {
                        final tx = snap.data;
                        if (tx == null) return const SizedBox.shrink();
                        return ListTile(
                          leading: const Icon(Icons.repeat),
                          title: Text(tx.payee),
                          subtitle: Text(
                            '${CurrencyFormatter.format(tx.amountCents.abs())} · ${tx.recurringInterval ?? 'monthly'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () => _skip(ref, item, tx),
                                child: const Text('Skip'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    _confirm(context, ref, item, tx),
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
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
}
