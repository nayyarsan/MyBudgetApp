import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../../core/utils/currency_formatter.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() =>
      _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _institutionController = TextEditingController();
  String _type = 'checking';

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final dollars =
        double.tryParse(_balanceController.text.replaceAll(',', '')) ??
            0;
    final db = ref.read(databaseProvider);
    await db.accountsDao.insertAccount(
      AccountsCompanion.insert(
        name: _nameController.text.trim(),
        type: _type,
        balanceCents: Value(CurrencyFormatter.toCents(dollars)),
        institution: Value(
          _institutionController.text.trim().isEmpty
              ? null
              : _institutionController.text.trim(),
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Account')),
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
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance),
              ),
              items: const [
                DropdownMenuItem(value: 'checking', child: Text('Checking')),
                DropdownMenuItem(value: 'savings', child: Text('Savings')),
                DropdownMenuItem(
                  value: 'credit',
                  child: Text('Credit Card'),
                ),
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
              ],
              onChanged: (v) => setState(() => _type = v ?? 'checking'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Current Balance',
                prefixText: r'$',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                helperText: 'Use negative value for credit card debt',
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
              label: const Text('Add Account'),
            ),
          ],
        ),
      ),
    );
  }
}
