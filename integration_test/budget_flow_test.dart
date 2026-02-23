import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myynab/core/database/database.dart';
import 'package:myynab/core/database/providers.dart';
import 'package:myynab/features/auth/auth_providers.dart';
import 'package:myynab/features/shell/main_shell.dart';
import 'package:myynab/core/theme/app_theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting();
  });

  tearDown(() => db.close());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          biometricEnabledProvider.overrideWith((_) async => false),
          isUnlockedProvider.overrideWith((_) => true),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MainShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Full budget flow: add account, add category, add transaction',
      (tester) async {
    await pumpApp(tester);

    // ---- Step 1: Add an account ----
    // Navigate to Accounts tab (index 2)
    await tester.tap(find.byIcon(Icons.account_balance_outlined));
    await tester.pumpAndSettle();

    // Tap FAB to open Add Account form
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Account name'), 'Checking',);
    await tester.pumpAndSettle();

    // Submit form
    await tester.tap(find.text('Add Account'));
    await tester.pumpAndSettle();

    // Account should appear in the list
    expect(find.text('Checking'), findsWidgets);

    // ---- Step 2: Add a category group + category on Budget tab ----
    // Navigate to Budget tab (index 0)
    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pumpAndSettle();

    // Tap the "Add group" FAB or button — the budget screen has a FAB
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill the group name dialog
    await tester.enterText(find.byType(TextField).last, 'Food');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Food'), findsOneWidget);

    // ---- Step 3: Add a transaction ----
    // Navigate to Transactions tab (index 1)
    await tester.tap(find.byIcon(Icons.list_outlined));
    await tester.pumpAndSettle();

    // Tap FAB to add a transaction
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Fill in payee
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Payee'), 'Grocery Store',);

    // Fill in amount
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount'), '45.00',);

    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Transaction should appear in the list
    expect(find.text('Grocery Store'), findsOneWidget);
  });
}
