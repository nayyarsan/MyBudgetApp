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
