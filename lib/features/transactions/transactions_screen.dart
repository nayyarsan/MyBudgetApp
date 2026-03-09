import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../accounts/account_providers.dart';
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
  int? _filterAccountId;
  int? _filterCategoryId;
  int? _filterMinCents;
  int? _filterMaxCents;

  bool get _hasActiveFilter =>
      _filterAccountId != null ||
      _filterCategoryId != null ||
      _filterMinCents != null ||
      _filterMaxCents != null;

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionsForMonthProvider);
    final month = ref.watch(selectedMonthProvider);
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    final accountMap = {
      for (final a in accountsAsync.valueOrNull ?? <Account>[]) a.id: a.name,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transactions — ${_monthName(month.month)} ${month.year}',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.tune,
              color: _hasActiveFilter
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: 'Filter',
            onPressed: () => _showFilterSheet(context, accountsAsync, categoriesAsync),
          ),
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
          preferredSize: Size.fromHeight(_hasActiveFilter ? 112 : 60),
          child: Column(
            children: [
              Padding(
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
              if (_hasActiveFilter)
                SizedBox(
                  height: 44,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    scrollDirection: Axis.horizontal,
                    children: [
                      if (_filterAccountId != null)
                        _filterChip(
                          accountMap[_filterAccountId] ?? 'Account',
                          () => setState(() => _filterAccountId = null),
                        ),
                      if (_filterCategoryId != null)
                        _filterChip(
                          categoriesAsync.valueOrNull
                                  ?.firstWhere(
                                    (c) => c.id == _filterCategoryId,
                                    orElse: () => categoriesAsync
                                        .valueOrNull!.first,
                                  )
                                  .name ??
                              'Category',
                          () => setState(() => _filterCategoryId = null),
                        ),
                      if (_filterMinCents != null)
                        _filterChip(
                          'Min \$${(_filterMinCents! / 100).toStringAsFixed(0)}',
                          () => setState(() => _filterMinCents = null),
                        ),
                      if (_filterMaxCents != null)
                        _filterChip(
                          'Max \$${(_filterMaxCents! / 100).toStringAsFixed(0)}',
                          () => setState(() => _filterMaxCents = null),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: txAsync.when(
        data: (txs) {
          final filtered = txs.where((t) {
            if (_searchQuery.isNotEmpty &&
                !t.payee.toLowerCase().contains(_searchQuery) &&
                !(t.memo?.toLowerCase().contains(_searchQuery) ?? false)) {
              return false;
            }
            if (_filterAccountId != null && t.accountId != _filterAccountId) {
              return false;
            }
            if (_filterCategoryId != null &&
                t.categoryId != _filterCategoryId) {
              return false;
            }
            if (_filterMinCents != null &&
                t.amountCents.abs() < _filterMinCents!) {
              return false;
            }
            if (_filterMaxCents != null &&
                t.amountCents.abs() > _filterMaxCents!) {
              return false;
            }
            return true;
          }).toList();

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
                    _searchQuery.isEmpty && !_hasActiveFilter
                        ? 'No transactions this month.\nTap + to add one.'
                        : 'No results for current filters.',
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

  Widget _filterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onDeleted: onRemove,
        deleteIcon: const Icon(Icons.close, size: 14),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    AsyncValue<List<Account>> accountsAsync,
    AsyncValue<List<Category>> categoriesAsync,
  ) {
    int? tempAccountId = _filterAccountId;
    int? tempCategoryId = _filterCategoryId;
    final minController = TextEditingController(
      text: _filterMinCents != null
          ? (_filterMinCents! / 100).toStringAsFixed(0)
          : '',
    );
    final maxController = TextEditingController(
      text: _filterMaxCents != null
          ? (_filterMaxCents! / 100).toStringAsFixed(0)
          : '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Account filter
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: DropdownButton<int?>(
                  value: tempAccountId,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: const Text('All accounts'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All accounts'),
                    ),
                    ...accountsAsync.valueOrNull?.map(
                          (a) => DropdownMenuItem<int?>(
                            value: a.id,
                            child: Text(a.name),
                          ),
                        ) ??
                        [],
                  ],
                  onChanged: (v) => setModalState(() => tempAccountId = v),
                ),
              ),
              const SizedBox(height: 12),

              // Category filter
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: DropdownButton<int?>(
                  value: tempCategoryId,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: const Text('All categories'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All categories'),
                    ),
                    ...categoriesAsync.valueOrNull?.map(
                          (c) => DropdownMenuItem<int?>(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ) ??
                        [],
                  ],
                  onChanged: (v) => setModalState(() => tempCategoryId = v),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minController,
                      decoration: const InputDecoration(
                        labelText: 'Min amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: maxController,
                      decoration: const InputDecoration(
                        labelText: 'Max amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _filterAccountId = null;
                          _filterCategoryId = null;
                          _filterMinCents = null;
                          _filterMaxCents = null;
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final minVal = double.tryParse(minController.text);
                        final maxVal = double.tryParse(maxController.text);
                        setState(() {
                          _filterAccountId = tempAccountId;
                          _filterCategoryId = tempCategoryId;
                          _filterMinCents =
                              minVal != null ? (minVal * 100).round() : null;
                          _filterMaxCents =
                              maxVal != null ? (maxVal * 100).round() : null;
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
