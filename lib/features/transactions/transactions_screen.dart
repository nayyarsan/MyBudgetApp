import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/providers.dart';
import '../budget/budget_providers.dart';
import 'add_transaction_screen.dart';
import 'import_csv_screen.dart';
import 'widgets/transaction_tile.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsForMonthProvider);
    final month = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions — ${_monthName(month.month)} ${month.year}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Import CSV',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ImportCsvScreen(),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by payee or memo…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: txAsync.when(
        data: (txs) {
          final filtered = _searchQuery.isEmpty
              ? txs
              : txs
                  .where(
                    (t) =>
                        t.payee.toLowerCase().contains(_searchQuery) ||
                        (t.memo?.toLowerCase().contains(_searchQuery) ??
                            false),
                  )
                  .toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No transactions this month.\nTap + to add one.'
                        : 'No results for "$_searchQuery".',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final tx = filtered[i];
              return TransactionTile(
                transaction: tx,
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
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_transactions',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AddTransactionScreen(),
          ),
        ),
        tooltip: 'Add transaction',
        child: const Icon(Icons.add),
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
