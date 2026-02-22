import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/database/providers.dart';
import 'goal_calculator.dart';

/// A goal category enriched with progress data.
class GoalProgress {
  final Category category;
  final int totalAssignedCents; // sum of all monthly budget assignments
  final int lastMonthAssignedCents; // used as monthly contribution estimate
  final double progressPercent;
  final DateTime projectedDate;

  const GoalProgress({
    required this.category,
    required this.totalAssignedCents,
    required this.lastMonthAssignedCents,
    required this.progressPercent,
    required this.projectedDate,
  });

  int get goalCents => category.goalAmountCents ?? 0;
  int get remainingCents => (goalCents - totalAssignedCents).clamp(0, goalCents);
  bool get isComplete => totalAssignedCents >= goalCents;
}

/// Stream of categories that have a goal set, with progress calculations.
final goalsProvider = StreamProvider<List<GoalProgress>>((ref) async* {
  final db = ref.watch(databaseProvider);

  await for (final cats in db.categoriesDao.watchCategoriesWithGoals()) {
    final results = <GoalProgress>[];
    for (final cat in cats) {
      // Sum all monthly budget assignments for this category
      final budgets = await db.budgetDao.getBudgetsForCategory(cat.id);
      var totalAssigned = 0;
      for (final b in budgets) {
        totalAssigned += b.assignedCents;
      }

      // Use the most recent month's assigned as the monthly contribution estimate
      final lastMonthAssigned = budgets.isNotEmpty ? budgets.last.assignedCents : 0;

      final goalCents = cat.goalAmountCents ?? 0;
      final progress = GoalCalculator.progressPercent(
        currentCents: totalAssigned,
        goalCents: goalCents,
      );
      final projected = GoalCalculator.projectedDate(
        currentCents: totalAssigned,
        goalCents: goalCents,
        monthlyContributionCents: lastMonthAssigned,
      );

      results.add(GoalProgress(
        category: cat,
        totalAssignedCents: totalAssigned,
        lastMonthAssignedCents: lastMonthAssigned,
        progressPercent: progress,
        projectedDate: projected,
      ),);
    }
    yield results;
  }
});
