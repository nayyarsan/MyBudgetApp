import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';

final accountsProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.accountsDao.watchAllAccounts();
});

/// Stream of all non-deleted transactions (used for running balance calc).
final _allTransactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(databaseProvider).transactionsDao.watchAllTransactions();
});

/// Map of accountId → current running balance (opening balance + transactions).
final accountRunningBalancesProvider = Provider<AsyncValue<Map<int, int>>>((ref) {
  final accountsAsync = ref.watch(accountsProvider);
  final allTxAsync = ref.watch(_allTransactionsStreamProvider);

  if (accountsAsync is AsyncLoading || allTxAsync is AsyncLoading) {
    return const AsyncLoading();
  }

  final accounts = accountsAsync.valueOrNull ?? [];
  final allTxs = allTxAsync.valueOrNull ?? [];

  final map = <int, int>{};
  for (final a in accounts) {
    final txSum = allTxs
        .where((t) => t.accountId == a.id)
        .fold<int>(0, (s, t) => s + t.amountCents);
    map[a.id] = a.balanceCents + txSum;
  }
  return AsyncData(map);
});

/// Net worth = sum of all account running balances.
final netWorthProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(accountRunningBalancesProvider).whenData(
        (map) => map.values.fold<int>(0, (s, b) => s + b),
      );
});
