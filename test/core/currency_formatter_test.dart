import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats positive cents as dollars', () {
      expect(CurrencyFormatter.format(100000), r'$1,000.00');
    });

    test('formats zero', () {
      expect(CurrencyFormatter.format(0), r'$0.00');
    });

    test('converts dollars to cents correctly', () {
      expect(CurrencyFormatter.toCents(49.99), 4999);
    });

    test('converts cents to dollars correctly', () {
      expect(CurrencyFormatter.toDollars(4999), closeTo(49.99, 0.001));
    });

    test('handles large amounts', () {
      expect(CurrencyFormatter.format(1000000), r'$10,000.00');
    });

    test('toCents rounds correctly for floating point', () {
      // 0.1 + 0.2 = 0.30000000000000004 in floating point
      expect(CurrencyFormatter.toCents(0.1 + 0.2), 30);
    });
  });
}
