import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'budget_snapshots_dao.g.dart';

@DriftAccessor(tables: [BudgetSnapshots])
class BudgetSnapshotsDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetSnapshotsDaoMixin {
  BudgetSnapshotsDao(super.db);

  Future<void> upsertSnapshot(BudgetSnapshotsCompanion entry) =>
      into(budgetSnapshots).insert(
        entry,
        onConflict: DoUpdate(
          (_) => entry,
          target: [budgetSnapshots.categoryId, budgetSnapshots.month],
        ),
      );

  /// All snapshots for a specific month.
  Future<List<BudgetSnapshot>> getSnapshotsForMonth(String month) =>
      (select(budgetSnapshots)..where((t) => t.month.equals(month))).get();

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
          ..where((t) =>
              t.categoryId.equals(categoryId) & t.month.equals(month),))
        .getSingleOrNull();
    return row != null;
  }
}
