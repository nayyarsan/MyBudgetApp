import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/features/transactions/add_transaction_screen.dart';

void main() {
  testWidgets('shows required fields on the form', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AddTransactionScreen()),
      ),
    );
    await tester.pump();

    // Type selector is present
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);

    // Key fields present
    expect(find.text('Payee'), findsOneWidget);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Memo (optional)'), findsOneWidget);
  });

  testWidgets('shows validation error when amount is empty',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AddTransactionScreen()),
      ),
    );
    await tester.pump();

    // Tap Save without entering amount
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();

    expect(find.text('Amount is required'), findsOneWidget);
  });

  testWidgets('shows validation error for invalid amount',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AddTransactionScreen()),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount'),
      'abc',
    );
    await tester.tap(find.text('Save Transaction'));
    await tester.pump();

    expect(find.text('Enter a valid number'), findsOneWidget);
  });
}
