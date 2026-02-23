import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../../core/utils/currency_formatter.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  /// Pass an existing account to switch to edit mode.
  final Account? initial;

  const AddAccountScreen({super.key, this.initial});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _institutionController = TextEditingController();
  String _type = 'checking';

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final a = widget.initial!;
      _nameController.text = a.name;
      _balanceController.text = (a.balanceCents.abs() / 100).toStringAsFixed(2);
      _institutionController.text = a.institution ?? '';
      _type = a.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    var dollars =
        double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0;

    // Credit cards: balance represents debt, so always store as negative.
    if (_type == 'credit' && dollars > 0) dollars = -dollars;

    final cents = CurrencyFormatter.toCents(dollars);
    final db = ref.read(databaseProvider);

    if (_isEditing) {
      await db.accountsDao.updateAccount(
        AccountsCompanion(
          id: Value(widget.initial!.id),
          name: Value(_nameController.text.trim()),
          type: Value(_type),
          balanceCents: Value(cents),
          institution: Value(
            _institutionController.text.trim().isEmpty
                ? null
                : _institutionController.text.trim(),
          ),
        ),
      );
    } else {
      await db.accountsDao.insertAccount(
        AccountsCompanion.insert(
          name: _nameController.text.trim(),
          type: _type,
          balanceCents: Value(cents),
          institution: Value(
            _institutionController.text.trim().isEmpty
                ? null
                : _institutionController.text.trim(),
          ),
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Account' : 'Add Account'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
              ),
              child: DropdownButton<String>(
                value: _type,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'checking', child: Text('Checking')),
                  DropdownMenuItem(value: 'savings', child: Text('Savings')),
                  DropdownMenuItem(value: 'credit', child: Text('Credit Card')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'checking'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _balanceController,
              decoration: InputDecoration(
                labelText: _isEditing ? 'Opening Balance' : 'Current Balance',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
                helperText: _type == 'credit'
                    ? 'Enter the amount you owe (minus sign added automatically)'
                    : null,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _institutionController,
              decoration: const InputDecoration(
                labelText: 'Institution (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(_isEditing ? 'Save Changes' : 'Add Account'),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final nav = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: Text(
          'Delete "${widget.initial!.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref
          .read(databaseProvider)
          .accountsDao
          .softDeleteAccount(widget.initial!.id);
      nav.pop();
    }
  }
}
