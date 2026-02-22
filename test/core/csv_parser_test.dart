import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/core/csv/csv_parser.dart';

void main() {
  const sampleCsv = 'Date,Description,Amount\n'
      '2026-02-01,Grocery Store,-49.99\n'
      '2026-02-03,Paycheck,2500.00\n'
      '2026-02-05,Electric Bill,-85.00';

  group('CsvParser.parse', () {
    test('parses correct number of rows', () {
      final rows = CsvParser.parse(sampleCsv);
      expect(rows.length, 3);
    });

    test('parses row values correctly', () {
      final rows = CsvParser.parse(sampleCsv);
      expect(rows[0]['Date'], '2026-02-01');
      expect(rows[0]['Description'], 'Grocery Store');
      expect(rows[0]['Amount'], '-49.99');
    });
  });

  group('CsvParser.detectHeaders', () {
    test('returns correct headers', () {
      final headers = CsvParser.detectHeaders(sampleCsv);
      expect(headers, containsAll(['Date', 'Description', 'Amount']));
    });
  });

  group('CsvParser.toTransactionData', () {
    test('converts row to transaction correctly', () {
      final rows = CsvParser.parse(sampleCsv);
      final tx = CsvParser.toTransactionData(
        row: rows[0],
        dateColumn: 'Date',
        amountColumn: 'Amount',
        payeeColumn: 'Description',
      );
      expect(tx.payee, 'Grocery Store');
      expect(tx.amountCents, -4999);
      expect(tx.date, DateTime(2026, 2, 1));
    });

    test('handles US date format MM/DD/YYYY', () {
      const usCsv = 'Date,Desc,Amt\n02/15/2026,Store,10.00';
      final rows = CsvParser.parse(usCsv);
      final tx = CsvParser.toTransactionData(
        row: rows[0],
        dateColumn: 'Date',
        amountColumn: 'Amt',
        payeeColumn: 'Desc',
      );
      expect(tx.date, DateTime(2026, 2, 15));
    });
  });

  group('CsvParser.validate', () {
    test('returns valid for good row', () {
      final rows = CsvParser.parse(sampleCsv);
      final result = CsvParser.validate(
        rows[0],
        dateColumn: 'Date',
        amountColumn: 'Amount',
      );
      expect(result.isValid, true);
    });

    test('flags invalid date', () {
      const badCsv = 'Date,Desc,Amount\nnot-a-date,Store,10.00';
      final rows = CsvParser.parse(badCsv);
      final result = CsvParser.validate(
        rows[0],
        dateColumn: 'Date',
        amountColumn: 'Amount',
      );
      expect(result.isValid, false);
      expect(result.error, contains('date'));
    });

    test('flags invalid amount', () {
      const badCsv = 'Date,Desc,Amount\n2026-02-01,Store,abc';
      final rows = CsvParser.parse(badCsv);
      final result = CsvParser.validate(
        rows[0],
        dateColumn: 'Date',
        amountColumn: 'Amount',
      );
      expect(result.isValid, false);
      expect(result.error, contains('amount'));
    });
  });
}
