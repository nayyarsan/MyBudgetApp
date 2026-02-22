import 'package:drift/drift.dart';
import '../database.dart';
import '../tables.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [MonthlyBudgets])
class BudgetDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Future<MonthlyBudget?> getBudgetForCategoryMonth(
    int categoryId,
    String month,
  ) =>
      (select(monthlyBudgets)
            ..where(
              (t) =>
                  t.categoryId.equals(categoryId) &
                  t.month.equals(month),
            ))
          .getSingleOrNull();

  Future<int> upsertBudget(MonthlyBudgetsCompanion entry) =>
      into(monthlyBudgets).insertOnConflictUpdate(entry);

  Stream<List<MonthlyBudget>> watchBudgetsForMonth(String month) =>
      (select(monthlyBudgets)
            ..where((t) => t.month.equals(month)))
          .watch();
}
