import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../../core/plaid/plaid_models.dart';
import '../../core/plaid/plaid_service.dart';
import '../../core/plaid/transaction_deduplicator.dart';
import '../../core/plaid/transfer_detector.dart';

final plaidServiceProvider = Provider<PlaidService>((_) => PlaidService());

/// Emits the count of transactions pending review (0 if none).
final pendingReviewCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.plaidDao
      .watchPendingReview()
      .map((rows) => rows.length);
});

/// State for the current sync operation.
enum SyncStatus { idle, syncing, done, error }

class BankSyncNotifier extends AsyncNotifier<SyncStatus> {
  @override
  Future<SyncStatus> build() async => SyncStatus.idle;

  Future<void> sync() async {
    if (state.value == SyncStatus.syncing) return;
    state = const AsyncValue.data(SyncStatus.syncing);

    try {
      await _runSync();
      state = const AsyncValue.data(SyncStatus.done);
    } catch (e, st) {
      debugPrint('BankSyncNotifier.sync error: $e\n$st');
      state = const AsyncValue.data(SyncStatus.error);
    }
  }

  Future<void> _runSync() async {
    final db = ref.read(databaseProvider);
    final plaidService = ref.read(plaidServiceProvider);

    // 1. Fetch from Plaid
    final fetchResult = await plaidService.fetchTransactions();
    if (!fetchResult.connected || fetchResult.transactions.isEmpty) return;

    // 2. Build plaidAccountId → internalAccountId map from PlaidAccounts table
    final plaidAccounts = await db.plaidDao.getAllPlaidAccounts();
    final accountMap = {
      for (final pa in plaidAccounts)
        pa.plaidAccountId: pa.internalAccountId,
    };

    // 3. Load recent existing transactions for dedup window (last 7 days)
    final since = DateTime.now().subtract(const Duration(days: 7));
    final existingTxs = await db.transactionsDao.getTransactionsForMonth(
      since,
      DateTime.now().add(const Duration(days: 1)),
    );
    final existingSummaries = existingTxs.map((t) => ExistingTransactionSummary(
      internalAccountId: t.accountId,
      amountCents: t.amountCents.abs(),
      date: t.date,
      payee: t.payee,
    )).toList();

    // 4. Deduplicate
    final dedupResult = TransactionDeduplicator.deduplicate(
      incoming: fetchResult.transactions,
      existing: existingSummaries,
      accountMap: accountMap,
    );

    // 5. Transfer detection on survivors
    final transferResult = TransferDetector.detect(dedupResult.toInsert);

    // 6. Insert auto-tagged transfers
    for (final pair in transferResult.autoTaggedTransfers) {
      final debitAccountId = accountMap[pair.debit.plaidAccountId]!;
      final creditAccountId = accountMap[pair.credit.plaidAccountId]!;
      await db.transactionsDao.insertTransaction(TransactionsCompanion(
        accountId: Value(debitAccountId),
        amountCents: Value(pair.debit.amountCents),
        date: Value(pair.debit.date),
        payee: Value(pair.debit.payee),
        type: const Value('transfer'),
        toAccountId: Value(creditAccountId),
        importedFrom: const Value('plaid'),
      ));
    }

    // 7. Insert regular transactions
    for (final tx in transferResult.regularTransactions) {
      final internalAccountId = accountMap[tx.plaidAccountId]!;
      final type = tx.amountCents > 0 ? 'expense' : 'income';
      await db.transactionsDao.insertTransaction(TransactionsCompanion(
        accountId: Value(internalAccountId),
        amountCents: Value(tx.amountCents.abs()),
        date: Value(tx.date),
        payee: Value(tx.payee),
        memo: Value(tx.memo),
        type: Value(type),
        importedFrom: const Value('plaid'),
      ));
    }

    // 8. Queue ambiguous transfers for review
    for (final pair in transferResult.ambiguousTransfers) {
      final already = await db.plaidDao
          .isPendingReviewExists(pair.debit.plaidId);
      if (!already) {
        await db.plaidDao.insertPendingReview(PendingReviewTransactionsCompanion(
          plaidTransactionId: Value(pair.debit.plaidId),
          accountId: Value(accountMap[pair.debit.plaidAccountId]!),
          amountCents: Value(pair.debit.amountCents),
          date: Value(pair.debit.date),
          payee: Value(pair.debit.payee),
          reason: const Value('ambiguous_transfer'),
          pairedPlaidTransactionId: Value(pair.credit.plaidId),
        ));
      }
    }

    // 9. Queue suspected duplicates for review
    for (final flagged in dedupResult.flagged) {
      final already = await db.plaidDao
          .isPendingReviewExists(flagged.transaction.plaidId);
      if (!already) {
        await db.plaidDao.insertPendingReview(PendingReviewTransactionsCompanion(
          plaidTransactionId: Value(flagged.transaction.plaidId),
          accountId: Value(accountMap[flagged.transaction.plaidAccountId]!),
          amountCents: Value(flagged.transaction.amountCents),
          date: Value(flagged.transaction.date),
          payee: Value(flagged.transaction.payee),
          reason: const Value('duplicate_suspected'),
        ));
      }
    }

    // 10. Mark sync complete
    await plaidService.markSyncComplete();

    // 11. Update syncedAt on all connected plaid accounts
    for (final pa in plaidAccounts) {
      await db.plaidDao.updateSyncedAt(pa.id, DateTime.now());
    }
  }
}

final bankSyncProvider =
    AsyncNotifierProvider<BankSyncNotifier, SyncStatus>(BankSyncNotifier.new);
