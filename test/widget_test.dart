import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myynab/core/database/database.dart';
import 'package:myynab/core/database/providers.dart';
import 'package:myynab/features/auth/auth_providers.dart';
import 'package:myynab/features/shell/main_shell.dart';
import 'package:myynab/core/theme/app_theme.dart';

void main() {
  testWidgets('App shell builds without crashing', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Use in-memory SQLite for tests
          databaseProvider.overrideWithValue(db),
          // Biometric disabled so lock screen never fires
          biometricEnabledProvider.overrideWith((_) async => false),
          // App starts unlocked
          isUnlockedProvider.overrideWith((_) => true),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const MainShell(),
        ),
      ),
    );

    // Let async providers settle
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
