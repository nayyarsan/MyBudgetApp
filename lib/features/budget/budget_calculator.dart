/// Pure business logic for zero-based budget calculations.
/// No Flutter or database dependencies — all methods are static and pure.
class BudgetCalculator {
  /// Returns the available balance for a category.
  ///
  /// available = assigned - spent + (rolledOver if rollover enabled)
  static int available({
    required int assignedCents,
    required int spentCents,
    required int rolledOverCents,
    required bool rollover,
  }) {
    final rolloverAmount = rollover ? rolledOverCents : 0;
    return assignedCents - spentCents + rolloverAmount;
  }

  /// Returns the "To Be Budgeted" amount for a month.
  ///
  /// TBB = total income received - total assigned to categories.
  /// Negative means over-assigned (more assigned than income available).
  static int toBeBudgeted({
    required int totalIncomeCents,
    required int totalAssignedCents,
  }) {
    return totalIncomeCents - totalAssignedCents;
  }

  /// Returns the age of money in days.
  ///
  /// Age of money = days between when income was received and when it was spent.
  /// Higher values indicate more financial stability (money sits longer before use).
  static int ageOfMoney({
    required DateTime incomeDate,
    required DateTime spendingDate,
  }) {
    return spendingDate.difference(incomeDate).inDays;
  }
}
