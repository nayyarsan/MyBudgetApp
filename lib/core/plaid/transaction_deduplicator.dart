import 'plaid_models.dart';

class DeduplicationResult {
  final List<PlaidTransaction> toInsert;
  final List<FlaggedPlaidTransaction> flagged;
  final int skippedCount;

  const DeduplicationResult({
    required this.toInsert,
    required this.flagged,
    required this.skippedCount,
  });
}

/// Pure deduplication logic — no Flutter or database dependencies.
/// Compares incoming Plaid transactions against existing Drift transactions.
class TransactionDeduplicator {
  /// [incoming] — transactions from Plaid
  /// [existing] — summarized transactions already in Drift DB
  /// [accountMap] — maps plaidAccountId → internalAccountId
  static DeduplicationResult deduplicate({
    required List<PlaidTransaction> incoming,
    required List<ExistingTransactionSummary> existing,
    required Map<String, int> accountMap,
  }) {
    final toInsert = <PlaidTransaction>[];
    final flagged = <FlaggedPlaidTransaction>[];
    int skipped = 0;

    for (final tx in incoming) {
      final internalId = accountMap[tx.plaidAccountId];
      if (internalId == null) {
        // Unknown account — skip until user maps it
        skipped++;
        continue;
      }

      final absAmount = tx.amountCents.abs();

      // Exact match: same payee, amount, date, account → silent skip
      final isExact = existing.any((e) =>
          e.internalAccountId == internalId &&
          e.amountCents == absAmount &&
          e.payee == tx.payee &&
          _sameDay(e.date, tx.date));

      if (isExact) {
        skipped++;
        continue;
      }

      // Near match: same amount + account, date within ±3 days (but not same day), different payee → flag
      final isNear = existing.any((e) {
        final daysDiff = e.date.difference(tx.date).inDays.abs();
        return e.internalAccountId == internalId &&
            e.amountCents == absAmount &&
            e.payee != tx.payee &&
            daysDiff > 0 &&
            daysDiff <= 3;
      });

      if (isNear) {
        flagged.add(FlaggedPlaidTransaction(
          transaction: tx,
          reason: FlagReason.duplicateSuspected,
        ));
        continue;
      }

      toInsert.add(tx);
    }

    return DeduplicationResult(
      toInsert: toInsert,
      flagged: flagged,
      skippedCount: skipped,
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
