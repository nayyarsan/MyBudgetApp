import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/csv/csv_parser.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';

class ImportCsvScreen extends ConsumerStatefulWidget {
  const ImportCsvScreen({super.key});

  @override
  ConsumerState<ImportCsvScreen> createState() => _ImportCsvScreenState();
}

class _ImportCsvScreenState extends ConsumerState<ImportCsvScreen> {
  List<String> _headers = [];
  List<Map<String, String>> _rows = [];
  String? _dateCol, _amountCol, _payeeCol;
  bool _loading = false;
  String? _error;
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );
    if (result == null) return;

    final path = result.files.single.path;
    if (path == null) return;

    try {
      final content = await File(path).readAsString();
      final headers = CsvParser.detectHeaders(content);
      final rows = CsvParser.parse(content);

      setState(() {
        _headers = headers;
        _rows = rows;
        _fileName = result.files.single.name;
        _error = null;
        // Auto-detect common column names
        _dateCol = _findHeader(['date', 'Date', 'DATE', 'Transaction Date']);
        _amountCol = _findHeader(['amount', 'Amount', 'AMOUNT', 'Debit', 'Credit']);
        _payeeCol = _findHeader(['description', 'Description', 'payee', 'Payee', 'Merchant']);
      });
    } catch (e) {
      setState(() => _error = 'Failed to read file: $e');
    }
  }

  String? _findHeader(List<String> candidates) {
    for (final c in candidates) {
      if (_headers.contains(c)) return c;
    }
    return null;
  }

  Future<void> _import() async {
    if (_dateCol == null || _amountCol == null || _payeeCol == null) {
      setState(() => _error = 'Please map all required columns (Date, Amount, Payee).');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final db = ref.read(databaseProvider);
    final accounts = await db.accountsDao.getAllAccounts();
    final accountId = accounts.isNotEmpty ? accounts.first.id : 1;

    var imported = 0;
    var skipped = 0;

    for (final row in _rows) {
      final validation = CsvParser.validate(
        row,
        dateColumn: _dateCol!,
        amountColumn: _amountCol!,
      );
      if (!validation.isValid) {
        skipped++;
        continue;
      }

      final tx = CsvParser.toTransactionData(
        row: row,
        dateColumn: _dateCol!,
        amountColumn: _amountCol!,
        payeeColumn: _payeeCol!,
      );

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          accountId: accountId,
          amountCents: tx.amountCents,
          payee: tx.payee,
          date: tx.date,
          type: tx.amountCents >= 0 ? 'income' : 'expense',
          memo: Value(tx.memo),
          importedFrom: const Value('csv'),
        ),
      );
      imported++;
    }

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported $imported transactions'
            '${skipped > 0 ? ' ($skipped skipped)' : ''}.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import CSV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step 1: Pick file
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step 1: Choose your bank CSV export',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: _pickFile,
                      child: const Text('Choose CSV File'),
                    ),
                    if (_fileName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '📄 $_fileName (${_rows.length} rows)',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (_headers.isNotEmpty) ...[
              const SizedBox(height: 12),

              // Step 2: Map columns
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 2: Map columns',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 12),
                      _columnDropdown('Date Column *', _dateCol,
                          (v) => setState(() => _dateCol = v)),
                      const SizedBox(height: 8),
                      _columnDropdown('Amount Column *', _amountCol,
                          (v) => setState(() => _amountCol = v)),
                      const SizedBox(height: 8),
                      _columnDropdown('Payee Column *', _payeeCol,
                          (v) => setState(() => _payeeCol = v)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Step 3: Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step 3: Preview (first 3 rows)',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ..._rows.take(3).map(
                            (row) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                row.entries
                                    .map((e) => '${e.key}: ${e.value}')
                                    .join('  |  '),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ],

            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ],

            const Spacer(),

            if (_headers.isNotEmpty)
              FilledButton.icon(
                onPressed: _loading ? null : _import,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload),
                label:
                    Text(_loading ? 'Importing…' : 'Import Transactions'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _columnDropdown(
    String label,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      value: value,
      hint: const Text('Select column'),
      items: _headers
          .map((h) => DropdownMenuItem(value: h, child: Text(h)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
