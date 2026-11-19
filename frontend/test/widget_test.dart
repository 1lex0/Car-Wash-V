import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('Application starts', (WidgetTester tester) async {
    ensureTestRouter();
    await tester.pumpWidget(const CarWashApp());

    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
