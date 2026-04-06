import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../../core/utils/currency_formatter.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Transactions')),
      body: StreamBuilder<List<PendingReviewTransaction>>(
        stream: db.plaidDao.watchPendingReview(),
        builder: (context, snapshot) {
          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text('All caught up — no transactions to review.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ReviewTile(item: item);
            },
          );
        },
      ),
    );
  }
}

class _ReviewTile extends ConsumerWidget {
  final PendingReviewTransaction item;
  const _ReviewTile({required this.item});

  String get _reasonLabel => item.reason == 'ambiguous_transfer'
      ? 'Possible transfer between accounts'
      : 'Possible duplicate';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final dateStr = DateFormat('MMM d, yyyy').format(item.date);
    final amountStr = CurrencyFormatter.format(item.amountCents);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(item.payee),
          subtitle: Text('$dateStr · $_reasonLabel'),
          trailing: Text(
            amountStr,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (item.reason == 'ambiguous_transfer')
              TextButton(
                onPressed: () async {
                  final creditAccountId = item.pairedAccountId;
                  if (creditAccountId != null) {
                    // Insert debit leg (money out of debit account, going to credit account)
                    await db.transactionsDao.insertTransaction(
                      TransactionsCompanion(
                        accountId: Value(item.accountId),
                        amountCents: Value(item.amountCents),
                        date: Value(item.date),
                        payee: Value(item.payee),
                        type: const Value('transfer'),
                        toAccountId: Value(creditAccountId),
                        importedFrom: const Value('plaid'),
                      ),
                    );
                  }
                  await db.plaidDao.deletePendingReview(item.id);
                },
                child: const Text('Mark as Transfer'),
              ),
            TextButton(
              onPressed: () async {
                // Insert as expense/income
                final type = item.amountCents > 0 ? 'expense' : 'income';
                await db.transactionsDao.insertTransaction(
                  TransactionsCompanion(
                    accountId: Value(item.accountId),
                    amountCents: Value(item.amountCents.abs()),
                    date: Value(item.date),
                    payee: Value(item.payee),
                    type: Value(type),
                    importedFrom: const Value('plaid'),
                  ),
                );
                await db.plaidDao.deletePendingReview(item.id);
              },
              child: Text(item.amountCents > 0 ? 'Keep as Expense' : 'Keep as Income'),
            ),
            TextButton(
              onPressed: () => db.plaidDao.deletePendingReview(item.id),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ],
    );
  }
}
