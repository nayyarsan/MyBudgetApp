import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import '../shell/main_shell.dart';
import 'onboarding_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _saving = false;

  // Step 1 — accounts
  final List<_AccountDraft> _accounts = [];

  // Step 2 — income
  final _incomeController = TextEditingController();

  // Step 3 — categories
  static const _defaultCategories = [
    'Housing',
    'Groceries',
    'Transport',
    'Dining',
    'Entertainment',
    'Health',
    'Utilities',
  ];
  final Set<String> _selectedCategories = {};
  final _customCategoryController = TextEditingController();

  // Step 4 — goals
  final List<_GoalDraft> _goals = [];

  @override
  void dispose() {
    _pageController.dispose();
    _incomeController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 1 && !_canProceedAccounts()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one account to continue.')),
      );
      return;
    }
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedAccounts() => _accounts.isNotEmpty;

  Future<void> _finish() async {
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);

    // Save accounts
    for (final draft in _accounts) {
      await db.accountsDao.insertAccount(
        AccountsCompanion.insert(
          name: draft.name,
          type: draft.type,
          balanceCents: Value((draft.balance * 100).round()),
        ),
      );
    }

    // Save income
    final incomeVal = double.tryParse(_incomeController.text) ?? 0;
    if (incomeVal > 0) {
      await saveMonthlyIncome((incomeVal * 100).round());
    }

    // Save categories
    final allCategories = {
      ..._selectedCategories,
      if (_customCategoryController.text.trim().isNotEmpty)
        _customCategoryController.text.trim(),
    };
    if (allCategories.isNotEmpty) {
      final groupId =
          await db.categoriesDao.insertGroup('My Categories');
      for (var i = 0; i < allCategories.length; i++) {
        await db.categoriesDao.insertCategory(
          CategoriesCompanion.insert(
            groupId: groupId,
            name: allCategories.elementAt(i),
            sortOrder: Value(i),
          ),
        );
      }
    }

    // Save goals
    if (_goals.isNotEmpty) {
      final goalsGroupId =
          await db.categoriesDao.insertGroup('Savings Goals');
      for (var i = 0; i < _goals.length; i++) {
        final g = _goals[i];
        await db.categoriesDao.insertCategory(
          CategoriesCompanion.insert(
            groupId: goalsGroupId,
            name: g.name,
            goalAmountCents: Value((g.targetAmount * 100).round()),
            goalDate: Value(g.targetDate),
            goalType: const Value('savings_balance'),
            sortOrder: Value(i),
          ),
        );
      }
    }

    await setOnboardingComplete();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _currentPage = p),
                children: [
                  _WelcomePage(onNext: _nextPage),
                  _AccountsPage(
                    accounts: _accounts,
                    onChanged: () => setState(() {}),
                  ),
                  _IncomePage(controller: _incomeController),
                  _CategoriesPage(
                    defaults: _defaultCategories,
                    selected: _selectedCategories,
                    customController: _customCategoryController,
                    onChanged: () => setState(() {}),
                  ),
                  _GoalsPage(
                    goals: _goals,
                    onChanged: () => setState(() {}),
                  ),
                  _DonePage(onFinish: _saving ? null : _finish),
                ],
              ),
            ),

            // Navigation buttons
            if (_currentPage > 0 && _currentPage < 5)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    if (_currentPage > 1)
                      OutlinedButton(
                        onPressed: _prevPage,
                        child: const Text('Back'),
                      ),
                    const Spacer(),
                    if (_currentPage == 4)
                      OutlinedButton(
                        onPressed: _nextPage,
                        child: const Text('Skip'),
                      ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _nextPage,
                      child: const Text('Next'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Step 0: Welcome ───────────────────────────────

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 96,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            'Welcome to Money in Sight',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your personal finance tracker.\nLet\'s get you set up in a few steps.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Get Started'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Step 1: Accounts ──────────────────────────────

class _AccountDraft {
  String name = '';
  String type = 'checking';
  double balance = 0;
}

class _AccountsPage extends StatefulWidget {
  final List<_AccountDraft> accounts;
  final VoidCallback onChanged;

  const _AccountsPage({required this.accounts, required this.onChanged});

  @override
  State<_AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<_AccountsPage> {
  void _addAccount() {
    setState(() => widget.accounts.add(_AccountDraft()));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Text(
          'Add Your Accounts',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add your bank accounts, credit cards, or cash to track.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ...widget.accounts.asMap().entries.map((entry) {
          final i = entry.key;
          final draft = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Account name',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (v) => draft.name = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red,),
                        onPressed: () {
                          setState(() =>
                              widget.accounts.removeAt(i),);
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          child: DropdownButton<String>(
                            value: draft.type,
                            isExpanded: true,
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(
                                value: 'checking',
                                child: Text('Checking'),
                              ),
                              DropdownMenuItem(
                                value: 'savings',
                                child: Text('Savings'),
                              ),
                              DropdownMenuItem(
                                value: 'credit',
                                child: Text('Credit Card'),
                              ),
                              DropdownMenuItem(
                                value: 'cash',
                                child: Text('Cash'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => draft.type = v!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Starting balance',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,),
                          onChanged: (v) =>
                              draft.balance = double.tryParse(v) ?? 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        TextButton.icon(
          onPressed: _addAccount,
          icon: const Icon(Icons.add),
          label: const Text('Add account'),
        ),
      ],
    );
  }
}

// ─────────────────────────── Step 2: Income ────────────────────────────────

class _IncomePage extends StatelessWidget {
  final TextEditingController controller;
  const _IncomePage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Income',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            "What's your monthly take-home income?",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Monthly income',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          const Text(
            'This helps us show how much you have left to budget.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────── Step 3: Categories ─────────────────────────────

class _CategoriesPage extends StatelessWidget {
  final List<String> defaults;
  final Set<String> selected;
  final TextEditingController customController;
  final VoidCallback onChanged;

  const _CategoriesPage({
    required this.defaults,
    required this.selected,
    required this.customController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Text(
          'Primary Categories',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select the spending categories you want to track.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...defaults.map(
          (cat) => CheckboxListTile(
            title: Text(cat),
            value: selected.contains(cat),
            onChanged: (v) {
              if (v == true) {
                selected.add(cat);
              } else {
                selected.remove(cat);
              }
              onChanged();
            },
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: customController,
          decoration: const InputDecoration(
            labelText: 'Custom category (optional)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Step 4: Goals ─────────────────────────────────

class _GoalDraft {
  String name = '';
  double targetAmount = 0;
  DateTime targetDate = DateTime.now().add(const Duration(days: 365));
}

class _GoalsPage extends StatefulWidget {
  final List<_GoalDraft> goals;
  final VoidCallback onChanged;

  const _GoalsPage({required this.goals, required this.onChanged});

  @override
  State<_GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<_GoalsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      children: [
        Text(
          'Savings Goals',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add savings goals to track your progress. (Optional)',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...widget.goals.asMap().entries.map((entry) {
          final i = entry.key;
          final draft = entry.value;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Goal name',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (v) => draft.name = v,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red,),
                        onPressed: () {
                          setState(() => widget.goals.removeAt(i));
                          widget.onChanged();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Target amount',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            isDense: true,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,),
                          onChanged: (v) =>
                              draft.targetAmount = double.tryParse(v) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: const Text(
                            'Target date',
                            style: TextStyle(fontSize: 12),
                          ),
                          subtitle: Text(
                            '${draft.targetDate.year}-'
                            '${draft.targetDate.month.toString().padLeft(2, '0')}-'
                            '${draft.targetDate.day.toString().padLeft(2, '0')}',
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: draft.targetDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2040),
                            );
                            if (picked != null) {
                              setState(() => draft.targetDate = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            setState(() => widget.goals.add(_GoalDraft()));
            widget.onChanged();
          },
          icon: const Icon(Icons.add),
          label: const Text('Add goal'),
        ),
      ],
    );
  }
}

// ─────────────────────────── Step 5: Done ──────────────────────────────────

class _DonePage extends StatelessWidget {
  final VoidCallback? onFinish;
  const _DonePage({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 96,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            "You're all set!",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your accounts and preferences have been saved.\nStart tracking your finances!',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          onFinish == null
              ? const CircularProgressIndicator()
              : FilledButton.icon(
                  onPressed: onFinish,
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text("Let's Go!"),
                ),
        ],
      ),
    );
  }
}
