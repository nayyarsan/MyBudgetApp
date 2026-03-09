import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moneyinsight/core/database/database.dart';
import 'package:moneyinsight/core/database/providers.dart';
import 'package:moneyinsight/core/services/rollover_provider.dart';
import 'package:moneyinsight/core/theme/app_theme.dart';
import 'package:moneyinsight/features/auth/auth_providers.dart';
import 'package:moneyinsight/features/auth/firebase_auth_service.dart';
import 'package:moneyinsight/features/shell/main_shell.dart';
import 'package:moneyinsight/features/sync/sync_service.dart';

class _FalseRolloverNotifier extends GlobalRolloverNotifier {
  @override
  Future<bool> build() async => false;
}

void main() {
  testWidgets('App shell builds without crashing', (WidgetTester tester) async {
    final db = AppDatabase.forTesting();

        await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // In-memory SQLite — no platform channels
          databaseProvider.overrideWithValue(db),
          // Biometric off — avoids flutter_secure_storage platform channel
          biometricEnabledProvider.overrideWith((_) async => false),
          // App starts unlocked
          isUnlockedProvider.overrideWith((_) => true),
          // Firebase unavailable in unit tests
          firebaseUserProvider.overrideWith((_) => Stream.value(null)),
          isSignedInProvider.overrideWith((_) => false),
          // Sync last-sync timestamp — avoids flutter_secure_storage
          lastSyncProvider.overrideWith((_) async => null),
          // Global rollover setting — avoids flutter_secure_storage
          globalRolloverEnabledProvider.overrideWith(_FalseRolloverNotifier.new),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const MainShell(),
        ),
      ),
    );

    // One pump to process the first frame
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);

    // Dispose the widget tree first so Riverpod cancels all DB stream subs,
    // then close the DB — avoids db.close() hanging on pending subscribers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(Duration.zero);
    await db.close();
  });
}
