import 'package:flutter_test/flutter_test.dart';
import 'package:moneyinsight/core/plaid/plaid_models.dart';
import 'package:moneyinsight/core/plaid/transaction_deduplicator.dart';

void main() {
  final baseDate = DateTime(2026, 4, 1);

  PlaidTransaction tx({
    String id = 'tx1',
    String accountId = 'acc1',
    int amountCents = 5000,
    DateTime? date,
    String payee = 'Starbucks',
  }) =>
      PlaidTransaction(
        plaidId: id,
        plaidAccountId: accountId,
        amountCents: amountCents,
        date: date ?? baseDate,
        payee: payee,
      );

  ExistingTransactionSummary existing({
    int accountId = 1,
    int amountCents = 5000,
    DateTime? date,
    String payee = 'Starbucks',
  }) =>
      ExistingTransactionSummary(
        internalAccountId: accountId,
        amountCents: amountCents,
        date: date ?? baseDate,
        payee: payee,
      );

  // Maps plaidAccountId → internal account id for these tests
  const accountMap = {'acc1': 1, 'acc2': 2};

  group('exact duplicates', () {
    test('skips transaction that exactly matches existing', () {
      final result = TransactionDeduplicator.deduplicate(
        incoming: [tx()],
        existing: [existing()],
        accountMap: accountMap,
      );
      expect(result.toInsert, isEmpty);
      expect(result.flagged, isEmpty);
      expect(result.skippedCount, 1);
    });

    test('passes through transaction with no match', () {
      final result = TransactionDeduplicator.deduplicate(
        incoming: [tx(payee: 'Amazon')],
        existing: [existing(payee: 'Starbucks')],
        accountMap: accountMap,
      );
      expect(result.toInsert, hasLength(1));
      expect(result.flagged, isEmpty);
    });
  });

  group('near duplicates', () {
    test('flags transaction with same amount/account, different payee, within 3 days', () {
      final result = TransactionDeduplicator.deduplicate(
        incoming: [tx(date: baseDate.add(const Duration(days: 2)), payee: 'BOA AUTOPAY')],
        existing: [existing(payee: 'Starbucks')],
        accountMap: accountMap,
      );
      expect(result.flagged, hasLength(1));
      expect(result.flagged.first.reason, FlagReason.duplicateSuspected);
      expect(result.toInsert, isEmpty);
    });

    test('does not flag if date difference is more than 3 days', () {
      final result = TransactionDeduplicator.deduplicate(
        incoming: [tx(date: baseDate.add(const Duration(days: 4)), payee: 'BOA AUTOPAY')],
        existing: [existing(payee: 'Starbucks')],
        accountMap: accountMap,
      );
      expect(result.flagged, isEmpty);
      expect(result.toInsert, hasLength(1));
    });

    test('does not flag if account ids differ', () {
      final result = TransactionDeduplicator.deduplicate(
        incoming: [tx(accountId: 'acc2')], // maps to internalAccountId=2
        existing: [existing(accountId: 1)],
        accountMap: accountMap,
      );
      expect(result.flagged, isEmpty);
      expect(result.toInsert, hasLength(1));
    });
  });

  group('unknown account', () {
    test('skips transaction if plaidAccountId not in accountMap', () {
      final result = TransactionDeduplicator.deduplicate(
        incoming: [tx(accountId: 'acc_unknown')],
        existing: [],
        accountMap: accountMap,
      );
      expect(result.toInsert, isEmpty);
      expect(result.flagged, isEmpty);
      expect(result.skippedCount, 1);
    });
  });
}
