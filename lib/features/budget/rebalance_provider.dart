import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      ),);
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
    ),);
  }

  return computeRebalanceSuggestions(categoryData: data);
});
