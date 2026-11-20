import 'package:flutter_test/flutter_test.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('Application starts', (WidgetTester tester) async {
    await tester.pumpWidget(AppHarness().build());

    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
