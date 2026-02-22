/// Pure business logic for savings goal calculations.
class GoalCalculator {
  /// Returns progress as a fraction between 0.0 and 1.0.
  static double progressPercent({
    required int currentCents,
    required int goalCents,
  }) {
    if (goalCents <= 0) return 0;
    return (currentCents / goalCents).clamp(0.0, 1.0);
  }

  /// Returns the projected completion date based on current monthly contribution.
  /// Returns DateTime(9999) if contribution is zero or negative.
  static DateTime projectedDate({
    required int currentCents,
    required int goalCents,
    required int monthlyContributionCents,
  }) {
    if (monthlyContributionCents <= 0) return DateTime(9999);
    final remaining = goalCents - currentCents;
    if (remaining <= 0) return DateTime.now(); // already done
    final monthsNeeded = (remaining / monthlyContributionCents).ceil();
    final now = DateTime.now();
    return DateTime(now.year, now.month + monthsNeeded);
  }
}
