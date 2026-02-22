// Basic smoke test for MyYnabApp.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myynab/main.dart';

void main() {
  testWidgets('MyYnabApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MyYnabApp()),
    );
    expect(find.text('MyYNAB \u2014 setting up...'), findsOneWidget);
  });
}
