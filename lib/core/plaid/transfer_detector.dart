import 'plaid_models.dart';

class TransferDetectionResult {
  final List<PlaidTransactionPair> autoTaggedTransfers;
  final List<PlaidTransactionPair> ambiguousTransfers;
  final List<PlaidTransaction> regularTransactions;

  const TransferDetectionResult({
    required this.autoTaggedTransfers,
    required this.ambiguousTransfers,
    required this.regularTransactions,
  });
}

/// Pure transfer detection logic — no Flutter or database dependencies.
/// Matches debit/credit pairs across different accounts within a time window.
class TransferDetector {
  /// Auto-tags same-day / next-day pairs as transfers.
  /// Flags 2–3 day pairs as ambiguous.
  /// Leaves everything else as regular income/expense.
  static TransferDetectionResult detect(List<PlaidTransaction> transactions) {
    final autoTagged = <PlaidTransactionPair>[];
    final ambiguous = <PlaidTransactionPair>[];
    final matchedIds = <String>{};

    // Positive amountCents = debit (money out). Negative = credit (money in).
    final debits = transactions.where((t) => t.amountCents > 0).toList();
    final credits = transactions.where((t) => t.amountCents < 0).toList();

    for (final debit in debits) {
      if (matchedIds.contains(debit.plaidId)) continue;

      // Find a credit from a different account with matching absolute amount
      final candidates = credits.where((c) =>
          !matchedIds.contains(c.plaidId) &&
          c.amountCents.abs() == debit.amountCents &&
          c.plaidAccountId != debit.plaidAccountId);

      PlaidTransaction? sameDayOrNext;
      PlaidTransaction? withinThreeDays;

      for (final c in candidates) {
        final dayDiff = c.date.difference(debit.date).inDays.abs();
        if (dayDiff <= 1) {
          sameDayOrNext = c;
          break;
        } else if (dayDiff <= 3) {
          withinThreeDays ??= c;
        }
      }

      final match = sameDayOrNext ?? withinThreeDays;
      if (match == null) continue;

      final pair = PlaidTransactionPair(debit: debit, credit: match);
      matchedIds.add(debit.plaidId);
      matchedIds.add(match.plaidId);

      if (sameDayOrNext != null) {
        autoTagged.add(pair);
      } else {
        ambiguous.add(pair);
      }
    }

    final remaining = transactions
        .where((t) => !matchedIds.contains(t.plaidId))
        .toList();

    return TransferDetectionResult(
      autoTaggedTransfers: autoTagged,
      ambiguousTransfers: ambiguous,
      regularTransactions: remaining,
    );
  }
}
