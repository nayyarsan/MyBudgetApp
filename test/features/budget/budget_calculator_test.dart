import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/features/budget/budget_calculator.dart';

void main() {
  group('BudgetCalculator', () {
    test('available = assigned - spent when no rollover', () {
      final result = BudgetCalculator.available(
        assignedCents: 50000, // $500
        spentCents: 30000, // $300
        rolledOverCents: 0,
        rollover: false,
      );
      expect(result, 20000); // $200
    });

    test('available includes rollover when rollover enabled', () {
      final result = BudgetCalculator.available(
        assignedCents: 50000,
        spentCents: 30000,
        rolledOverCents: 10000, // $100 from last month
        rollover: true,
      );
      expect(result, 30000); // $200 available + $100 rolled = $300
    });

    test('rollover amount ignored when rollover disabled', () {
      final result = BudgetCalculator.available(
        assignedCents: 50000,
        spentCents: 30000,
        rolledOverCents: 10000,
        rollover: false,
      );
      expect(result, 20000); // rollover ignored
    });

    test('available is negative when overspent', () {
      final result = BudgetCalculator.available(
        assignedCents: 20000,
        spentCents: 35000,
        rolledOverCents: 0,
        rollover: false,
      );
      expect(result, -15000);
    });

    test('to be budgeted = income - total assigned', () {
      final tbb = BudgetCalculator.toBeBudgeted(
        totalIncomeCents: 500000,
        totalAssignedCents: 350000,
      );
      expect(tbb, 150000);
    });

    test('to be budgeted is negative when over-assigned', () {
      final tbb = BudgetCalculator.toBeBudgeted(
        totalIncomeCents: 300000,
        totalAssignedCents: 350000,
      );
      expect(tbb, -50000);
    });

    test('age of money calculation in days', () {
      final age = BudgetCalculator.ageOfMoney(
        incomeDate: DateTime(2026, 2, 1),
        spendingDate: DateTime(2026, 2, 21),
      );
      expect(age, 20);
    });

    test('age of money is 0 when income and spending same day', () {
      final now = DateTime(2026, 2, 21);
      final age = BudgetCalculator.ageOfMoney(
        incomeDate: now,
        spendingDate: now,
      );
      expect(age, 0);
    });
  });
}
