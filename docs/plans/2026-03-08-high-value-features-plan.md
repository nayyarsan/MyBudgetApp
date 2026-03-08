# High-Value Features Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add recurring transactions, budget rollover, budget rebalancing, and budget history to Money in Sight — all built around a shared MonthBoundaryService.

**Architecture:** A `MonthBoundaryService` runs at app startup to handle all month-boundary events: snapshotting the prior month's budget, computing rollover amounts, and enqueuing due recurring transactions. All four features consume data produced by this service.

**Tech Stack:** Flutter, Riverpod 2.x, Drift (SQLite ORM with code generation), flutter_secure_storage, flutter_test

---

## Before You Start

- Run `flutter test` to confirm all existing tests pass before touching anything.
- After ANY change to `lib/core/database/tables.dart` or `lib/core/database/database.dart`, run:
  ```
  dart run build_runner build --delete-conflicting-outputs
  ```
  This regenerates the `.g.dart` files Drift needs. The app will not compile without this step.
- All monetary values are stored as **integer cents** (e.g. $5.00 = 500). Never use floats for money.
- The existing test pattern: `flutter test test/path/to/file.dart`

---

## Task 1: Database Schema Migration (v2 → v3)

**Files:**
- Modify: `lib/core/database/tables.dart`
- Modify: `lib/core/database/database.dart`

### Step 1: Add `nextDueDate` column to `Transactions` table

In `lib/core/database/tables.dart`, inside the `Transactions` class after line 74 (`recurringInterval`), add:

```dart
DateTimeColumn get nextDueDate => dateTime().nullable()();
```

### Step 2: Add `rolledOverCents` column to `MonthlyBudgets` table

In `lib/core/database/tables.dart`, inside the `MonthlyBudgets` class after line 49 (`assignedCents`), add:

```dart
IntColumn get rolledOverCents =>
    integer().withDefault(const Constant(0))();
```

### Step 3: Add `BudgetSnapshots` table

In `lib/core/database/tables.dart`, after the `NetWorthSnapshots` class, add:

```dart
class BudgetSnapshots extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId =>
      integer().references(Categories, #id)();
  TextColumn get month => text()(); // YYYY-MM
  IntColumn get assignedCents =>
      integer().withDefault(const Constant(0))();
  IntColumn get spentCents =>
      integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {categoryId, month},
      ];
}
```

### Step 4: Add `PendingRecurringQueue` table

In `lib/core/database/tables.dart`, after `BudgetSnapshots`, add:

```dart
class PendingRecurringQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceTransactionId =>
      integer().references(Transactions, #id)();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
```

### Step 5: Register new tables and bump schema version in `database.dart`

Replace the `@DriftDatabase` annotation and `AppDatabase` class in `lib/core/database/database.dart`:

```dart
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
import 'daos/budget_snapshots_dao.dart';
import 'daos/recurring_queue_dao.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Accounts,
    CategoryGroups,
    Categories,
    MonthlyBudgets,
    Transactions,
    NetWorthSnapshots,
    BudgetSnapshots,
    PendingRecurringQueue,
  ],
  daos: [
    AccountsDao,
    CategoriesDao,
    TransactionsDao,
    BudgetDao,
    BudgetSnapshotsDao,
    RecurringQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(transactions, transactions.toAccountId);
      }
      if (from < 3) {
        await m.addColumn(transactions, transactions.nextDueDate);
        await m.addColumn(monthlyBudgets, monthlyBudgets.rolledOverCents);
        await m.createTable(budgetSnapshots);
        await m.createTable(pendingRecurringQueue);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'moneyinsight.db'));
    return NativeDatabase(file);
  });
}
```

### Step 6: Run code generation

```
dart run build_runner build --delete-conflicting-outputs
```

Expected: no errors. You will see `database.g.dart` regenerated.

### Step 7: Confirm app compiles

```
flutter build windows --debug
```

(Or `flutter build apk --debug` on Android. Just confirm it compiles clean.)

### Step 8: Commit

```bash
git add lib/core/database/tables.dart lib/core/database/database.dart lib/core/database/database.g.dart
git commit -m "feat: schema v3 — add nextDueDate, rolledOverCents, BudgetSnapshots, PendingRecurringQueue"
```

---

## Task 2: DAOs for New Tables

**Files:**
- Create: `lib/core/database/daos/budget_snapshots_dao.dart`
- Create: `lib/core/database/daos/recurring_queue_dao.dart`
- Create: `test/core/database/budget_snapshots_dao_test.dart`

### Step 1: Create `BudgetSnapshotsDao`

Create `lib/core/database/daos/budget_snapshots_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'budget_snapshots_dao.g.dart';

@DriftAccessor(tables: [BudgetSnapshots])
class BudgetSnapshotsDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetSnapshotsDaoMixin {
  BudgetSnapshotsDao(super.db);

  Future<void> upsertSnapshot(BudgetSnapshotsCompanion entry) =>
      into(budgetSnapshots).insertOnConflictUpdate(entry);

  /// All snapshots for a specific month, keyed by categoryId.
  Future<List<BudgetSnapshot>> getSnapshotsForMonth(String month) =>
      (select(budgetSnapshots)
            ..where((t) => t.month.equals(month)))
          .get();

  /// All distinct months that have snapshots, sorted descending.
  Future<List<String>> getSnapshotMonths() async {
    final rows = await (selectOnly(budgetSnapshots, distinct: true)
          ..addColumns([budgetSnapshots.month])
          ..orderBy([OrderingTerm.desc(budgetSnapshots.month)]))
        .get();
    return rows.map((r) => r.read(budgetSnapshots.month)!).toList();
  }

  /// Check if a snapshot already exists for a category+month.
  Future<bool> hasSnapshot(int categoryId, String month) async {
    final row = await (select(budgetSnapshots)
          ..where(
            (t) =>
                t.categoryId.equals(categoryId) & t.month.equals(month),
          ))
        .getSingleOrNull();
    return row != null;
  }
}
```

### Step 2: Create `RecurringQueueDao`

Create `lib/core/database/daos/recurring_queue_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'recurring_queue_dao.g.dart';

@DriftAccessor(tables: [PendingRecurringQueue, Transactions])
class RecurringQueueDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringQueueDaoMixin {
  RecurringQueueDao(super.db);

  Stream<List<PendingRecurringQueueData>> watchPending() =>
      select(pendingRecurringQueue).watch();

  Future<List<PendingRecurringQueueData>> getPending() =>
      select(pendingRecurringQueue).get();

  Future<int> enqueue(PendingRecurringQueueCompanion entry) =>
      into(pendingRecurringQueue).insert(entry);

  Future<void> removeFromQueue(int id) =>
      (delete(pendingRecurringQueue)
            ..where((t) => t.id.equals(id)))
          .go();

  Future<void> clearAll() => delete(pendingRecurringQueue).go();

  /// Check if a source transaction is already in the queue.
  Future<bool> isEnqueued(int sourceTransactionId) async {
    final row = await (select(pendingRecurringQueue)
          ..where(
            (t) => t.sourceTransactionId.equals(sourceTransactionId),
          ))
        .getSingleOrNull();
    return row != null;
  }
}
```

### Step 3: Run code generation

```
dart run build_runner build --delete-conflicting-outputs
```

### Step 4: Write DAO tests

Create `test/core/database/budget_snapshots_dao_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyinsight/core/database/database.dart';
import 'package:moneyinsight/core/database/tables.dart';
import 'package:drift/drift.dart' show Value;

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() async {
    await db.close();
  });

  group('BudgetSnapshotsDao', () {
    test('upsert stores snapshot and getSnapshotsForMonth returns it', () async {
      // Need a category first
      final groupId = await db.categoriesDao.insertGroup('Housing');
      final catId = await db.categoriesDao.insertCategory(
        CategoriesCompanion.insert(groupId: groupId, name: 'Rent'),
      );

      await db.budgetSnapshotsDao.upsertSnapshot(
        BudgetSnapshotsCompanion.insert(
          categoryId: catId,
          month: '2026-02',
          assignedCents: const Value(50000),
          spentCents: const Value(48000),
        ),
      );

      final snapshots =
          await db.budgetSnapshotsDao.getSnapshotsForMonth('2026-02');
      expect(snapshots.length, 1);
      expect(snapshots.first.assignedCents, 50000);
      expect(snapshots.first.spentCents, 48000);
    });

    test('upsert on conflict updates existing snapshot', () async {
      final groupId = await db.categoriesDao.insertGroup('Housing');
      final catId = await db.categoriesDao.insertCategory(
        CategoriesCompanion.insert(groupId: groupId, name: 'Rent'),
      );

      await db.budgetSnapshotsDao.upsertSnapshot(
        BudgetSnapshotsCompanion.insert(
          categoryId: catId,
          month: '2026-02',
          assignedCents: const Value(50000),
          spentCents: const Value(48000),
        ),
      );
      // Upsert again with new values
      await db.budgetSnapshotsDao.upsertSnapshot(
        BudgetSnapshotsCompanion.insert(
          categoryId: catId,
          month: '2026-02',
          assignedCents: const Value(60000),
          spentCents: const Value(55000),
        ),
      );

      final snapshots =
          await db.budgetSnapshotsDao.getSnapshotsForMonth('2026-02');
      expect(snapshots.length, 1);
      expect(snapshots.first.assignedCents, 60000);
    });

    test('getSnapshotMonths returns distinct months desc', () async {
      final groupId = await db.categoriesDao.insertGroup('Housing');
      final catId = await db.categoriesDao.insertCategory(
        CategoriesCompanion.insert(groupId: groupId, name: 'Rent'),
      );

      await db.budgetSnapshotsDao.upsertSnapshot(
        BudgetSnapshotsCompanion.insert(
          categoryId: catId,
          month: '2026-01',
          assignedCents: const Value(50000),
          spentCents: const Value(48000),
        ),
      );
      await db.budgetSnapshotsDao.upsertSnapshot(
        BudgetSnapshotsCompanion.insert(
          categoryId: catId,
          month: '2026-02',
          assignedCents: const Value(52000),
          spentCents: const Value(50000),
        ),
      );

      final months = await db.budgetSnapshotsDao.getSnapshotMonths();
      expect(months, ['2026-02', '2026-01']);
    });
  });
}
```

### Step 5: Run tests

```
flutter test test/core/database/budget_snapshots_dao_test.dart
```

Expected: 3 tests pass.

### Step 6: Commit

```bash
git add lib/core/database/daos/ lib/core/database/database.dart test/core/database/
git commit -m "feat: add BudgetSnapshotsDao and RecurringQueueDao with tests"
```

---

## Task 3: MonthBoundaryService

**Files:**
- Create: `lib/core/services/month_boundary_service.dart`
- Create: `test/core/services/month_boundary_service_test.dart`

### Step 1: Write failing tests

Create `test/core/services/month_boundary_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moneyinsight/core/database/database.dart';
import 'package:moneyinsight/core/database/tables.dart';
import 'package:moneyinsight/core/services/month_boundary_service.dart';
import 'package:drift/drift.dart' show Value;

// Simple in-memory secure storage for tests
class FakeSecureStorage implements FlutterSecureStorage {
  final _store = <String, String>{};

  @override
  Future<String?> read({required String key, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) async =>
      _store[key];

  @override
  Future<void> write({required String key, required String? value, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> delete({required String key, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) async =>
      _store.remove(key);

  @override
  Future<Map<String, String>> readAll({iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) async => Map.of(_store);

  @override
  Future<void> deleteAll({iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) async => _store.clear();

  @override
  Future<bool> containsKey({required String key, iOptions, aOptions, lOptions, webOptions, mOptions, wOptions}) async => _store.containsKey(key);

  @override
  FlutterSecureStoragePlatform get iOptions => throw UnimplementedError();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late FakeSecureStorage storage;
  late MonthBoundaryService service;

  setUp(() {
    db = AppDatabase.forTesting();
    storage = FakeSecureStorage();
    service = MonthBoundaryService(db: db, storage: storage);
  });

  tearDown(() async {
    await db.close();
  });

  group('MonthBoundaryService.computeRolloverCents', () {
    test('returns surplus (assigned - spent) when positive', () {
      expect(
        MonthBoundaryService.computeRolloverCents(
          assignedCents: 50000,
          spentCents: 30000,
        ),
        20000,
      );
    });

    test('returns 0 when spent exceeds assigned (no negative rollover)', () {
      expect(
        MonthBoundaryService.computeRolloverCents(
          assignedCents: 30000,
          spentCents: 50000,
        ),
        0,
      );
    });

    test('returns 0 when exactly on budget', () {
      expect(
        MonthBoundaryService.computeRolloverCents(
          assignedCents: 30000,
          spentCents: 30000,
        ),
        0,
      );
    });
  });

  group('MonthBoundaryService.computeNextDueDate', () {
    test('weekly adds 7 days', () {
      final date = DateTime(2026, 3, 1);
      expect(
        MonthBoundaryService.computeNextDueDate(date, 'weekly'),
        DateTime(2026, 3, 8),
      );
    });

    test('monthly adds 1 month', () {
      final date = DateTime(2026, 3, 1);
      expect(
        MonthBoundaryService.computeNextDueDate(date, 'monthly'),
        DateTime(2026, 4, 1),
      );
    });

    test('yearly adds 1 year', () {
      final date = DateTime(2026, 3, 1);
      expect(
        MonthBoundaryService.computeNextDueDate(date, 'yearly'),
        DateTime(2027, 3, 1),
      );
    });
  });

  group('MonthBoundaryService.run', () {
    test('does nothing if already ran this month', () async {
      final now = DateTime.now();
      final currentMonth =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      await storage.write(
        key: 'last_snapshot_month',
        value: currentMonth,
      );

      await service.run(now: now);

      final months = await db.budgetSnapshotsDao.getSnapshotMonths();
      expect(months, isEmpty);
    });

    test('writes snapshots when transitioning to a new month', () async {
      // Set last snapshot to previous month
      final now = DateTime(2026, 3, 15);
      await storage.write(key: 'last_snapshot_month', value: '2026-02');

      // Create a category with a Feb budget and spending
      final groupId = await db.categoriesDao.insertGroup('Housing');
      final catId = await db.categoriesDao.insertCategory(
        CategoriesCompanion.insert(groupId: groupId, name: 'Rent'),
      );
      await db.budgetDao.upsertBudget(
        MonthlyBudgetsCompanion.insert(
          categoryId: catId,
          month: '2026-02',
          assignedCents: const Value(50000),
        ),
      );
      // Add a Feb expense for this category
      final accountId = await db.accountsDao.insertAccount(
        AccountsCompanion.insert(name: 'Checking', type: 'checking'),
      );
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          accountId: accountId,
          categoryId: Value(catId),
          amountCents: -30000,
          payee: 'Landlord',
          date: DateTime(2026, 2, 1),
          type: 'expense',
        ),
      );

      await service.run(now: now);

      // Should have written a snapshot for Feb
      final snapshots =
          await db.budgetSnapshotsDao.getSnapshotsForMonth('2026-02');
      expect(snapshots.length, 1);
      expect(snapshots.first.assignedCents, 50000);
      expect(snapshots.first.spentCents, 30000);

      // last_snapshot_month should be updated
      final stored =
          await storage.read(key: 'last_snapshot_month');
      expect(stored, '2026-03');
    });
  });
}
```

### Step 2: Run test to verify it fails

```
flutter test test/core/services/month_boundary_service_test.dart
```

Expected: FAIL — `MonthBoundaryService` not found.

### Step 3: Implement MonthBoundaryService

Create `lib/core/services/month_boundary_service.dart`:

```dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database.dart';
import '../database/tables.dart';

class MonthBoundaryService {
  final AppDatabase db;
  final FlutterSecureStorage storage;

  static const _lastSnapshotKey = 'last_snapshot_month';

  MonthBoundaryService({required this.db, required this.storage});

  /// Returns rollover amount (surplus only, never negative).
  static int computeRolloverCents({
    required int assignedCents,
    required int spentCents,
  }) {
    final surplus = assignedCents - spentCents;
    return surplus > 0 ? surplus : 0;
  }

  /// Returns the next due date for a recurring interval.
  static DateTime computeNextDueDate(DateTime from, String interval) {
    switch (interval) {
      case 'weekly':
        return from.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(from.year, from.month + 1, from.day);
      case 'yearly':
        return DateTime(from.year + 1, from.month, from.day);
      default:
        return DateTime(from.year, from.month + 1, from.day);
    }
  }

  static String _monthKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}';

  /// Main entry point. Call on app startup.
  /// [now] is injectable for testing.
  Future<void> run({DateTime? now}) async {
    final today = now ?? DateTime.now();
    final currentMonth = _monthKey(today);

    final lastSnapshot =
        await storage.read(key: _lastSnapshotKey);

    if (lastSnapshot == currentMonth) return; // Already ran this month

    final previousMonth = lastSnapshot ?? _monthKey(
      DateTime(today.year, today.month - 1),
    );

    await _snapshotMonth(previousMonth);
    await _applyRollovers(previousMonth, currentMonth);
    await _enqueueRecurring(today);

    await storage.write(key: _lastSnapshotKey, value: currentMonth);
  }

  Future<void> _snapshotMonth(String month) async {
    final categories = await db.categoriesDao.getAllCategories();
    final budgets = await db.budgetDao.watchBudgetsForMonth(month).first;

    final start = DateTime(
      int.parse(month.split('-')[0]),
      int.parse(month.split('-')[1]),
    );
    final end = DateTime(start.year, start.month + 1);
    final transactions =
        await db.transactionsDao.getTransactionsForMonth(start, end);

    for (final cat in categories) {
      final budget =
          budgets.where((b) => b.categoryId == cat.id).firstOrNull;
      final assigned = budget?.assignedCents ?? 0;

      var spent = 0;
      for (final t in transactions) {
        if (t.categoryId == cat.id && t.amountCents < 0) {
          spent += t.amountCents.abs();
        }
      }

      await db.budgetSnapshotsDao.upsertSnapshot(
        BudgetSnapshotsCompanion.insert(
          categoryId: cat.id,
          month: month,
          assignedCents: Value(assigned),
          spentCents: Value(spent),
        ),
      );
    }
  }

  Future<void> _applyRollovers(
    String previousMonth,
    String currentMonth,
  ) async {
    final categories = await db.categoriesDao.getAllCategories();
    final rolloversEnabled = categories.any((c) => c.rollover);
    if (!rolloversEnabled) return;

    final snapshots =
        await db.budgetSnapshotsDao.getSnapshotsForMonth(previousMonth);

    for (final cat in categories) {
      if (!cat.rollover) continue;

      final snapshot =
          snapshots.where((s) => s.categoryId == cat.id).firstOrNull;
      if (snapshot == null) continue;

      final rollover = computeRolloverCents(
        assignedCents: snapshot.assignedCents,
        spentCents: snapshot.spentCents,
      );
      if (rollover == 0) continue;

      // Get or create current month budget and add rollover
      final existing = await db.budgetDao.getBudgetForCategoryMonth(
        cat.id,
        currentMonth,
      );
      await db.budgetDao.upsertBudget(
        MonthlyBudgetsCompanion.insert(
          categoryId: cat.id,
          month: currentMonth,
          assignedCents: Value(existing?.assignedCents ?? 0),
          rolledOverCents: Value(rollover),
        ),
      );
    }
  }

  Future<void> _enqueueRecurring(DateTime today) async {
    final allTx = await db.transactionsDao.getAllTransactions();
    final recurringTemplates =
        allTx.where((t) => t.recurring && t.nextDueDate != null).toList();

    for (final tx in recurringTemplates) {
      if (tx.nextDueDate!.isAfter(today)) continue;
      final alreadyQueued =
          await db.recurringQueueDao.isEnqueued(tx.id);
      if (alreadyQueued) continue;

      await db.recurringQueueDao.enqueue(
        PendingRecurringQueueCompanion.insert(
          sourceTransactionId: tx.id,
          dueDate: tx.nextDueDate!,
        ),
      );
    }
  }
}
```

### Step 4: Run tests

```
flutter test test/core/services/month_boundary_service_test.dart
```

Expected: all tests pass.

### Step 5: Commit

```bash
git add lib/core/services/ test/core/services/
git commit -m "feat: implement MonthBoundaryService with snapshot, rollover, and recurring queue logic"
```

---

## Task 4: Wire MonthBoundaryService into App Startup

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/core/services/month_boundary_provider.dart`

### Step 1: Create a provider for MonthBoundaryService

Create `lib/core/services/month_boundary_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/providers.dart';
import 'month_boundary_service.dart';

final monthBoundaryServiceProvider = Provider<MonthBoundaryService>((ref) {
  final db = ref.watch(databaseProvider);
  const storage = FlutterSecureStorage();
  return MonthBoundaryService(db: db, storage: storage);
});
```

### Step 2: Call the service on startup in `main.dart`

In `lib/main.dart`, replace `_AppStartup` with a version that calls the service after onboarding is confirmed:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/services/month_boundary_provider.dart';
import 'features/auth/biometric_lock_screen.dart';
import 'features/onboarding/onboarding_providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured yet — app runs in offline-only mode
  }
  runApp(const ProviderScope(child: MoneyInSightApp()));
}

class MoneyInSightApp extends StatelessWidget {
  const MoneyInSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money in Sight',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const BiometricLockScreen(child: _AppStartup()),
    );
  }
}

class _AppStartup extends ConsumerWidget {
  const _AppStartup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(onboardingCompleteProvider).when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const MainShell(),
      data: (done) {
        if (!done) return const OnboardingScreen();
        // Run month boundary checks after onboarding is confirmed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(monthBoundaryServiceProvider).run();
        });
        return const MainShell();
      },
    );
  }
}
```

### Step 3: Commit

```bash
git add lib/main.dart lib/core/services/month_boundary_provider.dart
git commit -m "feat: run MonthBoundaryService on app startup after onboarding"
```

---

## Task 5: Recurring Transactions — Add/Edit UI

**Files:**
- Modify: `lib/features/transactions/add_transaction_screen.dart`

### Step 1: Add recurring state fields

In `_AddTransactionScreenState`, after `bool _saving = false;` (line 34), add:

```dart
bool _recurring = false;
String _recurringInterval = 'monthly';
```

In `initState`, after `_memoController.text = tx.memo ?? '';` (line 51), add:

```dart
_recurring = tx.recurring;
_recurringInterval = tx.recurringInterval ?? 'monthly';
```

### Step 2: Add recurring fields to the save logic

In `_save()`, replace the `insertTransaction` call (lines 100-116) with:

```dart
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
```

Add the import at the top of the file:
```dart
import '../../core/services/month_boundary_service.dart';
```

### Step 3: Add recurring UI widgets

In the `build` method, after the Memo field (`const SizedBox(height: 24),` before the Save button), add:

```dart
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
```

### Step 4: Run app and manually verify

Open the app, add a transaction, verify the "Repeats" toggle and interval dropdown appear. Set it to Monthly and save — confirm the transaction saves without error.

### Step 5: Commit

```bash
git add lib/features/transactions/add_transaction_screen.dart
git commit -m "feat: add recurring toggle and interval to add/edit transaction form"
```

---

## Task 6: Recurring Transactions — Due Banner + Review Sheet

**Files:**
- Create: `lib/features/budget/widgets/recurring_due_banner.dart`
- Create: `lib/features/budget/widgets/recurring_review_sheet.dart`
- Create: `lib/features/budget/recurring_providers.dart`
- Modify: `lib/features/budget/budget_screen.dart`

### Step 1: Create recurring providers

Create `lib/features/budget/recurring_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/providers.dart';
import '../../core/database/tables.dart';

/// Watches the pending recurring queue.
final pendingRecurringProvider =
    StreamProvider<List<PendingRecurringQueueData>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.recurringQueueDao.watchPending();
});
```

### Step 2: Create RecurringDueBanner widget

Create `lib/features/budget/widgets/recurring_due_banner.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../recurring_providers.dart';
import 'recurring_review_sheet.dart';

class RecurringDueBanner extends ConsumerWidget {
  const RecurringDueBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRecurringProvider);

    return pendingAsync.when(
      data: (pending) {
        if (pending.isEmpty) return const SizedBox.shrink();
        return MaterialBanner(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          content: Text(
            '${pending.length} recurring transaction${pending.length == 1 ? '' : 's'} due — Review',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          leading: Icon(
            Icons.repeat,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          actions: [
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => const RecurringReviewSheet(),
              ),
              child: const Text('Review'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
```

### Step 3: Create RecurringReviewSheet

Create `lib/features/budget/widgets/recurring_review_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/database.dart';
import '../../../core/database/providers.dart';
import '../../../core/database/tables.dart';
import '../../../core/services/month_boundary_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../recurring_providers.dart';

class RecurringReviewSheet extends ConsumerWidget {
  const RecurringReviewSheet({super.key});

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    PendingRecurringQueueData item,
    Transaction sourceTx,
  ) async {
    final db = ref.read(databaseProvider);
    // Insert new transaction cloned from template, dated today
    await db.transactionsDao.insertTransaction(
      TransactionsCompanion.insert(
        accountId: sourceTx.accountId,
        categoryId: Value(sourceTx.categoryId),
        amountCents: sourceTx.amountCents,
        payee: sourceTx.payee,
        date: item.dueDate,
        memo: Value(sourceTx.memo),
        type: sourceTx.type,
        toAccountId: Value(sourceTx.toAccountId),
      ),
    );
    // Advance nextDueDate on template
    final nextDue = MonthBoundaryService.computeNextDueDate(
      item.dueDate,
      sourceTx.recurringInterval ?? 'monthly',
    );
    await db.transactionsDao.updateTransaction(
      sourceTx.id,
      TransactionsCompanion(nextDueDate: Value(nextDue)),
    );
    // Remove from queue
    await db.recurringQueueDao.removeFromQueue(item.id);
  }

  Future<void> _skip(
    WidgetRef ref,
    PendingRecurringQueueData item,
    Transaction sourceTx,
  ) async {
    final db = ref.read(databaseProvider);
    // Advance nextDueDate without creating transaction
    final nextDue = MonthBoundaryService.computeNextDueDate(
      item.dueDate,
      sourceTx.recurringInterval ?? 'monthly',
    );
    await db.transactionsDao.updateTransaction(
      sourceTx.id,
      TransactionsCompanion(nextDueDate: Value(nextDue)),
    );
    await db.recurringQueueDao.removeFromQueue(item.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingRecurringProvider);
    final db = ref.watch(databaseProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recurring Transactions Due',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: pendingAsync.when(
              data: (pending) {
                if (pending.isEmpty) {
                  return const Center(child: Text('All caught up!'));
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: pending.length + 1,
                  itemBuilder: (context, i) {
                    if (i == pending.length) {
                      // Confirm All button
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: FilledButton.icon(
                          onPressed: () async {
                            for (final item in [...pending]) {
                              final sourceTx = await db.transactionsDao
                                  .getTransaction(item.sourceTransactionId);
                              if (sourceTx != null && context.mounted) {
                                await _confirm(context, ref, item, sourceTx);
                              }
                            }
                            if (context.mounted) Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.check_circle),
                          label: Text('Confirm All (${pending.length})'),
                        ),
                      );
                    }
                    final item = pending[i];
                    return FutureBuilder<Transaction?>(
                      future: db.transactionsDao
                          .getTransaction(item.sourceTransactionId),
                      builder: (context, snap) {
                        final tx = snap.data;
                        if (tx == null) return const SizedBox.shrink();
                        return ListTile(
                          leading: const Icon(Icons.repeat),
                          title: Text(tx.payee),
                          subtitle: Text(
                            '${CurrencyFormatter.format(tx.amountCents.abs())} · ${tx.recurringInterval ?? 'monthly'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () =>
                                    _skip(ref, item, tx),
                                child: const Text('Skip'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    _confirm(context, ref, item, tx),
                                child: const Text('Confirm'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 4: Wire banner into BudgetScreen

In `lib/features/budget/budget_screen.dart`:

Add import at the top:
```dart
import 'widgets/recurring_due_banner.dart';
```

In the `body: Column(children: [` section (after line 71, after `ToBeBudgetedBanner`), add:
```dart
const RecurringDueBanner(),
```

### Step 5: Commit

```bash
git add lib/features/budget/widgets/ lib/features/budget/recurring_providers.dart lib/features/budget/budget_screen.dart
git commit -m "feat: add recurring due banner and review sheet to budget screen"
```

---

## Task 7: Budget Rollover — Settings + Category Edit + Wire Calculator

**Files:**
- Create: `lib/core/services/rollover_provider.dart`
- Modify: `lib/features/settings/settings_screen.dart`
- Modify: `lib/features/budget/budget_screen.dart`
- Modify: `lib/features/budget/budget_providers.dart`

### Step 1: Create rollover provider

Create `lib/core/services/rollover_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kRolloverKey = 'rollover_global_enabled';
const _storage = FlutterSecureStorage();

/// Global rollover enabled setting (default: false).
final globalRolloverEnabledProvider =
    AsyncNotifierProvider<GlobalRolloverNotifier, bool>(
  GlobalRolloverNotifier.new,
);

class GlobalRolloverNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> load() async {
    final val = await _storage.read(key: _kRolloverKey);
    return val == 'true';
  }

  Future<void> setEnabled(bool value) async {
    await _storage.write(
      key: _kRolloverKey,
      value: value.toString(),
    );
    state = AsyncData(value);
  }
}
```

### Step 2: Add rollover toggle to Settings screen

In `lib/features/settings/settings_screen.dart`, add import:
```dart
import '../../core/services/rollover_provider.dart';
```

In the `build` method, after the `biometricAsync.when(...)` block and before the first `const Divider()` after Security (around line 142), add a new section:

```dart
const Divider(),

// --- Budget section ---
const _SectionHeader(title: 'Budget'),
ref.watch(globalRolloverEnabledProvider).when(
  loading: () => const SwitchListTile(
    title: Text('Roll over unused budget'),
    value: false,
    onChanged: null,
  ),
  error: (_, __) => const ListTile(
    title: Text('Rollover unavailable'),
  ),
  data: (enabled) => SwitchListTile(
    secondary: const Icon(Icons.savings_outlined),
    title: const Text('Roll over unused budget'),
    subtitle: const Text(
      'Carry surplus from each category into the next month',
    ),
    value: enabled,
    onChanged: (val) => ref
        .read(globalRolloverEnabledProvider.notifier)
        .setEnabled(val),
  ),
),
```

### Step 3: Add rollover amounts provider to budget_providers.dart

In `lib/features/budget/budget_providers.dart`, add at the bottom:

```dart
import '../../core/database/daos/budget_snapshots_dao.dart';

/// Rollover amounts for each category for the selected month.
/// Map<categoryId, rolledOverCents>
final rolloverAmountsProvider =
    FutureProvider<Map<int, int>>((ref) async {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  final budgets = await db.budgetDao
      .watchBudgetsForMonth(monthKey(month))
      .first;

  final result = <int, int>{};
  for (final b in budgets) {
    result[b.categoryId] = b.rolledOverCents;
  }
  return result;
});
```

### Step 4: Wire rollover into budget_screen.dart

In `lib/features/budget/budget_screen.dart`, in `_GroupTile.build()`:

After `final transactions = txAsync.valueOrNull ?? [];` add:
```dart
final rolloverAmounts = ref.watch(rolloverAmountsProvider).valueOrNull ?? {};
```

Replace the two `rolledOverCents: 0,` occurrences with:
```dart
rolledOverCents: rolloverAmounts[cat.id] ?? 0,
```

Also add the imports at the top of budget_screen.dart:
```dart
import '../../core/services/rollover_provider.dart';
```

And update `_GroupTile` to also take a `rolloverAmounts` parameter, or simply watch it directly from within `_GroupTile.build()` — the latter is simpler since `_GroupTile` is already a `ConsumerWidget`.

### Step 5: Add per-category rollover override to category edit

In `budget_screen.dart`, in `_showBudgetDialog`, add a second dialog or expand the existing one to include a rollover toggle. Replace `_showBudgetDialog` with:

```dart
Future<void> _showBudgetDialog(
  BuildContext context,
  WidgetRef ref,
  Category cat,
  int currentCents,
) async {
  final ctrl = TextEditingController(
    text: currentCents == 0 ? '' : (currentCents / 100).toStringAsFixed(2),
  );
  var rolloverOverride = cat.rollover;

  final globalEnabled =
      await ref.read(globalRolloverEnabledProvider.future);

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text('Budget: ${cat.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            if (globalEnabled) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Roll over unused'),
                value: rolloverOverride,
                onChanged: (v) => setState(() => rolloverOverride = v),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final dollars =
                  double.tryParse(ctrl.text.replaceAll(',', '')) ?? 0;
              final cents = (dollars * 100).round();
              final db = ref.read(databaseProvider);
              await db.budgetDao.upsertBudget(
                MonthlyBudgetsCompanion.insert(
                  categoryId: cat.id,
                  month: month,
                  assignedCents: Value(cents),
                ),
              );
              if (globalEnabled) {
                await db.categoriesDao.updateRollover(cat.id, rolloverOverride);
              }
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
```

### Step 6: Add `updateRollover` to CategoriesDao

In `lib/core/database/daos/categories_dao.dart`, add:

```dart
Future<void> updateRollover(int categoryId, bool rollover) =>
    (update(categories)..where((t) => t.id.equals(categoryId)))
        .write(CategoriesCompanion(rollover: Value(rollover)));
```

### Step 7: Commit

```bash
git add lib/core/services/rollover_provider.dart lib/features/settings/settings_screen.dart lib/features/budget/budget_screen.dart lib/features/budget/budget_providers.dart lib/core/database/daos/categories_dao.dart
git commit -m "feat: global rollover setting, per-category override, wire rollover into budget calculations"
```

---

## Task 8: Budget Rebalancing

**Files:**
- Create: `lib/features/budget/rebalance_provider.dart`
- Create: `lib/features/budget/widgets/rebalance_sheet.dart`
- Modify: `lib/features/budget/budget_screen.dart`
- Create: `test/features/budget/rebalance_provider_test.dart`

### Step 1: Write failing test for rebalance logic

Create `test/features/budget/rebalance_provider_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyinsight/features/budget/rebalance_provider.dart';

void main() {
  group('RebalanceSuggestion logic', () {
    test('no suggestions when nothing is overspent', () {
      final suggestions = computeRebalanceSuggestions(
        categoryData: [
          CategoryBudgetData(id: 1, name: 'Groceries', assigned: 40000, spent: 30000),
          CategoryBudgetData(id: 2, name: 'Dining', assigned: 20000, spent: 15000),
        ],
      );
      expect(suggestions, isEmpty);
    });

    test('suggests pulling from surplus to cover overage', () {
      final suggestions = computeRebalanceSuggestions(
        categoryData: [
          CategoryBudgetData(id: 1, name: 'Groceries', assigned: 40000, spent: 50000), // -$100 overage
          CategoryBudgetData(id: 2, name: 'Dining', assigned: 20000, spent: 5000),     // +$150 surplus
        ],
      );
      expect(suggestions.length, 1);
      expect(suggestions.first.fromCategoryId, 2); // pull from Dining
      expect(suggestions.first.toCategoryId, 1);   // to cover Groceries
      expect(suggestions.first.amountCents, 10000); // $100 transfer
    });

    test('caps transfer at available surplus', () {
      final suggestions = computeRebalanceSuggestions(
        categoryData: [
          CategoryBudgetData(id: 1, name: 'Groceries', assigned: 40000, spent: 70000), // -$300 overage
          CategoryBudgetData(id: 2, name: 'Dining', assigned: 20000, spent: 10000),    // +$100 surplus only
        ],
      );
      // Can only cover $100 of the $300 overage
      expect(suggestions.first.amountCents, 10000);
    });
  });
}
```

### Step 2: Run test to verify it fails

```
flutter test test/features/budget/rebalance_provider_test.dart
```

Expected: FAIL — `rebalance_provider.dart` not found.

### Step 3: Implement rebalance provider

Create `lib/features/budget/rebalance_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'budget_calculator.dart';
import 'budget_providers.dart';
import '../../core/database/providers.dart';

class CategoryBudgetData {
  final int id;
  final String name;
  final int assigned;
  final int spent;

  const CategoryBudgetData({
    required this.id,
    required this.name,
    required this.assigned,
    required this.spent,
  });

  int get available => assigned - spent;
}

class RebalanceSuggestion {
  final int fromCategoryId;
  final String fromCategoryName;
  final int toCategoryId;
  final String toCategoryName;
  int amountCents;

  RebalanceSuggestion({
    required this.fromCategoryId,
    required this.fromCategoryName,
    required this.toCategoryId,
    required this.toCategoryName,
    required this.amountCents,
  });
}

/// Pure function — testable without database.
List<RebalanceSuggestion> computeRebalanceSuggestions({
  required List<CategoryBudgetData> categoryData,
}) {
  final overspent = categoryData
      .where((c) => c.available < 0)
      .toList()
    ..sort((a, b) => a.available.compareTo(b.available)); // worst first

  final surplus = categoryData
      .where((c) => c.available > 0)
      .toList()
    ..sort((a, b) => b.available.compareTo(a.available)); // most surplus first

  if (overspent.isEmpty || surplus.isEmpty) return [];

  final surplusRemaining = Map.fromEntries(
    surplus.map((c) => MapEntry(c.id, c.available)),
  );

  final suggestions = <RebalanceSuggestion>[];

  for (final over in overspent) {
    var deficit = over.available.abs();
    for (final src in surplus) {
      final available = surplusRemaining[src.id] ?? 0;
      if (available <= 0) continue;

      final transfer = deficit < available ? deficit : available;
      suggestions.add(RebalanceSuggestion(
        fromCategoryId: src.id,
        fromCategoryName: src.name,
        toCategoryId: over.id,
        toCategoryName: over.name,
        amountCents: transfer,
      ));
      surplusRemaining[src.id] = available - transfer;
      deficit -= transfer;
      if (deficit <= 0) break;
    }
  }

  return suggestions;
}

/// Provider that computes rebalance suggestions for the current month.
final rebalanceSuggestionsProvider =
    FutureProvider<List<RebalanceSuggestion>>((ref) async {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  final monthStr = monthKey(month);

  final categories = await db.categoriesDao.getAllCategories();
  final budgets =
      await db.budgetDao.watchBudgetsForMonth(monthStr).first;
  final start = DateTime(month.year, month.month);
  final end = DateTime(month.year, month.month + 1);
  final transactions =
      await db.transactionsDao.getTransactionsForMonth(start, end);

  final data = <CategoryBudgetData>[];
  for (final cat in categories) {
    final budget =
        budgets.where((b) => b.categoryId == cat.id).firstOrNull;
    final assigned = budget?.assignedCents ?? 0;
    var spent = 0;
    for (final t in transactions) {
      if (t.categoryId == cat.id && t.amountCents < 0) {
        spent += t.amountCents.abs();
      }
    }
    data.add(CategoryBudgetData(
      id: cat.id,
      name: cat.name,
      assigned: assigned,
      spent: spent,
    ));
  }

  return computeRebalanceSuggestions(categoryData: data);
});
```

### Step 4: Run tests

```
flutter test test/features/budget/rebalance_provider_test.dart
```

Expected: all 3 tests pass.

### Step 5: Create RebalanceSheet widget

Create `lib/features/budget/widgets/rebalance_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../../core/database/providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../budget_providers.dart';
import '../rebalance_provider.dart';

class RebalanceSheet extends ConsumerStatefulWidget {
  const RebalanceSheet({super.key});

  @override
  ConsumerState<RebalanceSheet> createState() => _RebalanceSheetState();
}

class _RebalanceSheetState extends ConsumerState<RebalanceSheet> {
  List<RebalanceSuggestion>? _editable;

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync = ref.watch(rebalanceSuggestionsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rebalance Budget',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Move money from surplus categories to cover overages.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const Divider(),
          Expanded(
            child: suggestionsAsync.when(
              data: (suggestions) {
                _editable ??= List.of(suggestions);
                if (_editable!.isEmpty) {
                  return const Center(
                    child: Text('No overages to rebalance.'),
                  );
                }
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._editable!.map((s) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'From: ${s.fromCategoryName}',
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'To: ${s.toCategoryName}',
                                            style: const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        initialValue: (s.amountCents / 100)
                                            .toStringAsFixed(2),
                                        decoration: const InputDecoration(
                                          prefixText: '\$',
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                        ),
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                                decimal: true),
                                        onChanged: (v) {
                                          final cents =
                                              ((double.tryParse(v) ?? 0) * 100)
                                                  .round();
                                          setState(
                                              () => s.amountCents = cents);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _applyAll(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve All'),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyAll(BuildContext context) async {
    if (_editable == null) return;
    final db = ref.read(databaseProvider);
    final month = ref.read(selectedMonthProvider);
    final monthStr = monthKey(month);
    final budgets =
        await db.budgetDao.watchBudgetsForMonth(monthStr).first;

    for (final s in _editable!) {
      if (s.amountCents <= 0) continue;

      // Reduce source
      final fromBudget =
          budgets.where((b) => b.categoryId == s.fromCategoryId).firstOrNull;
      final fromAssigned = (fromBudget?.assignedCents ?? 0) - s.amountCents;
      await db.budgetDao.upsertBudget(
        MonthlyBudgetsCompanion.insert(
          categoryId: s.fromCategoryId,
          month: monthStr,
          assignedCents: Value(fromAssigned < 0 ? 0 : fromAssigned),
        ),
      );

      // Increase destination
      final toBudget =
          budgets.where((b) => b.categoryId == s.toCategoryId).firstOrNull;
      final toAssigned = (toBudget?.assignedCents ?? 0) + s.amountCents;
      await db.budgetDao.upsertBudget(
        MonthlyBudgetsCompanion.insert(
          categoryId: s.toCategoryId,
          month: monthStr,
          assignedCents: Value(toAssigned),
        ),
      );
    }

    if (context.mounted) Navigator.of(context).pop();
    ref.invalidate(rebalanceSuggestionsProvider);
  }
}
```

### Step 6: Add Rebalance button to BudgetScreen

In `lib/features/budget/budget_screen.dart`, add import:
```dart
import 'rebalance_provider.dart';
import 'widgets/rebalance_sheet.dart';
```

In the `AppBar` `actions` list (after the Goals button, around line 61), add:

```dart
Consumer(
  builder: (context, ref, _) {
    final suggestionsAsync =
        ref.watch(rebalanceSuggestionsProvider);
    final hasOverages =
        suggestionsAsync.valueOrNull?.isNotEmpty ?? false;
    if (!hasOverages) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.balance),
      tooltip: 'Rebalance budget',
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const RebalanceSheet(),
      ),
    );
  },
),
```

### Step 7: Commit

```bash
git add lib/features/budget/rebalance_provider.dart lib/features/budget/widgets/rebalance_sheet.dart lib/features/budget/budget_screen.dart test/features/budget/rebalance_provider_test.dart
git commit -m "feat: budget rebalancing — detect overages, suggest moves, apply patches"
```

---

## Task 9: Budget History Screen

**Files:**
- Create: `lib/features/analytics/budget_history_providers.dart`
- Create: `lib/features/analytics/budget_history_screen.dart`
- Modify: `lib/features/analytics/analytics_screen.dart`
- Create: `test/features/analytics/budget_history_providers_test.dart`

### Step 1: Create budget history provider

Create `lib/features/analytics/budget_history_providers.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/providers.dart';

class CategoryMonthHistory {
  final String categoryName;
  final int assignedCents;
  final int spentCents;

  const CategoryMonthHistory({
    required this.categoryName,
    required this.assignedCents,
    required this.spentCents,
  });

  int get varianceCents => assignedCents - spentCents;
}

class MonthBudgetHistory {
  final String month; // YYYY-MM
  final List<CategoryMonthHistory> categories;

  const MonthBudgetHistory({
    required this.month,
    required this.categories,
  });

  int get totalAssigned =>
      categories.fold(0, (sum, c) => sum + c.assignedCents);
  int get totalSpent =>
      categories.fold(0, (sum, c) => sum + c.spentCents);
  int get totalVariance => totalAssigned - totalSpent;
}

/// Budget history grouped by month, with per-category assigned/spent/variance.
final budgetHistoryProvider =
    FutureProvider<List<MonthBudgetHistory>>((ref) async {
  final db = ref.watch(databaseProvider);

  final months = await db.budgetSnapshotsDao.getSnapshotMonths();
  final categories = await db.categoriesDao.getAllCategories();

  final result = <MonthBudgetHistory>[];
  for (final month in months) {
    final snapshots =
        await db.budgetSnapshotsDao.getSnapshotsForMonth(month);
    final catHistories = <CategoryMonthHistory>[];
    for (final snap in snapshots) {
      final cat =
          categories.where((c) => c.id == snap.categoryId).firstOrNull;
      if (cat == null) continue;
      catHistories.add(CategoryMonthHistory(
        categoryName: cat.name,
        assignedCents: snap.assignedCents,
        spentCents: snap.spentCents,
      ));
    }
    catHistories.sort((a, b) => b.spentCents.compareTo(a.spentCents));
    result.add(MonthBudgetHistory(month: month, categories: catHistories));
  }

  return result;
});
```

### Step 2: Create BudgetHistoryScreen

Create `lib/features/analytics/budget_history_screen.dart`:

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/currency_formatter.dart';
import 'budget_history_providers.dart';

class BudgetHistoryScreen extends ConsumerWidget {
  const BudgetHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(budgetHistoryProvider);

    return historyAsync.when(
      data: (months) {
        if (months.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Budget history will appear here after your first month closes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Budget vs Actual',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _BudgetTrendChart(months: months),
            const SizedBox(height: 24),
            Text(
              'Monthly Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ...months.map((m) => _MonthTile(month: m)),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _BudgetTrendChart extends StatelessWidget {
  final List<MonthBudgetHistory> months;

  const _BudgetTrendChart({required this.months});

  @override
  Widget build(BuildContext context) {
    // Show last 6 months max
    final display = months.take(6).toList().reversed.toList();
    final maxY = display
        .map((m) => m.totalAssigned > m.totalSpent
            ? m.totalAssigned
            : m.totalSpent)
        .fold(0, (a, b) => a > b ? a : b)
        .toDouble();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY * 1.1,
          gridData: const FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= display.length) {
                    return const SizedBox.shrink();
                  }
                  final m = display[idx].month;
                  return Text(
                    m.substring(5), // MM part
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) => Text(
                  '\$${(value / 100).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            // Assigned line (blue)
            LineChartBarData(
              spots: display
                  .asMap()
                  .entries
                  .map((e) => FlSpot(
                        e.key.toDouble(),
                        e.value.totalAssigned.toDouble(),
                      ))
                  .toList(),
              color: Colors.blue,
              barWidth: 2,
              dotData: const FlDotData(show: true),
            ),
            // Spent line (red)
            LineChartBarData(
              spots: display
                  .asMap()
                  .entries
                  .map((e) => FlSpot(
                        e.key.toDouble(),
                        e.value.totalSpent.toDouble(),
                      ))
                  .toList(),
              color: Colors.red,
              barWidth: 2,
              dotData: const FlDotData(show: true),
            ),
          ],
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

class _MonthTile extends StatelessWidget {
  final MonthBudgetHistory month;

  const _MonthTile({required this.month});

  @override
  Widget build(BuildContext context) {
    final variance = month.totalVariance;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          month.month,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(
              'Budgeted: ${CurrencyFormatter.format(month.totalAssigned)}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 12),
            Text(
              'Spent: ${CurrencyFormatter.format(month.totalSpent)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${variance >= 0 ? '+' : ''}${CurrencyFormatter.format(variance)}',
              style: TextStyle(
                color: variance >= 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                const Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text('CATEGORY',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey))),
                    Expanded(
                        flex: 2,
                        child: Text('BUDGETED',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey))),
                    Expanded(
                        flex: 2,
                        child: Text('SPENT',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey))),
                    Expanded(
                        flex: 2,
                        child: Text('VARIANCE',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey))),
                  ],
                ),
                const Divider(height: 8),
                ...month.categories.map((cat) {
                  final v = cat.varianceCents;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3, child: Text(cat.categoryName)),
                        Expanded(
                          flex: 2,
                          child: Text(
                            CurrencyFormatter.format(cat.assignedCents),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            CurrencyFormatter.format(cat.spentCents),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${v >= 0 ? '+' : ''}${CurrencyFormatter.format(v)}',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: v > 0
                                  ? Colors.green
                                  : v < 0
                                      ? Colors.red
                                      : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 3: Add Budget History tab to AnalyticsScreen

In `lib/features/analytics/analytics_screen.dart`, replace the file with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_providers.dart';
import 'budget_history_screen.dart';
import 'widgets/income_vs_expenses_chart.dart';
import 'widgets/spending_by_category_chart.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Spending', icon: Icon(Icons.pie_chart)),
              Tab(text: 'Income vs Expenses', icon: Icon(Icons.bar_chart)),
              Tab(text: 'Budget History', icon: Icon(Icons.history)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SpendingTab(),
            _IncomeVsExpensesTab(),
            BudgetHistoryScreen(),
          ],
        ),
      ),
    );
  }
}

class _SpendingTab extends ConsumerWidget {
  const _SpendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(spendingByCategoryProvider);

    return dataAsync.when(
      data: (data) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Spending by Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            SpendingByCategoryChart(data: data),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _IncomeVsExpensesTab extends ConsumerWidget {
  const _IncomeVsExpensesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(monthlyTotalsProvider);

    return dataAsync.when(
      data: (data) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Income vs Expenses (Last 6 Months)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            IncomeVsExpensesChart(data: data),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
```

### Step 4: Run all tests

```
flutter test
```

Expected: all tests pass.

### Step 5: Commit

```bash
git add lib/features/analytics/ test/features/analytics/
git commit -m "feat: budget history screen with trend chart and monthly breakdown"
```

---

## Task 10: Final Integration Test

### Step 1: Run full test suite

```
flutter test
```

Expected: all existing + new tests pass.

### Step 2: Build and verify compilation

```
dart run build_runner build --delete-conflicting-outputs && flutter build windows --debug
```

Expected: clean build, no compilation errors.

### Step 3: Final commit

```bash
git add .
git commit -m "feat: complete high-value features — recurring transactions, rollover, rebalancing, budget history"
```

---

## Summary of All New Files

| File | Purpose |
|------|---------|
| `lib/core/database/daos/budget_snapshots_dao.dart` | DAO for budget snapshots |
| `lib/core/database/daos/recurring_queue_dao.dart` | DAO for pending recurring queue |
| `lib/core/services/month_boundary_service.dart` | Core service: snapshot, rollover, recurring |
| `lib/core/services/month_boundary_provider.dart` | Riverpod provider for the service |
| `lib/core/services/rollover_provider.dart` | Global rollover setting provider |
| `lib/features/budget/recurring_providers.dart` | pendingRecurringProvider |
| `lib/features/budget/rebalance_provider.dart` | Rebalance logic + provider |
| `lib/features/budget/widgets/recurring_due_banner.dart` | Banner for due recurring transactions |
| `lib/features/budget/widgets/recurring_review_sheet.dart` | Bottom sheet to confirm/skip recurring |
| `lib/features/budget/widgets/rebalance_sheet.dart` | Bottom sheet to approve rebalancing |
| `lib/features/analytics/budget_history_providers.dart` | Budget history data provider |
| `lib/features/analytics/budget_history_screen.dart` | History screen with chart + tiles |
