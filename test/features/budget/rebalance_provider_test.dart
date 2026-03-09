import 'package:flutter_test/flutter_test.dart';
import 'package:moneyinsight/features/budget/rebalance_provider.dart';

void main() {
  group('RebalanceSuggestion logic', () {
    test('no suggestions when nothing is overspent', () {
      final suggestions = computeRebalanceSuggestions(
        categoryData: [
          CategoryBudgetData(id: 1, name: 'Groceries', assigned: 40000, spent: 30000),
          CategoryBudgetData(id: 2, name: 'Dining', assigned: 20000, spent: 15000),
        ],
      );
      expect(suggestions, isEmpty);
    });

    test('suggests pulling from surplus to cover overage', () {
      final suggestions = computeRebalanceSuggestions(
        categoryData: [
          CategoryBudgetData(id: 1, name: 'Groceries', assigned: 40000, spent: 50000), // -$100 overage
          CategoryBudgetData(id: 2, name: 'Dining', assigned: 20000, spent: 5000),     // +$150 surplus
        ],
      );
      expect(suggestions.length, 1);
      expect(suggestions.first.fromCategoryId, 2); // pull from Dining
      expect(suggestions.first.toCategoryId, 1);   // to cover Groceries
      expect(suggestions.first.amountCents, 10000); // $100 transfer
    });

    test('caps transfer at available surplus', () {
      final suggestions = computeRebalanceSuggestions(
        categoryData: [
          CategoryBudgetData(id: 1, name: 'Groceries', assigned: 40000, spent: 70000), // -$300 overage
          CategoryBudgetData(id: 2, name: 'Dining', assigned: 20000, spent: 10000),    // +$100 surplus only
        ],
      );
      // Can only cover $100 of the $300 overage
      expect(suggestions.first.amountCents, 10000);
    });
  });
}
