import 'package:flutter_test/flutter_test.dart';
import 'package:moneyinsight/core/plaid/plaid_models.dart';
import 'package:moneyinsight/core/plaid/transfer_detector.dart';

void main() {
  final baseDate = DateTime(2026, 4, 1);

  PlaidTransaction tx({
    required String id,
    required String accountId,
    required int amountCents,
    DateTime? date,
    String payee = 'Transfer',
  }) =>
      PlaidTransaction(
        plaidId: id,
        plaidAccountId: accountId,
        amountCents: amountCents,
        date: date ?? baseDate,
        payee: payee,
      );

  group('auto-tagged transfers', () {
    test('same-day opposite-sign same-amount across accounts → auto-tag', () {
      final debit = tx(id: 'd1', accountId: 'checking', amountCents: 50000);
      final credit = tx(id: 'c1', accountId: 'creditcard', amountCents: -50000);
      final result = TransferDetector.detect([debit, credit]);

      expect(result.autoTaggedTransfers, hasLength(1));
      expect(result.autoTaggedTransfers.first.debit.plaidId, 'd1');
      expect(result.autoTaggedTransfers.first.credit.plaidId, 'c1');
      expect(result.ambiguousTransfers, isEmpty);
      expect(result.regularTransactions, isEmpty);
    });

    test('next-day match → auto-tag', () {
      final debit = tx(id: 'd1', accountId: 'checking', amountCents: 50000);
      final credit = tx(
        id: 'c1',
        accountId: 'creditcard',
        amountCents: -50000,
        date: baseDate.add(const Duration(days: 1)),
      );
      final result = TransferDetector.detect([debit, credit]);

      expect(result.autoTaggedTransfers, hasLength(1));
      expect(result.ambiguousTransfers, isEmpty);
    });
  });

  group('ambiguous transfers', () {
    test('2-day gap → ambiguous', () {
      final debit = tx(id: 'd1', accountId: 'checking', amountCents: 50000);
      final credit = tx(
        id: 'c1',
        accountId: 'creditcard',
        amountCents: -50000,
        date: baseDate.add(const Duration(days: 2)),
      );
      final result = TransferDetector.detect([debit, credit]);

      expect(result.ambiguousTransfers, hasLength(1));
      expect(result.autoTaggedTransfers, isEmpty);
    });

    test('3-day gap → ambiguous', () {
      final debit = tx(id: 'd1', accountId: 'checking', amountCents: 50000);
      final credit = tx(
        id: 'c1',
        accountId: 'creditcard',
        amountCents: -50000,
        date: baseDate.add(const Duration(days: 3)),
      );
      final result = TransferDetector.detect([debit, credit]);

      expect(result.ambiguousTransfers, hasLength(1));
    });

    test('4-day gap → regular transactions (no match)', () {
      final debit = tx(id: 'd1', accountId: 'checking', amountCents: 50000);
      final credit = tx(
        id: 'c1',
        accountId: 'creditcard',
        amountCents: -50000,
        date: baseDate.add(const Duration(days: 4)),
      );
      final result = TransferDetector.detect([debit, credit]);

      expect(result.ambiguousTransfers, isEmpty);
      expect(result.autoTaggedTransfers, isEmpty);
      expect(result.regularTransactions, hasLength(2));
    });
  });

  group('no transfer', () {
    test('same account → not a transfer', () {
      final debit = tx(id: 'd1', accountId: 'checking', amountCents: 50000);
      final credit = tx(id: 'c1', accountId: 'checking', amountCents: -50000);
      final result = TransferDetector.detect([debit, credit]);

      expect(result.autoTaggedTransfers, isEmpty);
      expect(result.ambiguousTransfers, isEmpty);
      expect(result.regularTransactions, hasLength(2));
    });

    test('different amounts → not a transfer', () {
      final debit = tx(id: 'd1', accountId: 'checking', amountCents: 50000);
      final credit = tx(id: 'c1', accountId: 'creditcard', amountCents: -49900);
      final result = TransferDetector.detect([debit, credit]);

      expect(result.autoTaggedTransfers, isEmpty);
      expect(result.regularTransactions, hasLength(2));
    });
  });

  group('non-transfer transactions pass through', () {
    test('regular expense stays in regularTransactions', () {
      final expense = tx(id: 'e1', accountId: 'checking', amountCents: 1500, payee: 'Netflix');
      final result = TransferDetector.detect([expense]);

      expect(result.regularTransactions, hasLength(1));
      expect(result.regularTransactions.first.plaidId, 'e1');
    });
  });
}
