import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../../core/services/month_boundary_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../budget/budget_providers.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  /// Pass an existing transaction to switch to edit mode.
  final Transaction? initial;

  /// Pre-select an account (used when launching from AccountDetailScreen).
  final int? initialAccountId;

  const AddTransactionScreen({super.key, this.initial, this.initialAccountId});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _payeeController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _type = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  int? _toAccountId;
  bool _saving = false;
  bool _recurring = false;
  String _recurringInterval = 'monthly';

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final tx = widget.initial!;
      _payeeController.text = tx.payee;
      _amountController.text =
          (tx.amountCents.abs() / 100).toStringAsFixed(2);
      _selectedDate = tx.date;
      _type = tx.type;
      _selectedCategoryId = tx.categoryId;
      _selectedAccountId = tx.accountId;
      _toAccountId = tx.toAccountId;
      _memoController.text = tx.memo ?? '';
      _recurring = tx.recurring;
      _recurringInterval = tx.recurringInterval ?? 'monthly';
    } else if (widget.initialAccountId != null) {
      _selectedAccountId = widget.initialAccountId;
    }
  }

  @override
  void dispose() {
    _payeeController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final amountText =
        _amountController.text.replaceAll(',', '').trim();
    final dollars = double.tryParse(amountText) ?? 0;
    // Expenses are stored as negative cents; income as positive
    final cents = CurrencyFormatter.toCents(dollars) *
        (_type == 'expense' ? -1 : 1);

    final db = ref.read(databaseProvider);
    final accounts = await db.accountsDao.getAllAccounts();
    final accountId =
        _selectedAccountId ?? (accounts.isNotEmpty ? accounts.first.id : 1);

    // Compute nextDueDate for new recurring transactions
    DateTime? nextDueDate;
    if (_recurring) {
      nextDueDate = MonthBoundaryService.computeNextDueDate(
        _selectedDate,
        _recurringInterval,
      );
    }

    if (_isEditing) {
      await db.transactionsDao.updateTransaction(
        widget.initial!.id,
        TransactionsCompanion(
          accountId: Value(accountId),
          categoryId: Value(_selectedCategoryId),
          amountCents: Value(cents),
          payee: Value(_payeeController.text.trim()),
          date: Value(_selectedDate),
          memo: Value(
            _memoController.text.trim().isEmpty
                ? null
                : _memoController.text.trim(),
          ),
          type: Value(_type),
          toAccountId: Value(_type == 'transfer' ? _toAccountId : null),
          recurring: Value(_recurring),
          recurringInterval: Value(_recurring ? _recurringInterval : null),
          nextDueDate: Value(nextDueDate),
        ),
      );
    } else {
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          accountId: accountId,
          categoryId: Value(_selectedCategoryId),
          amountCents: cents,
          payee: _payeeController.text.trim(),
          date: _selectedDate,
          memo: Value(
            _memoController.text.trim().isEmpty
                ? null
                : _memoController.text.trim(),
          ),
          type: _type,
          toAccountId: Value(_type == 'transfer' ? _toAccountId : null),
          recurring: Value(_recurring),
          recurringInterval: Value(_recurring ? _recurringInterval : null),
          nextDueDate: Value(nextDueDate),
        ),
      );
    }

    if (mounted) {
      setState(() => _saving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(
      StreamProvider(
        (ref) =>
            ref.watch(databaseProvider).accountsDao.watchAllAccounts(),
      ),
    );
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type selector
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'expense',
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_downward),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: 'transfer',
                  label: Text('Transfer'),
                  icon: Icon(Icons.swap_horiz),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) =>
                  setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),

            // Payee
            TextFormField(
              controller: _payeeController,
              decoration: const InputDecoration(
                labelText: 'Payee',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),

            // Amount — single $ via icon only, no prefixText
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Amount is required';
                if (double.tryParse(v.replaceAll(',', '')) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.year}-'
                '${_selectedDate.month.toString().padLeft(2, '0')}-'
                '${_selectedDate.day.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            const SizedBox(height: 12),

            // Account selector
            accountsAsync.when(
              data: (accounts) => InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                child: DropdownButton<int>(
                  value: _selectedAccountId ??
                      (accounts.isNotEmpty ? accounts.first.id : null),
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  hint: const Text('Select account'),
                  items: accounts
                      .map(
                        (a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),

            // To Account selector (only for transfers)
            if (_type == 'transfer')
              accountsAsync.when(
                data: (accounts) {
                  final fromId = _selectedAccountId ??
                      (accounts.isNotEmpty ? accounts.first.id : null);
                  final toAccounts =
                      accounts.where((a) => a.id != fromId).toList();
                  return Column(
                    children: [
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'To Account',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance_wallet),
                        ),
                        child: DropdownButton<int>(
                          value: toAccounts.any((a) => a.id == _toAccountId)
                              ? _toAccountId
                              : null,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          hint: const Text('Select destination account'),
                          items: toAccounts
                              .map(
                                (a) => DropdownMenuItem(
                                  value: a.id,
                                  child: Text(a.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _toAccountId = v),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),

            // Category selector (not shown for transfers)
            if (_type != 'transfer')
              categoriesAsync.when(
                data: (cats) => InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  child: DropdownButton<int>(
                    value: _selectedCategoryId,
                    isExpanded: true,
                    underline: const SizedBox.shrink(),
                    hint: const Text('Select category (optional)'),
                    items: cats
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedCategoryId = v),
                  ),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            const SizedBox(height: 12),

            // Memo
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(
                labelText: 'Memo (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),

            // Recurring toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.repeat),
              title: const Text('Repeats'),
              value: _recurring,
              onChanged: (val) => setState(() => _recurring = val),
            ),

            // Interval dropdown (only shown when recurring is on)
            if (_recurring) ...[
              const SizedBox(height: 8),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Repeat interval',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                child: DropdownButton<String>(
                  value: _recurringInterval,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                  ],
                  onChanged: (v) =>
                      setState(() => _recurringInterval = v ?? 'monthly'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            const SizedBox(height: 24),

            // Save button
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _saving
                    ? 'Saving…'
                    : _isEditing
                        ? 'Save Changes'
                        : 'Save Transaction',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
