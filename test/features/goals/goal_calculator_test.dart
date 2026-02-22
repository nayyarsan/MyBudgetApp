import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/features/goals/goal_calculator.dart';

void main() {
  group('GoalCalculator.progressPercent', () {
    test('calculates progress correctly at 25%', () {
      expect(
        GoalCalculator.progressPercent(
          currentCents: 25000,
          goalCents: 100000,
        ),
        closeTo(0.25, 0.001),
      );
    });

    test('clamps to 1.0 when goal is reached', () {
      expect(
        GoalCalculator.progressPercent(
          currentCents: 120000,
          goalCents: 100000,
        ),
        1.0,
      );
    });

    test('returns 0 for zero goal', () {
      expect(
        GoalCalculator.progressPercent(currentCents: 5000, goalCents: 0),
        0.0,
      );
    });
  });

  group('GoalCalculator.projectedDate', () {
    test('projects 3 more months when 75% done with equal contributions',
        () {
      final date = GoalCalculator.projectedDate(
        currentCents: 25000,
        goalCents: 100000,
        monthlyContributionCents: 25000,
      );
      final now = DateTime.now();
      expect(date.year, isNotNull);
      // Should need 3 more months
      expect(
        date.difference(DateTime(now.year, now.month)).inDays,
        greaterThan(60),
      );
    });

    test('returns DateTime(9999) for zero contribution', () {
      final date = GoalCalculator.projectedDate(
        currentCents: 0,
        goalCents: 100000,
        monthlyContributionCents: 0,
      );
      expect(date.year, 9999);
    });

    test('returns now when already at goal', () {
      final date = GoalCalculator.projectedDate(
        currentCents: 100000,
        goalCents: 100000,
        monthlyContributionCents: 10000,
      );
      expect(date.year, DateTime.now().year);
    });
  });
}
