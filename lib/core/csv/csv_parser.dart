import 'package:csv/csv.dart';
import '../utils/currency_formatter.dart';

/// A single parsed transaction row from a CSV file.
class ParsedTransaction {
  final String payee;
  final int amountCents;
  final DateTime date;
  final String? memo;

  const ParsedTransaction({
    required this.payee,
    required this.amountCents,
    required this.date,
    this.memo,
  });
}

/// Result of validating a CSV row.
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult({required this.isValid, this.error});
}

/// Pure CSV parsing utility — no Flutter or database dependencies.
class CsvParser {
  /// Parse CSV content into a list of column-name → value maps.
  static List<Map<String, String>> parse(String csvContent) {
    final normalized = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = const CsvToListConverter(eol: '\n').convert(normalized);
    if (rows.isEmpty) return [];

    final headers =
        rows.first.map((e) => e.toString().trim()).toList();

    return rows.skip(1).where((row) => row.isNotEmpty).map((row) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length && i < row.length; i++) {
        map[headers[i]] = row[i].toString().trim();
      }
      return map;
    }).toList();
  }

  /// Return the column headers detected from the CSV.
  static List<String> detectHeaders(String csvContent) {
    final normalized = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = const CsvToListConverter(eol: '\n').convert(normalized);
    if (rows.isEmpty) return [];
    return rows.first.map((e) => e.toString().trim()).toList();
  }

  /// Convert a parsed row into a [ParsedTransaction].
  static ParsedTransaction toTransactionData({
    required Map<String, String> row,
    required String dateColumn,
    required String amountColumn,
    required String payeeColumn,
    String? memoColumn,
  }) {
    final dateStr = row[dateColumn] ?? '';
    final amountStr =
        (row[amountColumn] ?? '0').replaceAll(',', '').replaceAll(r'$', '');
    final dollars = double.tryParse(amountStr) ?? 0;
    final date = _parseDate(dateStr) ?? DateTime.now();

    return ParsedTransaction(
      payee: row[payeeColumn] ?? '',
      amountCents: CurrencyFormatter.toCents(dollars),
      date: date,
      memo: memoColumn != null ? row[memoColumn] : null,
    );
  }

  /// Validate a row has parseable date and amount.
  static ValidationResult validate(
    Map<String, String> row, {
    required String dateColumn,
    required String amountColumn,
  }) {
    final dateStr = row[dateColumn] ?? '';
    final amountStr =
        (row[amountColumn] ?? '').replaceAll(',', '').replaceAll(r'$', '');

    if (_parseDate(dateStr) == null) {
      return ValidationResult(
        isValid: false,
        error: 'Invalid date: "$dateStr"',
      );
    }
    if (double.tryParse(amountStr) == null) {
      return ValidationResult(
        isValid: false,
        error: 'Invalid amount: "$amountStr"',
      );
    }
    return const ValidationResult(isValid: true);
  }

  static DateTime? _parseDate(String s) {
    if (s.isEmpty) return null;
    return DateTime.tryParse(s) ?? _tryUsFormat(s);
  }

  /// Try parsing MM/DD/YYYY or MM-DD-YYYY formats common in US bank exports.
  static DateTime? _tryUsFormat(String s) {
    final parts = s.split(RegExp(r'[/\-]'));
    if (parts.length == 3) {
      final m = int.tryParse(parts[0]);
      final d = int.tryParse(parts[1]);
      final y = int.tryParse(parts[2]);
      if (m != null && d != null && y != null) {
        return DateTime.tryParse(
          '${y.toString().padLeft(4, '0')}-'
          '${m.toString().padLeft(2, '0')}-'
          '${d.toString().padLeft(2, '0')}',
        );
      }
    }
    return null;
  }
}
