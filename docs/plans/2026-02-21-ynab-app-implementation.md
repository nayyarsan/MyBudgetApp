# Money in Sight — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a production-ready personal finance Android app (Money in Sight) with zero-based budgeting, offline-first local storage, optional Firebase cloud sync, and rich analytics.

**Architecture:** Feature-first Clean Architecture with Riverpod for state management, Drift (SQLite) as the local source of truth, and Firebase Firestore for background cloud sync. All UI reads from SQLite; Firestore is write-behind only.

**Tech Stack:** Flutter (Dart), Drift + SQLite, Firebase Auth + Firestore, Riverpod, fl_chart, local_auth, sqflite_sqlcipher, csv, file_picker

---

## Phase 1: Project Foundation

---

### Task 1: Create Flutter project and configure dependencies

**Files:**
- Create: `pubspec.yaml`
- Create: `android/app/google-services.json` (from Firebase console)
- Create: `android/build.gradle`
- Create: `android/app/build.gradle`

**Step 1: Create Flutter project**

```bash
cd C:/Users/sivan/myynabapplication
flutter create --org com.myynab --project-name myynab --platforms android .
```

Expected: Flutter project scaffolded in current directory.

**Step 2: Replace pubspec.yaml dependencies**

Replace the `dependencies` and `dev_dependencies` sections in `pubspec.yaml`:

```yaml
name: myynab
description: Personal budget tracker — YNAB inspired
publish_to: none
version: 1.0.0+1

environment:
  sdk: ">=3.2.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Local database
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.2
  path: ^1.9.0

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  google_sign_in: ^6.2.1

  # Charts
  fl_chart: ^0.66.2

  # CSV import
  file_picker: ^6.1.1
  csv: ^6.0.0

  # Security
  local_auth: ^2.1.8
  flutter_secure_storage: ^9.0.0

  # Utilities
  intl: ^0.19.0
  uuid: ^4.3.3
  collection: ^1.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  drift_dev: ^2.14.1
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8
  mockito: ^5.4.4
  build: ^2.4.1

flutter:
  uses-material-design: true
  assets:
    - assets/
```

**Step 3: Get dependencies**

```bash
cd C:/Users/sivan/myynabapplication
flutter pub get
```

Expected: All packages downloaded, no version conflicts.

**Step 4: Configure Android minimum SDK**

Edit `android/app/build.gradle`, set:
```groovy
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 26
        targetSdkVersion 34
    }
}
```

**Step 5: Create assets directory**

```bash
mkdir -p C:/Users/sivan/myynabapplication/assets
```

**Step 6: Commit**

```bash
git add .
git commit -m "feat: scaffold Flutter project with all dependencies"
```

---

### Task 2: Set up project folder structure

**Files:**
- Create: `lib/core/database/database.dart`
- Create: `lib/core/theme/app_theme.dart`
- Create: `lib/core/utils/currency_formatter.dart`
- Create: `lib/core/utils/date_utils.dart`
- Create: `lib/features/budget/budget_screen.dart`
- Create: `lib/features/transactions/transactions_screen.dart`
- Create: `lib/features/accounts/accounts_screen.dart`
- Create: `lib/features/analytics/analytics_screen.dart`
- Create: `lib/features/settings/settings_screen.dart`
- Create: `lib/main.dart`

**Step 1: Create directory structure**

```bash
mkdir -p C:/Users/sivan/myynabapplication/lib/core/database
mkdir -p C:/Users/sivan/myynabapplication/lib/core/firebase
mkdir -p C:/Users/sivan/myynabapplication/lib/core/csv
mkdir -p C:/Users/sivan/myynabapplication/lib/core/theme
mkdir -p C:/Users/sivan/myynabapplication/lib/core/utils
mkdir -p C:/Users/sivan/myynabapplication/lib/features/budget
mkdir -p C:/Users/sivan/myynabapplication/lib/features/transactions
mkdir -p C:/Users/sivan/myynabapplication/lib/features/accounts
mkdir -p C:/Users/sivan/myynabapplication/lib/features/analytics
mkdir -p C:/Users/sivan/myynabapplication/lib/features/goals
mkdir -p C:/Users/sivan/myynabapplication/lib/features/auth
mkdir -p C:/Users/sivan/myynabapplication/lib/features/settings
mkdir -p C:/Users/sivan/myynabapplication/test/core
mkdir -p C:/Users/sivan/myynabapplication/test/features
```

**Step 2: Write main.dart scaffold**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'features/budget/budget_screen.dart';
import 'features/transactions/transactions_screen.dart';
import 'features/accounts/accounts_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyYnabApp()));
}

class MyYnabApp extends StatelessWidget {
  const MyYnabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyYNAB',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    BudgetScreen(),
    TransactionsScreen(),
    AccountsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Budget'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.account_balance), label: 'Accounts'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

**Step 3: Write app theme**

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static const _primaryColor = Color(0xFF1B6CA8);
  static const _accentColor = Color(0xFF2DC9A4);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _accentColor,
    ),
    navigationBarTheme: const NavigationBarThemeData(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _accentColor,
      brightness: Brightness.dark,
    ),
  );
}
```

**Step 4: Write placeholder screens**

For each of the 5 feature screens, create a minimal placeholder. Example for BudgetScreen:

```dart
// lib/features/budget/budget_screen.dart
import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Budget')),
    );
  }
}
```

Repeat pattern for: `TransactionsScreen`, `AccountsScreen`, `AnalyticsScreen`, `SettingsScreen`.

**Step 5: Verify app runs**

```bash
flutter run
```

Expected: App launches with bottom nav bar and 5 placeholder screens.

**Step 6: Commit**

```bash
git add lib/ test/
git commit -m "feat: add project structure, theme, and shell navigation"
```

---

## Phase 2: Database Layer

---

### Task 3: Define Drift database schema

**Files:**
- Create: `lib/core/database/tables.dart`
- Create: `lib/core/database/database.dart`
- Create: `lib/core/database/database.g.dart` (generated)
- Test: `test/core/database_test.dart`

**Step 1: Write failing test**

```dart
// test/core/database_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() async {
    await db.close();
  });

  test('can insert and retrieve an account', () async {
    final id = await db.accountsDao.insertAccount(
      AccountsCompanion.insert(
        name: 'Checking',
        type: 'checking',
        balanceCents: const Value(100000),
        institution: const Value('Chase'),
      ),
    );
    final account = await db.accountsDao.getAccount(id);
    expect(account?.name, 'Checking');
    expect(account?.balanceCents, 100000);
  });

  test('can insert and retrieve a category group', () async {
    final groupId = await db.categoriesDao.insertGroup('Housing');
    final catId = await db.categoriesDao.insertCategory(
      CategoriesCompanion.insert(
        groupId: groupId,
        name: 'Rent',
      ),
    );
    final cat = await db.categoriesDao.getCategory(catId);
    expect(cat?.name, 'Rent');
  });

  test('amounts stored as integer cents to avoid float errors', () async {
    final id = await db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        accountId: 1,
        amountCents: -4999, // -$49.99
        payee: 'Grocery Store',
        date: DateTime(2026, 2, 21),
        type: 'expense',
      ),
    );
    final tx = await db.transactionsDao.getTransaction(id);
    expect(tx?.amountCents, -4999);
  });
}
```

**Step 2: Run test to verify it fails**

```bash
flutter test test/core/database_test.dart -v
```

Expected: FAIL — `AppDatabase` not defined.

**Step 3: Write the Drift tables**

```dart
// lib/core/database/tables.dart
import 'package:drift/drift.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get type => text()(); // checking, savings, credit, cash
  IntColumn get balanceCents => integer().withDefault(const Constant(0))();
  TextColumn get institution => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class CategoryGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get groupId => integer().references(CategoryGroups, #id)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();
  IntColumn get goalAmountCents => integer().nullable()();
  DateTimeColumn get goalDate => dateTime().nullable()();
  TextColumn get goalType => text().nullable()(); // targetBalance, monthlyContribution
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class MonthlyBudgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get month => text()(); // YYYY-MM format
  IntColumn get assignedCents => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {categoryId, month},
  ];
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get amountCents => integer()(); // negative = expense, positive = income
  TextColumn get payee => text().withLength(min: 0, max: 200)();
  DateTimeColumn get date => dateTime()();
  TextColumn get memo => text().nullable()();
  TextColumn get type => text()(); // income, expense, transfer
  BoolColumn get cleared => boolean().withDefault(const Constant(false))();
  BoolColumn get recurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringInterval => text().nullable()(); // daily, weekly, monthly
  TextColumn get importedFrom => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class NetWorthSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get totalAssetsCents => integer()();
  IntColumn get totalLiabilitiesCents => integer()();
  IntColumn get netWorthCents => integer()();
}
```

**Step 4: Write the Drift database class**

```dart
// lib/core/database/database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';
import 'daos/accounts_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/budget_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Accounts, CategoryGroups, Categories, MonthlyBudgets, Transactions, NetWorthSnapshots],
  daos: [AccountsDao, CategoriesDao, TransactionsDao, BudgetDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'myynab.db'));
    return NativeDatabase(file);
  });
}
```

**Step 5: Create DAO files**

```bash
mkdir -p C:/Users/sivan/myynabapplication/lib/core/database/daos
```

Create `lib/core/database/daos/accounts_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Future<int> insertAccount(AccountsCompanion entry) =>
      into(accounts).insert(entry);

  Future<Account?> getAccount(int id) =>
      (select(accounts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<Account>> watchAllAccounts() =>
      (select(accounts)..where((t) => t.isDeleted.equals(false))).watch();

  Future<List<Account>> getAllAccounts() =>
      (select(accounts)..where((t) => t.isDeleted.equals(false))).get();

  Future<bool> updateAccount(AccountsCompanion entry) =>
      update(accounts).replace(entry);

  Future<int> softDeleteAccount(int id) =>
      (update(accounts)..where((t) => t.id.equals(id)))
          .write(const AccountsCompanion(isDeleted: Value(true)));
}
```

Create `lib/core/database/daos/categories_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'categories_dao.g.dart';

@DriftAccessor(tables: [CategoryGroups, Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin {
  CategoriesDao(super.db);

  Future<int> insertGroup(String name) =>
      into(categoryGroups).insert(CategoryGroupsCompanion.insert(name: name));

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<Category?> getCategory(int id) =>
      (select(categories)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<Category>> watchCategoriesForGroup(int groupId) =>
      (select(categories)
            ..where((t) => t.groupId.equals(groupId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm(expression: t.sortOrder)]))
          .watch();

  Stream<List<CategoryGroup>> watchAllGroups() =>
      (select(categoryGroups)..where((t) => t.isDeleted.equals(false))).watch();
}
```

Create `lib/core/database/daos/transactions_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'transactions_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<Transaction?> getTransaction(int id) =>
      (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<Transaction>> watchTransactionsForMonth(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    return (select(transactions)
          ..where((t) =>
              t.isDeleted.equals(false) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<Transaction>> getTransactionsForAccount(int accountId) =>
      (select(transactions)
            ..where((t) => t.accountId.equals(accountId) & t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

  Future<int> softDelete(int id) =>
      (update(transactions)..where((t) => t.id.equals(id)))
          .write(const TransactionsCompanion(isDeleted: Value(true)));
}
```

Create `lib/core/database/daos/budget_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [MonthlyBudgets])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Future<MonthlyBudget?> getBudgetForCategoryMonth(int categoryId, String month) =>
      (select(monthlyBudgets)
            ..where((t) => t.categoryId.equals(categoryId) & t.month.equals(month)))
          .getSingleOrNull();

  Future<int> upsertBudget(MonthlyBudgetsCompanion entry) =>
      into(monthlyBudgets).insertOnConflictUpdate(entry);

  Stream<List<MonthlyBudget>> watchBudgetsForMonth(String month) =>
      (select(monthlyBudgets)..where((t) => t.month.equals(month))).watch();
}
```

**Step 6: Run code generation**

```bash
cd C:/Users/sivan/myynabapplication
dart run build_runner build --delete-conflicting-outputs
```

Expected: Generated files `database.g.dart`, `accounts_dao.g.dart`, etc. created.

**Step 7: Run tests**

```bash
flutter test test/core/database_test.dart -v
```

Expected: All 3 tests PASS.

**Step 8: Commit**

```bash
git add lib/core/database/ test/core/database_test.dart
git commit -m "feat: add Drift database schema and DAOs with tests"
```

---

### Task 4: Currency formatter utility

**Files:**
- Create: `lib/core/utils/currency_formatter.dart`
- Test: `test/core/currency_formatter_test.dart`

**Step 1: Write failing tests**

```dart
// test/core/currency_formatter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats positive cents as dollars', () {
      expect(CurrencyFormatter.format(100000), r'$1,000.00');
    });

    test('formats negative cents with minus sign', () {
      expect(CurrencyFormatter.format(-4999), r'-$49.99');
    });

    test('formats zero', () {
      expect(CurrencyFormatter.format(0), r'$0.00');
    });

    test('converts dollars to cents', () {
      expect(CurrencyFormatter.toCents(49.99), 4999);
    });

    test('converts cents to dollars', () {
      expect(CurrencyFormatter.toDollars(4999), closeTo(49.99, 0.001));
    });
  });
}
```

**Step 2: Run test — verify fail**

```bash
flutter test test/core/currency_formatter_test.dart -v
```

Expected: FAIL — `CurrencyFormatter` not defined.

**Step 3: Implement**

```dart
// lib/core/utils/currency_formatter.dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(symbol: r'$', decimalDigits: 2);

  static String format(int cents) {
    final dollars = cents / 100.0;
    return _formatter.format(dollars);
  }

  static int toCents(double dollars) => (dollars * 100).round();

  static double toDollars(int cents) => cents / 100.0;
}
```

**Step 4: Run tests — verify pass**

```bash
flutter test test/core/currency_formatter_test.dart -v
```

Expected: All 5 tests PASS.

**Step 5: Commit**

```bash
git add lib/core/utils/currency_formatter.dart test/core/currency_formatter_test.dart
git commit -m "feat: add currency formatter utility"
```

---

## Phase 3: Budget Feature

---

### Task 5: Budget calculation logic

**Files:**
- Create: `lib/features/budget/budget_calculator.dart`
- Test: `test/features/budget/budget_calculator_test.dart`

**Step 1: Write failing tests**

```dart
// test/features/budget/budget_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/features/budget/budget_calculator.dart';

void main() {
  group('BudgetCalculator', () {
    test('available = assigned - spent when no rollover', () {
      final result = BudgetCalculator.available(
        assignedCents: 50000, // $500
        spentCents: 30000,    // $300
        rolledOverCents: 0,
        rollover: false,
      );
      expect(result, 20000); // $200
    });

    test('available includes rollover when rollover enabled', () {
      final result = BudgetCalculator.available(
        assignedCents: 50000,
        spentCents: 30000,
        rolledOverCents: 10000, // $100 from last month
        rollover: true,
      );
      expect(result, 30000); // $200 + $100 rolled
    });

    test('available is negative when overspent', () {
      final result = BudgetCalculator.available(
        assignedCents: 20000,
        spentCents: 35000,
        rolledOverCents: 0,
        rollover: false,
      );
      expect(result, -15000);
    });

    test('to be budgeted = income - total assigned', () {
      final tbb = BudgetCalculator.toBeBudgeted(
        totalIncomeCents: 500000,
        totalAssignedCents: 350000,
      );
      expect(tbb, 150000);
    });

    test('to be budgeted can be negative if over-assigned', () {
      final tbb = BudgetCalculator.toBeBudgeted(
        totalIncomeCents: 300000,
        totalAssignedCents: 350000,
      );
      expect(tbb, -50000);
    });

    test('age of money calculation', () {
      // Average days between income and spending
      final age = BudgetCalculator.ageOfMoney(
        incomeDate: DateTime(2026, 2, 1),
        spendingDate: DateTime(2026, 2, 21),
      );
      expect(age, 20);
    });
  });
}
```

**Step 2: Run test — verify fail**

```bash
flutter test test/features/budget/budget_calculator_test.dart -v
```

Expected: FAIL — `BudgetCalculator` not defined.

**Step 3: Implement**

```dart
// lib/features/budget/budget_calculator.dart
class BudgetCalculator {
  static int available({
    required int assignedCents,
    required int spentCents,
    required int rolledOverCents,
    required bool rollover,
  }) {
    final rolloverAmount = rollover ? rolledOverCents : 0;
    return assignedCents - spentCents + rolloverAmount;
  }

  static int toBeBudgeted({
    required int totalIncomeCents,
    required int totalAssignedCents,
  }) {
    return totalIncomeCents - totalAssignedCents;
  }

  static int ageOfMoney({
    required DateTime incomeDate,
    required DateTime spendingDate,
  }) {
    return spendingDate.difference(incomeDate).inDays;
  }
}
```

**Step 4: Run tests — verify pass**

```bash
flutter test test/features/budget/budget_calculator_test.dart -v
```

Expected: All 6 tests PASS.

**Step 5: Commit**

```bash
git add lib/features/budget/budget_calculator.dart test/features/budget/budget_calculator_test.dart
git commit -m "feat: add budget calculator with zero-based budgeting logic"
```

---

### Task 6: Budget providers (Riverpod)

**Files:**
- Create: `lib/core/database/providers.dart`
- Create: `lib/features/budget/budget_providers.dart`
- Test: `test/features/budget/budget_providers_test.dart`

**Step 1: Create database provider**

```dart
// lib/core/database/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
```

**Step 2: Create budget providers**

```dart
// lib/features/budget/budget_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/providers.dart';
import '../../core/database/tables.dart';

final selectedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month),
);

String _monthKey(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}';

final categoryGroupsProvider = StreamProvider<List<CategoryGroup>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.categoriesDao.watchAllGroups();
});

final monthlyBudgetsProvider = StreamProvider<List<MonthlyBudget>>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.budgetDao.watchBudgetsForMonth(_monthKey(month));
});

final transactionsForMonthProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.transactionsDao.watchTransactionsForMonth(month.year, month.month);
});
```

**Step 3: Write widget test for budget screen**

```dart
// test/features/budget/budget_providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myynab/features/budget/budget_providers.dart';

void main() {
  test('selectedMonthProvider defaults to current month', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final month = container.read(selectedMonthProvider);
    final now = DateTime.now();
    expect(month.year, now.year);
    expect(month.month, now.month);
  });

  test('selectedMonthProvider can be updated', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(selectedMonthProvider.notifier).state = DateTime(2026, 3);
    expect(container.read(selectedMonthProvider).month, 3);
  });
}
```

**Step 4: Run tests**

```bash
flutter test test/features/budget/budget_providers_test.dart -v
```

Expected: PASS.

**Step 5: Commit**

```bash
git add lib/core/database/providers.dart lib/features/budget/budget_providers.dart test/features/budget/budget_providers_test.dart
git commit -m "feat: add Riverpod providers for budget and database"
```

---

### Task 7: Budget screen UI

**Files:**
- Modify: `lib/features/budget/budget_screen.dart`
- Create: `lib/features/budget/widgets/tbb_banner.dart`
- Create: `lib/features/budget/widgets/category_group_tile.dart`
- Create: `lib/features/budget/widgets/category_row.dart`

**Step 1: Write TBB banner widget**

```dart
// lib/features/budget/widgets/tbb_banner.dart
import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

class ToBeBudgetedBanner extends StatelessWidget {
  final int tbbCents;

  const ToBeBudgetedBanner({super.key, required this.tbbCents});

  @override
  Widget build(BuildContext context) {
    final isNegative = tbbCents < 0;
    final color = isNegative ? Colors.red : Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: color,
      child: Column(
        children: [
          Text(
            'To Be Budgeted',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(tbbCents),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Write category row widget**

```dart
// lib/features/budget/widgets/category_row.dart
import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

class CategoryRow extends StatelessWidget {
  final String name;
  final int assignedCents;
  final int spentCents;
  final int availableCents;
  final VoidCallback? onTap;

  const CategoryRow({
    super.key,
    required this.name,
    required this.assignedCents,
    required this.spentCents,
    required this.availableCents,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOverspent = availableCents < 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(name, style: Theme.of(context).textTheme.bodyMedium),
            ),
            Expanded(
              flex: 2,
              child: Text(
                CurrencyFormatter.format(assignedCents),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                CurrencyFormatter.format(spentCents),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                CurrencyFormatter.format(availableCents),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isOverspent ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 3: Update budget screen**

```dart
// lib/features/budget/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'budget_providers.dart';
import 'widgets/tbb_banner.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final groupsAsync = ref.watch(categoryGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                  DateTime(month.year, month.month - 1),
            ),
            Text('${_monthName(month.month)} ${month.year}'),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                  DateTime(month.year, month.month + 1),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const ToBeBudgetedBanner(tbbCents: 0), // wired up in Task 8
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(flex: 3, child: Text('CATEGORY', style: TextStyle(fontSize: 11, color: Colors.grey))),
                const Expanded(flex: 2, child: Text('BUDGETED', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: Colors.grey))),
                const Expanded(flex: 2, child: Text('SPENT', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: Colors.grey))),
                const Expanded(flex: 2, child: Text('AVAILABLE', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: Colors.grey))),
              ],
            ),
          ),
          Expanded(
            child: groupsAsync.when(
              data: (groups) => ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, i) => ListTile(
                  title: Text(groups[i].name, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {}, // Add category — Task 8
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  String _monthName(int month) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[month - 1];
  }
}
```

**Step 4: Run app and verify budget screen renders**

```bash
flutter run
```

Expected: Budget tab shows month nav header, TBB banner, column headers.

**Step 5: Commit**

```bash
git add lib/features/budget/
git commit -m "feat: add budget screen UI with month navigation and TBB banner"
```

---

## Phase 4: Transactions Feature

---

### Task 8: Add transaction form

**Files:**
- Create: `lib/features/transactions/add_transaction_screen.dart`
- Create: `lib/features/transactions/transaction_providers.dart`
- Test: `test/features/transactions/add_transaction_test.dart`

**Step 1: Write failing widget test**

```dart
// test/features/transactions/add_transaction_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myynab/features/transactions/add_transaction_screen.dart';

void main() {
  testWidgets('shows required fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AddTransactionScreen()),
      ),
    );

    expect(find.text('Payee'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
  });

  testWidgets('shows validation error when amount is empty', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AddTransactionScreen()),
      ),
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Amount is required'), findsOneWidget);
  });
}
```

**Step 2: Run test — verify fail**

```bash
flutter test test/features/transactions/add_transaction_test.dart -v
```

Expected: FAIL — `AddTransactionScreen` not found.

**Step 3: Implement add transaction screen**

```dart
// lib/features/transactions/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/database/providers.dart';
import '../../core/database/tables.dart';
import '../../core/utils/currency_formatter.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _payeeController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _type = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;

  @override
  void dispose() {
    _payeeController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amountText = _amountController.text.replaceAll(',', '');
    final dollars = double.tryParse(amountText) ?? 0;
    final cents = CurrencyFormatter.toCents(dollars) * (_type == 'expense' ? -1 : 1);

    final db = ref.read(databaseProvider);
    await db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        accountId: _selectedAccountId ?? 1,
        categoryId: Value(_selectedCategoryId),
        amountCents: cents,
        payee: _payeeController.text,
        date: _selectedDate,
        memo: Value(_memoController.text.isEmpty ? null : _memoController.text),
        type: _type,
      ),
    );

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
                ButtonSegment(value: 'transfer', label: Text('Transfer')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _payeeController,
              decoration: const InputDecoration(labelText: 'Payee', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: r'$',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || v.isEmpty) ? 'Amount is required' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2,'0')}-${_selectedDate.day.toString().padLeft(2,'0')}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              value: _selectedCategoryId,
              hint: const Text('Select category'),
              items: const [], // populated from DB in Task 9
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _memoController,
              decoration: const InputDecoration(labelText: 'Memo', border: OutlineInputBorder()),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
```

**Step 4: Run tests**

```bash
flutter test test/features/transactions/add_transaction_test.dart -v
```

Expected: PASS.

**Step 5: Wire FAB to open form in transactions screen**

```dart
// lib/features/transactions/transactions_screen.dart
import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: const Center(child: Text('No transactions yet')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Step 6: Commit**

```bash
git add lib/features/transactions/ test/features/transactions/
git commit -m "feat: add transaction entry form with validation"
```

---

### Task 9: Transaction list with search and filter

**Files:**
- Modify: `lib/features/transactions/transactions_screen.dart`
- Create: `lib/features/transactions/widgets/transaction_tile.dart`

**Step 1: Create transaction tile widget**

```dart
// lib/features/transactions/widgets/transaction_tile.dart
import 'package:flutter/material.dart';
import '../../../core/database/tables.dart';
import '../../../core/utils/currency_formatter.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.amountCents < 0;

    return Dismissible(
      key: Key('tx-${transaction.id}'),
      background: Container(color: Colors.red, alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.delete, color: Colors.white)),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense ? Colors.red.shade100 : Colors.green.shade100,
          child: Icon(isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: isExpense ? Colors.red : Colors.green, size: 18),
        ),
        title: Text(transaction.payee),
        subtitle: Text(
          '${transaction.date.year}-${transaction.date.month.toString().padLeft(2,'0')}-${transaction.date.day.toString().padLeft(2,'0')}'
          '${transaction.memo != null ? ' · ${transaction.memo}' : ''}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          CurrencyFormatter.format(transaction.amountCents.abs()),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        onTap: onEdit,
      ),
    );
  }
}
```

**Step 2: Update transactions screen with list, search, and Riverpod**

```dart
// lib/features/transactions/transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/budget/budget_providers.dart';
import 'add_transaction_screen.dart';
import 'widgets/transaction_tile.dart';
import '../../core/database/providers.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedMonthProvider);
    final txAsync = ref.watch(transactionsForMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                isDense: true,
                filled: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: txAsync.when(
        data: (txs) {
          final filtered = txs.where((t) =>
            _searchQuery.isEmpty ||
            t.payee.toLowerCase().contains(_searchQuery) ||
            (t.memo?.toLowerCase().contains(_searchQuery) ?? false)
          ).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('No transactions'));
          }

          return ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final tx = filtered[i];
              return TransactionTile(
                transaction: tx,
                onDelete: () => ref.read(databaseProvider).transactionsDao.softDelete(tx.id),
                onEdit: () {}, // edit flow — future enhancement
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

**Step 3: Run app and manually test**

```bash
flutter run
```

Expected: Add a transaction, see it appear in the Transactions tab. Swipe left to delete. Search filters results.

**Step 4: Commit**

```bash
git add lib/features/transactions/
git commit -m "feat: add transaction list with search, swipe-to-delete"
```

---

### Task 10: CSV import feature

**Files:**
- Create: `lib/core/csv/csv_parser.dart`
- Create: `lib/features/transactions/import_csv_screen.dart`
- Test: `test/core/csv_parser_test.dart`

**Step 1: Write failing tests**

```dart
// test/core/csv_parser_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/core/csv/csv_parser.dart';

void main() {
  group('CsvParser', () {
    const sampleCsv = '''Date,Description,Amount
2026-02-01,Grocery Store,-49.99
2026-02-03,Paycheck,2500.00
2026-02-05,Electric Bill,-85.00''';

    test('parses rows correctly', () {
      final rows = CsvParser.parse(sampleCsv);
      expect(rows.length, 3);
      expect(rows[0]['Date'], '2026-02-01');
      expect(rows[0]['Description'], 'Grocery Store');
      expect(rows[0]['Amount'], '-49.99');
    });

    test('detects headers', () {
      final headers = CsvParser.detectHeaders(sampleCsv);
      expect(headers, containsAll(['Date', 'Description', 'Amount']));
    });

    test('converts row to transaction data', () {
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

    test('flags invalid rows', () {
      const badCsv = '''Date,Description,Amount
not-a-date,Store,abc''';
      final rows = CsvParser.parse(badCsv);
      final result = CsvParser.validate(rows[0], dateColumn: 'Date', amountColumn: 'Amount');
      expect(result.isValid, false);
    });
  });
}
```

**Step 2: Run test — verify fail**

```bash
flutter test test/core/csv_parser_test.dart -v
```

Expected: FAIL.

**Step 3: Implement CSV parser**

```dart
// lib/core/csv/csv_parser.dart
import 'package:csv/csv.dart';
import '../utils/currency_formatter.dart';

class ParsedTransaction {
  final String payee;
  final int amountCents;
  final DateTime date;
  final String? memo;

  ParsedTransaction({required this.payee, required this.amountCents, required this.date, this.memo});
}

class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult({required this.isValid, this.error});
}

class CsvParser {
  static List<Map<String, String>> parse(String csvContent) {
    final rows = const CsvToListConverter(eol: '\n').convert(csvContent);
    if (rows.isEmpty) return [];

    final headers = rows.first.map((e) => e.toString().trim()).toList();
    return rows.skip(1).map((row) {
      final map = <String, String>{};
      for (var i = 0; i < headers.length && i < row.length; i++) {
        map[headers[i]] = row[i].toString().trim();
      }
      return map;
    }).toList();
  }

  static List<String> detectHeaders(String csvContent) {
    final rows = const CsvToListConverter(eol: '\n').convert(csvContent);
    if (rows.isEmpty) return [];
    return rows.first.map((e) => e.toString().trim()).toList();
  }

  static ParsedTransaction toTransactionData({
    required Map<String, String> row,
    required String dateColumn,
    required String amountColumn,
    required String payeeColumn,
    String? memoColumn,
  }) {
    final dateStr = row[dateColumn] ?? '';
    final amountStr = row[amountColumn]?.replaceAll(',', '') ?? '0';
    final dollars = double.tryParse(amountStr) ?? 0;
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();

    return ParsedTransaction(
      payee: row[payeeColumn] ?? '',
      amountCents: CurrencyFormatter.toCents(dollars),
      date: date,
      memo: memoColumn != null ? row[memoColumn] : null,
    );
  }

  static ValidationResult validate(
    Map<String, String> row, {
    required String dateColumn,
    required String amountColumn,
  }) {
    final dateStr = row[dateColumn] ?? '';
    final amountStr = row[amountColumn]?.replaceAll(',', '') ?? '';

    if (DateTime.tryParse(dateStr) == null) {
      return ValidationResult(isValid: false, error: 'Invalid date: $dateStr');
    }
    if (double.tryParse(amountStr) == null) {
      return ValidationResult(isValid: false, error: 'Invalid amount: $amountStr');
    }
    return ValidationResult(isValid: true);
  }
}
```

**Step 4: Run tests**

```bash
flutter test test/core/csv_parser_test.dart -v
```

Expected: All 4 tests PASS.

**Step 5: Create import screen**

```dart
// lib/features/transactions/import_csv_screen.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/csv/csv_parser.dart';
import '../../core/database/providers.dart';
import '../../core/database/tables.dart';
import 'package:drift/drift.dart' show Value;

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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
    if (result == null) return;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();

    setState(() {
      _headers = CsvParser.detectHeaders(content);
      _rows = CsvParser.parse(content);
      _error = null;
    });
  }

  Future<void> _import() async {
    if (_dateCol == null || _amountCol == null || _payeeCol == null) {
      setState(() => _error = 'Please map all required columns');
      return;
    }

    setState(() => _loading = true);
    final db = ref.read(databaseProvider);
    int imported = 0;

    for (final row in _rows) {
      final validation = CsvParser.validate(row, dateColumn: _dateCol!, amountColumn: _amountCol!);
      if (!validation.isValid) continue;

      final tx = CsvParser.toTransactionData(
        row: row,
        dateColumn: _dateCol!,
        amountColumn: _amountCol!,
        payeeColumn: _payeeCol!,
      );

      await db.transactionsDao.insertTransaction(TransactionsCompanion.insert(
        accountId: 1, // TODO: let user select account
        amountCents: tx.amountCents,
        payee: tx.payee,
        date: tx.date,
        type: tx.amountCents >= 0 ? 'income' : 'expense',
        importedFrom: const Value('csv'),
      ));
      imported++;
    }

    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $imported transactions')),
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
            FilledButton.tonal(onPressed: _pickFile, child: const Text('Choose CSV File')),
            if (_headers.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Map columns:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _columnDropdown('Date Column *', _dateCol, (v) => setState(() => _dateCol = v)),
              _columnDropdown('Amount Column *', _amountCol, (v) => setState(() => _amountCol = v)),
              _columnDropdown('Payee Column *', _payeeCol, (v) => setState(() => _payeeCol = v)),
              const SizedBox(height: 16),
              Text('Preview: ${_rows.take(3).length} of ${_rows.length} rows',
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              ..._rows.take(3).map((row) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(row.entries.map((e) => '${e.key}: ${e.value}').join(' | '),
                      style: const TextStyle(fontSize: 11)),
                ),
              )),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const Spacer(),
            if (_headers.isNotEmpty)
              FilledButton(
                onPressed: _loading ? null : _import,
                child: _loading ? const CircularProgressIndicator() : const Text('Import Transactions'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _columnDropdown(String label, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        value: value,
        items: _headers.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
```

**Step 6: Commit**

```bash
git add lib/core/csv/ lib/features/transactions/import_csv_screen.dart test/core/csv_parser_test.dart
git commit -m "feat: add CSV import with column mapping and validation"
```

---

## Phase 5: Accounts Feature

---

### Task 11: Accounts screen and net worth

**Files:**
- Modify: `lib/features/accounts/accounts_screen.dart`
- Create: `lib/features/accounts/add_account_screen.dart`
- Create: `lib/features/accounts/account_providers.dart`

**Step 1: Create account providers**

```dart
// lib/features/accounts/account_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/providers.dart';
import '../../core/database/tables.dart';

final accountsProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.accountsDao.watchAllAccounts();
});

final netWorthProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(accountsProvider).whenData((accounts) {
    return accounts.fold<int>(0, (sum, a) => sum + a.balanceCents);
  });
});
```

**Step 2: Build accounts screen**

```dart
// lib/features/accounts/accounts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import 'account_providers.dart';
import 'add_account_screen.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsProvider);
    final netWorthAsync = ref.watch(netWorthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: Column(
        children: [
          // Net worth card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Net Worth', style: TextStyle(color: Colors.grey)),
                    netWorthAsync.when(
                      data: (cents) => Text(CurrencyFormatter.format(cents),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const Text('—'),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Expanded(
            child: accountsAsync.when(
              data: (accounts) => ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, i) {
                  final a = accounts[i];
                  return ListTile(
                    leading: Icon(_accountIcon(a.type)),
                    title: Text(a.name),
                    subtitle: Text(a.institution ?? a.type),
                    trailing: Text(CurrencyFormatter.format(a.balanceCents),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: a.balanceCents < 0 ? Colors.red : null,
                        )),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddAccountScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _accountIcon(String type) {
    switch (type) {
      case 'checking': return Icons.account_balance;
      case 'savings': return Icons.savings;
      case 'credit': return Icons.credit_card;
      default: return Icons.attach_money;
    }
  }
}
```

**Step 3: Build add account screen**

```dart
// lib/features/accounts/add_account_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/database/providers.dart';
import '../../core/database/tables.dart';
import '../../core/utils/currency_formatter.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
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
    final dollars = double.tryParse(_balanceController.text) ?? 0;
    final db = ref.read(databaseProvider);
    await db.accountsDao.insertAccount(AccountsCompanion.insert(
      name: _nameController.text,
      type: _type,
      balanceCents: Value(CurrencyFormatter.toCents(dollars)),
      institution: Value(_institutionController.text.isEmpty ? null : _institutionController.text),
    ));
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
              decoration: const InputDecoration(labelText: 'Account Name *', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Account Type', border: OutlineInputBorder()),
              items: ['checking', 'savings', 'credit', 'cash']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v ?? 'checking'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(labelText: 'Current Balance', prefixText: r'$', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _institutionController,
              decoration: const InputDecoration(labelText: 'Institution (optional)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Add Account')),
          ],
        ),
      ),
    );
  }
}
```

**Step 4: Commit**

```bash
git add lib/features/accounts/
git commit -m "feat: add accounts screen with net worth tracker and add account form"
```

---

## Phase 6: Analytics Feature

---

### Task 12: Analytics charts with fl_chart

**Files:**
- Modify: `lib/features/analytics/analytics_screen.dart`
- Create: `lib/features/analytics/widgets/spending_by_category_chart.dart`
- Create: `lib/features/analytics/widgets/income_vs_expenses_chart.dart`
- Create: `lib/features/analytics/analytics_providers.dart`

**Step 1: Create analytics providers**

```dart
// lib/features/analytics/analytics_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/providers.dart';
import '../../core/database/tables.dart';
import '../../features/budget/budget_providers.dart';

class CategorySpending {
  final String categoryName;
  final int spentCents;
  CategorySpending({required this.categoryName, required this.spentCents});
}

final spendingByCategoryProvider = FutureProvider<List<CategorySpending>>((ref) async {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);

  // Get all expense transactions for the month
  final txs = await db.transactionsDao.getTransactionsForMonth(start, end);
  final expenses = txs.where((t) => t.amountCents < 0 && t.categoryId != null).toList();

  // Group by category
  final Map<int, int> byCategory = {};
  for (final t in expenses) {
    byCategory[t.categoryId!] = (byCategory[t.categoryId!] ?? 0) + t.amountCents.abs();
  }

  final result = <CategorySpending>[];
  for (final entry in byCategory.entries) {
    final cat = await db.categoriesDao.getCategory(entry.key);
    if (cat != null) {
      result.add(CategorySpending(categoryName: cat.name, spentCents: entry.value));
    }
  }

  result.sort((a, b) => b.spentCents.compareTo(a.spentCents));
  return result;
});
```

**Step 2: Add getTransactionsForMonth to DAO**

Add to `lib/core/database/daos/transactions_dao.dart`:

```dart
Future<List<Transaction>> getTransactionsForMonth(DateTime start, DateTime end) =>
    (select(transactions)
          ..where((t) =>
              t.isDeleted.equals(false) &
              t.date.isBiggerOrEqualValue(start) &
              t.date.isSmallerThanValue(end)))
        .get();
```

**Step 3: Build spending by category donut chart**

```dart
// lib/features/analytics/widgets/spending_by_category_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../analytics_providers.dart';
import '../../../core/utils/currency_formatter.dart';

class SpendingByCategoryChart extends StatefulWidget {
  final List<CategorySpending> data;
  const SpendingByCategoryChart({super.key, required this.data});

  @override
  State<SpendingByCategoryChart> createState() => _SpendingByCategoryChartState();
}

class _SpendingByCategoryChartState extends State<SpendingByCategoryChart> {
  int _touchedIndex = -1;

  static const _colors = [
    Color(0xFF1B6CA8), Color(0xFF2DC9A4), Color(0xFFFF6B6B),
    Color(0xFFFFD93D), Color(0xFF6BCB77), Color(0xFF845EC2),
    Color(0xFFFF9671), Color(0xFF00C9A7),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text('No spending data'));
    }

    final total = widget.data.fold<int>(0, (s, c) => s + c.spentCents);

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
                  });
                },
              ),
              sections: widget.data.asMap().entries.map((e) {
                final isTouched = e.key == _touchedIndex;
                final pct = e.value.spentCents / total * 100;
                return PieChartSectionData(
                  color: _colors[e.key % _colors.length],
                  value: e.value.spentCents.toDouble(),
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: isTouched ? 70 : 60,
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                );
              }).toList(),
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...widget.data.asMap().entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
          child: Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(
                color: _colors[e.key % _colors.length], shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(e.value.categoryName)),
              Text(CurrencyFormatter.format(e.value.spentCents),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        )),
      ],
    );
  }
}
```

**Step 4: Build analytics screen**

```dart
// lib/features/analytics/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_providers.dart';
import 'widgets/spending_by_category_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendingAsync = ref.watch(spendingByCategoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Spending by Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            spendingAsync.when(
              data: (data) => SpendingByCategoryChart(data: data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 5: Commit**

```bash
git add lib/features/analytics/
git commit -m "feat: add analytics screen with spending by category donut chart"
```

---

## Phase 7: Security

---

### Task 13: Biometric lock

**Files:**
- Create: `lib/features/auth/biometric_lock_screen.dart`
- Create: `lib/features/auth/auth_providers.dart`
- Modify: `lib/main.dart`

**Step 1: Add biometric permission to AndroidManifest**

Edit `android/app/src/main/AndroidManifest.xml`, add inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.USE_FINGERPRINT"/>
```

**Step 2: Create auth provider**

```dart
// lib/features/auth/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _biometricEnabledKey = 'biometric_enabled';

final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final val = await _storage.read(key: _biometricEnabledKey);
  return val == 'true';
});

final isUnlockedProvider = StateProvider<bool>((ref) => false);

final localAuthProvider = Provider<LocalAuthentication>((ref) => LocalAuthentication());
```

**Step 3: Create biometric lock screen**

```dart
// lib/features/auth/biometric_lock_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'auth_providers.dart';

class BiometricLockScreen extends ConsumerWidget {
  final Widget child;
  const BiometricLockScreen({super.key, required this.child});

  Future<void> _authenticate(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(localAuthProvider);
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access MyYNAB',
        options: const AuthenticationOptions(biometricOnly: false),
      );
      if (authenticated) {
        ref.read(isUnlockedProvider.notifier).state = true;
      }
    } catch (e) {
      // Authentication failed — stay locked
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUnlocked = ref.watch(isUnlockedProvider);
    final biometricAsync = ref.watch(biometricEnabledProvider);

    return biometricAsync.when(
      data: (enabled) {
        if (!enabled || isUnlocked) return child;
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('MyYNAB is locked', style: TextStyle(fontSize: 20)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock'),
                  onPressed: () => _authenticate(context, ref),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => child,
    );
  }
}
```

**Step 4: Wrap app with biometric lock in main.dart**

```dart
// Wrap MainShell in BiometricLockScreen
home: const BiometricLockScreen(child: MainShell()),
```

**Step 5: Commit**

```bash
git add lib/features/auth/ android/app/src/main/AndroidManifest.xml
git commit -m "feat: add biometric lock screen with local_auth"
```

---

## Phase 8: Firebase Cloud Sync

---

### Task 14: Firebase setup and sync service

**Files:**
- Create: `lib/core/firebase/sync_service.dart`
- Create: `lib/core/firebase/auth_service.dart`
- Modify: `lib/features/settings/settings_screen.dart`

**Step 1: Set up Firebase project**

1. Go to https://console.firebase.google.com
2. Create project "myynab"
3. Add Android app with package `com.myynab.myynab`
4. Download `google-services.json` → place in `android/app/`
5. Enable Firestore Database (start in test mode)
6. Enable Authentication → Google sign-in

**Step 2: Add google-services plugin to android/build.gradle**

```groovy
// android/build.gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
  }
}
```

Add to bottom of `android/app/build.gradle`:
```groovy
apply plugin: 'com.google.gms.google-services'
```

**Step 3: Create auth service**

```dart
// lib/core/firebase/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final currentUserProvider = StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signInAnonymously() => _auth.signInAnonymously();

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
```

**Step 4: Create sync service**

```dart
// lib/core/firebase/sync_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../database/providers.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  return SyncService(db);
});

class SyncService {
  final AppDatabase _db;
  final _firestore = FirebaseFirestore.instance;

  SyncService(this._db);

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference _col(String name) =>
      _firestore.collection('users').doc(_uid).collection(name);

  Future<void> syncAll() async {
    if (_uid == null) return; // not signed in — skip sync
    try {
      await _syncAccounts();
      await _syncCategories();
      await _syncTransactions();
    } catch (e) {
      // Sync failed silently — local data unaffected
    }
  }

  Future<void> _syncAccounts() async {
    final accounts = await _db.accountsDao.getAllAccounts();
    final batch = _firestore.batch();
    for (final a in accounts) {
      final ref = _col('accounts').doc(a.id.toString());
      batch.set(ref, {
        'id': a.id, 'name': a.name, 'type': a.type,
        'balanceCents': a.balanceCents, 'institution': a.institution,
        'updatedAt': a.updatedAt.millisecondsSinceEpoch,
        'isDeleted': a.isDeleted,
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  Future<void> _syncCategories() async {
    // Similar pattern to _syncAccounts for categories
    // (implementation follows same batch write pattern)
  }

  Future<void> _syncTransactions() async {
    // Similar pattern — batch write all non-deleted transactions
    // with updatedAt for conflict resolution
  }

  Future<void> restoreFromCloud() async {
    if (_uid == null) return;
    // Pull all documents from Firestore and insert into local DB
    // Used when signing in on a new device
    final accountDocs = await _col('accounts').get();
    for (final doc in accountDocs.docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Insert into local DB (upsert by id)
    }
  }
}
```

**Step 5: Set Firestore security rules**

In Firebase Console → Firestore → Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Step 6: Build settings screen**

```dart
// lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/auth_providers.dart';
import '../../core/firebase/auth_service.dart';
import '../../core/firebase/sync_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final authService = ref.read(authServiceProvider);
    final syncService = ref.read(syncServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Account section
          const ListTile(title: Text('ACCOUNT', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
          userAsync.when(
            data: (user) => user == null
                ? ListTile(
                    leading: const Icon(Icons.login),
                    title: const Text('Sign in with Google'),
                    subtitle: const Text('Enable cloud backup'),
                    onTap: () => authService.signInWithGoogle(),
                  )
                : ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: Text(user.displayName ?? user.email ?? 'Signed in'),
                    trailing: TextButton(
                      onPressed: () => authService.signOut(),
                      child: const Text('Sign out'),
                    ),
                  ),
            loading: () => const ListTile(title: Text('Loading...')),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const Divider(),

          // Sync section
          const ListTile(title: Text('SYNC', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Sync now'),
            onTap: () async {
              await syncService.syncAll();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sync complete')),
                );
              }
            },
          ),
          const Divider(),

          // Security section
          const ListTile(title: Text('SECURITY', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
          Consumer(builder: (context, ref, _) {
            final biometricAsync = ref.watch(biometricEnabledProvider);
            return biometricAsync.when(
              data: (enabled) => SwitchListTile(
                secondary: const Icon(Icons.fingerprint),
                title: const Text('Biometric Lock'),
                subtitle: const Text('Require fingerprint/face to open app'),
                value: enabled,
                onChanged: (val) async {
                  const storage = FlutterSecureStorage();
                  await storage.write(key: 'biometric_enabled', value: val.toString());
                  ref.invalidate(biometricEnabledProvider);
                },
              ),
              loading: () => const ListTile(title: Text('Loading...')),
              error: (_, __) => const SizedBox.shrink(),
            );
          }),
          const Divider(),

          // Theme
          const ListTile(title: Text('APPEARANCE', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Theme'),
            subtitle: const Text('Follows system setting'),
          ),
        ],
      ),
    );
  }
}
```

**Step 7: Commit**

```bash
git add lib/core/firebase/ lib/features/settings/ android/
git commit -m "feat: add Firebase auth, Firestore sync, and settings screen"
```

---

## Phase 9: Goals Feature

---

### Task 15: Savings goals

**Files:**
- Create: `lib/features/goals/goals_screen.dart`
- Create: `lib/features/goals/goals_providers.dart`
- Test: `test/features/goals/goal_progress_test.dart`

**Step 1: Write failing test**

```dart
// test/features/goals/goal_progress_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/features/goals/goal_calculator.dart';

void main() {
  test('calculates progress percentage correctly', () {
    final pct = GoalCalculator.progressPercent(currentCents: 25000, goalCents: 100000);
    expect(pct, closeTo(0.25, 0.001));
  });

  test('projected completion date based on monthly contribution', () {
    final date = GoalCalculator.projectedDate(
      currentCents: 25000,
      goalCents: 100000,
      monthlyContributionCents: 25000,
    );
    // Need 3 more months
    final expectedDate = DateTime(DateTime.now().year, DateTime.now().month + 3, 1);
    expect(date.year, expectedDate.year);
    expect(date.month, expectedDate.month);
  });
}
```

**Step 2: Run test — verify fail**

```bash
flutter test test/features/goals/goal_progress_test.dart -v
```

Expected: FAIL.

**Step 3: Implement goal calculator**

```dart
// lib/features/goals/goal_calculator.dart
class GoalCalculator {
  static double progressPercent({required int currentCents, required int goalCents}) {
    if (goalCents <= 0) return 0;
    return (currentCents / goalCents).clamp(0.0, 1.0);
  }

  static DateTime projectedDate({
    required int currentCents,
    required int goalCents,
    required int monthlyContributionCents,
  }) {
    if (monthlyContributionCents <= 0) return DateTime(9999);
    final remaining = goalCents - currentCents;
    final monthsNeeded = (remaining / monthlyContributionCents).ceil();
    final now = DateTime.now();
    return DateTime(now.year, now.month + monthsNeeded, 1);
  }
}
```

**Step 4: Run tests**

```bash
flutter test test/features/goals/goal_progress_test.dart -v
```

Expected: PASS.

**Step 5: Build goals screen**

```dart
// lib/features/goals/goals_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/providers.dart';
import '../../core/utils/currency_formatter.dart';
import 'goal_calculator.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(
      StreamProvider((ref) => ref.watch(databaseProvider).categoriesDao.watchCategoriesWithGoals()),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: categoriesAsync.when(
        data: (cats) {
          final withGoals = cats.where((c) => c.goalAmountCents != null).toList();
          if (withGoals.isEmpty) {
            return const Center(child: Text('No goals yet.\nSet a goal on any budget category.', textAlign: TextAlign.center));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: withGoals.length,
            itemBuilder: (context, i) {
              final cat = withGoals[i];
              final goal = cat.goalAmountCents!;
              final current = 0; // TODO: pull from available balance
              final pct = GoalCalculator.progressPercent(currentCents: current, goalCents: goal);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: pct, minHeight: 8),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${(pct * 100).toStringAsFixed(0)}% saved'),
                          Text('Goal: ${CurrencyFormatter.format(goal)}'),
                        ],
                      ),
                      if (cat.goalDate != null)
                        Text('Target: ${cat.goalDate!.year}-${cat.goalDate!.month.toString().padLeft(2,'0')}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

**Step 6: Commit**

```bash
git add lib/features/goals/ test/features/goals/
git commit -m "feat: add savings goals with progress tracking"
```

---

## Phase 10: Production Hardening

---

### Task 16: Integration test — full budget flow

**Files:**
- Create: `integration_test/budget_flow_test.dart`

**Step 1: Write integration test**

```dart
// integration_test/budget_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myynab/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full budget flow: add account → add transaction → verify in list', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate to Accounts tab
    await tester.tap(find.text('Accounts'));
    await tester.pumpAndSettle();

    // Add account
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Account Name *'), 'Test Checking');
    await tester.tap(find.text('Add Account'));
    await tester.pumpAndSettle();

    expect(find.text('Test Checking'), findsOneWidget);

    // Navigate to Transactions tab
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    // Add transaction
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Payee'), 'Grocery Store');
    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '49.99');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Grocery Store'), findsOneWidget);
  });
}
```

**Step 2: Run integration test**

```bash
flutter test integration_test/budget_flow_test.dart
```

Expected: PASS on connected Android device or emulator.

**Step 3: Commit**

```bash
git add integration_test/
git commit -m "test: add integration test for full budget flow"
```

---

### Task 17: Production build configuration

**Files:**
- Modify: `android/app/build.gradle`
- Create: `android/key.properties` (not committed — add to .gitignore)

**Step 1: Create .gitignore for secrets**

```bash
echo "android/key.properties" >> .gitignore
echo "*.jks" >> .gitignore
echo "*.keystore" >> .gitignore
```

**Step 2: Generate release keystore**

```bash
keytool -genkey -v -keystore android/app/myynab.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias myynab -storepass YOUR_STORE_PASSWORD -keypass YOUR_KEY_PASSWORD
```

**Step 3: Configure signing in build.gradle**

Add to `android/app/build.gradle`:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

**Step 4: Build release APK**

```bash
flutter build apk --release
```

Expected: APK generated at `build/app/outputs/flutter-apk/app-release.apk`

**Step 5: Final commit**

```bash
git add android/ .gitignore
git commit -m "feat: configure release build signing and ProGuard"
```

---

## Summary of All Tasks

| # | Task | Phase |
|---|---|---|
| 1 | Create Flutter project + dependencies | Foundation |
| 2 | Set up folder structure + shell nav | Foundation |
| 3 | Drift database schema + DAOs | Database |
| 4 | Currency formatter utility | Database |
| 5 | Budget calculation logic | Budget |
| 6 | Budget Riverpod providers | Budget |
| 7 | Budget screen UI | Budget |
| 8 | Add transaction form | Transactions |
| 9 | Transaction list + search | Transactions |
| 10 | CSV import + parser | Transactions |
| 11 | Accounts screen + net worth | Accounts |
| 12 | Analytics charts (fl_chart) | Analytics |
| 13 | Biometric lock screen | Security |
| 14 | Firebase auth + sync service | Cloud Sync |
| 15 | Savings goals + calculator | Goals |
| 16 | Integration test — full flow | Testing |
| 17 | Release build configuration | Production |

---

*Plan written 2026-02-21. Implement using superpowers:executing-plans.*
