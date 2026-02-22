import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../budget/budget_providers.dart';

/// Screen to set a savings goal on an existing budget category.
class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  Category? _selectedCategory;
  DateTime? _targetDate;
  bool _saving = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month + 3),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
      helpText: 'Goal target date (optional)',
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save(List<Category> categories) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final amountDollars = double.tryParse(_amountController.text) ?? 0.0;
    final amountCents = (amountDollars * 100).round();

    // Update the category's goal fields
    await (db.update(db.categories)
          ..where((t) => t.id.equals(_selectedCategory!.id)))
        .write(CategoriesCompanion(
      goalAmountCents: Value(amountCents),
      goalDate: Value(_targetDate),
      goalType: const Value('savings_balance'),
      updatedAt: Value(DateTime.now()),
    ),);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Savings Goal'),
        centerTitle: false,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) => _buildForm(categories),
      ),
    );
  }

  Widget _buildForm(List<Category> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Which category is this goal for?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Category>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              validator: (v) => v == null ? 'Select a category' : null,
            ),
            const SizedBox(height: 24),
            Text(
              'Goal amount',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Target amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final parsed = double.tryParse(v ?? '');
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Target date (optional)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                _targetDate == null
                    ? 'No target date set'
                    : '${_targetDate!.month}/${_targetDate!.day}/${_targetDate!.year}',
              ),
              trailing: _targetDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _targetDate = null),
                    )
                  : null,
              onTap: _pickDate,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving
                    ? null
                    : () => _save(
                          ref.read(allCategoriesProvider).valueOrNull ?? [],
                        ),
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
