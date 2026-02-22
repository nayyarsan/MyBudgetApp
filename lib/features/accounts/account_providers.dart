import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';

final accountsProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.accountsDao.watchAllAccounts();
});

/// Total of all account balances — positive accounts minus credit card balances.
final netWorthProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(accountsProvider).whenData((accounts) {
    var total = 0;
    for (final a in accounts) {
      total += a.balanceCents;
    }
    return total;
  });
});
