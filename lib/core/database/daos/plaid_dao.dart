import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'plaid_dao.g.dart';

@DriftAccessor(tables: [PlaidAccounts, PendingReviewTransactions])
class PlaidDao extends DatabaseAccessor<AppDatabase>
    with _$PlaidDaoMixin {
  PlaidDao(super.db);

  // --- PlaidAccounts ---

  Future<List<PlaidAccount>> getAllPlaidAccounts() =>
      select(plaidAccounts).get();

  Future<PlaidAccount?> getByPlaidAccountId(String plaidAccountId) =>
      (select(plaidAccounts)
            ..where((t) => t.plaidAccountId.equals(plaidAccountId)))
          .getSingleOrNull();

  Future<int> insertPlaidAccount(PlaidAccountsCompanion entry) =>
      into(plaidAccounts).insert(entry);

  Future<void> updateSyncedAt(int id, DateTime syncedAt) =>
      (update(plaidAccounts)..where((t) => t.id.equals(id))).write(
        PlaidAccountsCompanion(syncedAt: Value(syncedAt)),
      );

  Future<void> deletePlaidAccount(int id) =>
      (delete(plaidAccounts)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllPlaidAccounts() =>
      delete(plaidAccounts).go();

  // --- PendingReviewTransactions ---

  Stream<List<PendingReviewTransaction>> watchPendingReview() =>
      (select(pendingReviewTransactions)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<int> countPendingReview() async {
    final rows = await select(pendingReviewTransactions).get();
    return rows.length;
  }

  Future<int> insertPendingReview(PendingReviewTransactionsCompanion entry) =>
      into(pendingReviewTransactions).insert(entry);

  Future<void> deletePendingReview(int id) =>
      (delete(pendingReviewTransactions)..where((t) => t.id.equals(id))).go();

  Future<void> clearAllPendingReview() =>
      delete(pendingReviewTransactions).go();

  /// Returns true if a plaidTransactionId is already in pending review.
  Future<bool> isPendingReviewExists(String plaidTransactionId) async {
    final row = await (select(pendingReviewTransactions)
          ..where((t) => t.plaidTransactionId.equals(plaidTransactionId)))
        .getSingleOrNull();
    return row != null;
  }
}
