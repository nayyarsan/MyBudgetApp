import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/providers.dart';
import '../budget/budget_providers.dart';

class CategorySpending {
  final String categoryName;
  final int spentCents;

  const CategorySpending({
    required this.categoryName,
    required this.spentCents,
  });
}

class MonthlyTotal {
  final String month; // YYYY-MM
  final int incomeCents;
  final int expenseCents;

  const MonthlyTotal({
    required this.month,
    required this.incomeCents,
    required this.expenseCents,
  });
}

/// Spending grouped by category for the selected month.
final spendingByCategoryProvider =
    FutureProvider<List<CategorySpending>>((ref) async {
  final db = ref.watch(databaseProvider);
  final month = ref.watch(selectedMonthProvider);
  final start = DateTime(month.year, month.month);
  final end = DateTime(month.year, month.month + 1);

  final txs = await db.transactionsDao.getTransactionsForMonth(start, end);
  final expenses =
      txs.where((t) => t.amountCents < 0 && t.categoryId != null).toList();

  final byCategory = <int, int>{};
  for (final t in expenses) {
    byCategory[t.categoryId!] =
        (byCategory[t.categoryId!] ?? 0) + t.amountCents.abs();
  }

  final result = <CategorySpending>[];
  for (final entry in byCategory.entries) {
    final cat = await db.categoriesDao.getCategory(entry.key);
    if (cat != null) {
      result.add(
        CategorySpending(
          categoryName: cat.name,
          spentCents: entry.value,
        ),
      );
    }
  }

  result.sort((a, b) => b.spentCents.compareTo(a.spentCents));
  return result;
});

/// Income vs expenses for the last 6 months.
final monthlyTotalsProvider =
    FutureProvider<List<MonthlyTotal>>((ref) async {
  final db = ref.watch(databaseProvider);
  final now = DateTime.now();

  final totals = <MonthlyTotal>[];
  for (var i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final txs = await db.transactionsDao.getTransactionsForMonth(start, end);

    var income = 0;
    var expense = 0;
    for (final t in txs) {
      if (t.amountCents > 0) {
        income += t.amountCents;
      } else {
        expense += t.amountCents.abs();
      }
    }

    totals.add(
      MonthlyTotal(
        month: monthKey(month),
        incomeCents: income,
        expenseCents: expense,
      ),
    );
  }
  return totals;
});
