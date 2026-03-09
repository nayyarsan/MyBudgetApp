import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../../core/utils/currency_formatter.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/widgets/transaction_tile.dart';
import 'account_providers.dart';
import 'add_account_screen.dart';

class AccountDetailScreen extends ConsumerWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txStream = StreamProvider<List<Transaction>>(
      (ref) => ref
          .watch(databaseProvider)
          .transactionsDao
          .watchTransactionsForAccount(account.id),
    );
    final txAsync = ref.watch(txStream);
    final balancesAsync = ref.watch(accountRunningBalancesProvider);
    final allAccountsAsync = ref.watch(accountsProvider);

    final accountMap = {
      for (final a in allAccountsAsync.valueOrNull ?? <Account>[]) a.id: a.name,
    };

    final currentBalance = balancesAsync.valueOrNull?[account.id] ??
        account.balanceCents;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.name),
            Text(
              CurrencyFormatter.format(currentBalance),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: currentBalance < 0 ? Colors.red.shade200 : Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit account',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => AddAccountScreen(initial: account),
              ),
            ),
          ),
        ],
      ),
      body: txAsync.when(
        data: (txs) {
          if (txs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'No transactions yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: txs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final tx = txs[i];
              return TransactionTile(
                transaction: tx,
                accountName: accountMap[tx.accountId],
                toAccountName: tx.toAccountId != null
                    ? accountMap[tx.toAccountId!]
                    : null,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddTransactionScreen(initial: tx),
                  ),
                ),
                onDelete: () => ref
                    .read(databaseProvider)
                    .transactionsDao
                    .softDelete(tx.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Something went wrong. Please try again.', style: TextStyle(color: Colors.grey))),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_account_detail',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AddTransactionScreen(
              initialAccountId: account.id,
            ),
          ),
        ),
        tooltip: 'Add transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}
