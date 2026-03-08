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
      final now = DateTime(2026, 3, 15);
      await storage.write(key: 'last_snapshot_month', value: '2026-02');

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

      final snapshots =
          await db.budgetSnapshotsDao.getSnapshotsForMonth('2026-02');
      expect(snapshots.length, 1);
      expect(snapshots.first.assignedCents, 50000);
      expect(snapshots.first.spentCents, 30000);

      final stored = await storage.read(key: 'last_snapshot_month');
      expect(stored, '2026-03');
    });
  });
}
