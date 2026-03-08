import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'budget_snapshots_dao.g.dart';

@DriftAccessor(tables: [BudgetSnapshots])
class BudgetSnapshotsDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetSnapshotsDaoMixin {
  BudgetSnapshotsDao(super.db);
}
