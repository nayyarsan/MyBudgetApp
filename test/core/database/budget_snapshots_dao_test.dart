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
