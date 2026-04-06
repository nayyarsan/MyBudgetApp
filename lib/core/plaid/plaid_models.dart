/// A transaction returned by Plaid's API (mapped from Cloud Function response).
/// amountCents: positive = money leaving account (debit/expense),
///              negative = money entering account (credit/income).
class PlaidTransaction {
  final String plaidId;
  final String plaidAccountId; // Plaid's account_id
  final int amountCents;
  final DateTime date;
  final String payee;
  final String? memo;

  const PlaidTransaction({
    required this.plaidId,
    required this.plaidAccountId,
    required this.amountCents,
    required this.date,
    required this.payee,
    this.memo,
  });

  factory PlaidTransaction.fromJson(Map<String, dynamic> json) {
    return PlaidTransaction(
      plaidId: json['plaidId'] as String,
      plaidAccountId: json['plaidAccountId'] as String,
      amountCents: json['amountCents'] as int,
      date: DateTime.parse(json['date'] as String),
      payee: json['payee'] as String,
      memo: json['memo'] as String?,
    );
  }
}

/// A Plaid account returned by the Cloud Function.
class PlaidAccount {
  final String plaidAccountId;
  final String name;
  final String? mask;
  final String type; // depository, credit
  final String? subtype; // checking, savings, credit card

  const PlaidAccount({
    required this.plaidAccountId,
    required this.name,
    this.mask,
    required this.type,
    this.subtype,
  });

  factory PlaidAccount.fromJson(Map<String, dynamic> json) {
    return PlaidAccount(
      plaidAccountId: json['plaidAccountId'] as String,
      name: json['name'] as String,
      mask: json['mask'] as String?,
      type: json['type'] as String,
      subtype: json['subtype'] as String?,
    );
  }
}

/// Summary of a transaction already stored in Drift — used for deduplication.
class ExistingTransactionSummary {
  final int internalAccountId;
  final int amountCents;
  final DateTime date;
  final String payee;

  const ExistingTransactionSummary({
    required this.internalAccountId,
    required this.amountCents,
    required this.date,
    required this.payee,
  });
}

/// Reason a transaction was flagged for review.
enum FlagReason { duplicateSuspected, ambiguousTransfer }

/// A transaction flagged during deduplication or transfer detection.
class FlaggedPlaidTransaction {
  final PlaidTransaction transaction;
  final FlagReason reason;
  final PlaidTransaction? pair; // set for ambiguousTransfer pairs

  const FlaggedPlaidTransaction({
    required this.transaction,
    required this.reason,
    this.pair,
  });
}

/// Result from the full fetch + dedup + transfer pipeline.
class PlaidSyncResult {
  final List<PlaidTransaction> toInsertAsExpenseOrIncome;
  final List<PlaidTransactionPair> autoTaggedTransfers;
  final List<FlaggedPlaidTransaction> flagged;
  final int skippedDuplicates;

  const PlaidSyncResult({
    required this.toInsertAsExpenseOrIncome,
    required this.autoTaggedTransfers,
    required this.flagged,
    required this.skippedDuplicates,
  });
}

/// A matched transfer pair (debit leg + credit leg).
class PlaidTransactionPair {
  final PlaidTransaction debit; // money leaving account (amountCents > 0)
  final PlaidTransaction credit; // money entering account (amountCents < 0)

  const PlaidTransactionPair({required this.debit, required this.credit});
}
