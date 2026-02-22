import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myynab/features/budget/budget_providers.dart';

void main() {
  group('selectedMonthProvider', () {
    test('defaults to current month', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final month = container.read(selectedMonthProvider);
      final now = DateTime.now();
      expect(month.year, now.year);
      expect(month.month, now.month);
    });

    test('can be updated to a different month', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(selectedMonthProvider.notifier).state =
          DateTime(2026, 3);
      final updated = container.read(selectedMonthProvider);
      expect(updated.month, 3);
      expect(updated.year, 2026);
    });
  });

  group('monthKey', () {
    test('formats single-digit month with leading zero', () {
      expect(monthKey(DateTime(2026, 3)), '2026-03');
    });

    test('formats double-digit month correctly', () {
      expect(monthKey(DateTime(2026, 12)), '2026-12');
    });
  });
}
