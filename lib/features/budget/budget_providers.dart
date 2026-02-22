import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';

/// The currently selected budget month.
final selectedMonthProvider = StateProvider<DateTime>(
  (ref) => DateTime(DateTime.now().year, DateTime.now().month),
);

/// Formats a DateTime to YYYY-MM string for DB queries.
String monthKey(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}';

/// All non-deleted category groups, ordered by sortOrder.
final categoryGroupsProvider = StreamProvider<List<CategoryGroup>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.categoriesDao.watchAllGroups();
});

/// All non-deleted categories.
final allCategoriesProvider = FutureProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.categoriesDao.getAllCategories();
});

/// Monthly budget rows for the selected month.
final monthlyBudgetsProvider = StreamProvider<List<MonthlyBudget>>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.budgetDao.watchBudgetsForMonth(monthKey(month));
});

/// All transactions for the selected month (reactive stream).
final transactionsForMonthProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.transactionsDao.watchTransactionsForMonth(
    month.year,
    month.month,
  );
});

/// Total income for the selected month (sum of positive transactions).
final monthlyIncomeProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(transactionsForMonthProvider).whenData(
        (txs) {
          var total = 0;
          for (final t in txs.where((t) => t.amountCents > 0)) {
            total += t.amountCents;
          }
          return total;
        },
      );
});

/// Total assigned across all categories for the selected month.
final totalAssignedProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(monthlyBudgetsProvider).whenData(
        (budgets) {
          var total = 0;
          for (final b in budgets) {
            total += b.assignedCents;
          }
          return total;
        },
      );
});
