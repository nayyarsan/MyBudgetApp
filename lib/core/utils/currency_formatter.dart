import 'package:intl/intl.dart';

/// Utility for formatting and converting USD amounts.
/// All monetary values in the app are stored as integer cents
/// to avoid floating-point precision errors.
class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    symbol: r'$',
    decimalDigits: 2,
  );

  /// Format integer cents as a dollar string (e.g. 4999 → "$49.99")
  static String format(int cents) {
    final dollars = cents / 100.0;
    return _formatter.format(dollars);
  }

  /// Convert a dollar amount to integer cents (e.g. 49.99 → 4999)
  static int toCents(double dollars) => (dollars * 100).round();

  /// Convert integer cents to a double dollar amount
  static double toDollars(int cents) => cents / 100.0;
}
