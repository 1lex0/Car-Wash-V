import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/router.dart';
import 'package:frontend/widgets/car_wash_card.dart';
import 'package:frontend/widgets/error_view.dart';

import 'support/app_harness.dart';

const _latency = AppHarness.latency;
const _transition = Duration(milliseconds: 600);

Future<void> _open(WidgetTester tester, String location) async {
  router.go(location);
  await tester.pump();
  await tester.pump(_transition);
}

void main() {
  testWidgets('каталог показывает загрузку', (tester) async {
    usePhoneScreen(tester);
    router.go('/search');
    await tester.pumpWidget(AppHarness().build());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(CarWashCard), findsNothing);

    await tester.pump(_latency);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(CarWashCard), findsNWidgets(3));
  });

  testWidgets('каталог: ошибка, потом retry и данные', (tester) async {
    usePhoneScreen(tester);
    final app = AppHarness()..simulateError = true;
    router.go('/search');
    await tester.pumpWidget(app.build());
    await tester.pump(_latency);

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.textContaining('Server is not responding'), findsOneWidget);

    app.simulateError = false;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(_latency);
    expect(find.byType(ErrorView), findsNothing);
    expect(find.byType(CarWashCard), findsNWidgets(3));
  });

  testWidgets('избранное из деталей появляется на главном', (tester) async {
    usePhoneScreen(tester);
    router.go('/search/3');
    await tester.pumpWidget(AppHarness().build());
    await tester.pump(_latency);

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pump();
    expect(find.byTooltip('Remove from favorites'), findsOneWidget);

    await _open(tester, '/home');
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsOneWidget,
    );

    await _open(tester, '/search/favorites');
    expect(find.text('I-Wash'), findsOneWidget);

    await tester.drag(find.text('I-Wash'), const Offset(-500, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('No favorites yet'), findsOneWidget);
  });

  testWidgets('форма проверяет поля и добавляет мойку', (tester) async {
    usePhoneScreen(tester);
    router.go('/search');
    await tester.pumpWidget(AppHarness().build());
    await tester.pump(_latency);

    await tester.tap(find.byTooltip('Add car wash'));
    await tester.pump(_transition);

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Area is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Aqua Wash',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Area'),
      'Ciocana',
    );
    await tester.tap(find.text('Save'));
    await tester.pump(_latency);
    await tester.pump(_transition);

    expect(find.text('Add car wash'), findsNothing);
    expect(find.byType(CarWashCard), findsNWidgets(4));
    expect(find.text('Aqua Wash'), findsOneWidget);
  });

  testWidgets('форма при ошибке сервера не стирает поля', (tester) async {
    usePhoneScreen(tester);
    final app = AppHarness();
    router.go('/search/new');
    await tester.pumpWidget(app.build());
    await tester.pump(_latency);

    app.simulateError = true;
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Aqua Wash',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Area'),
      'Ciocana',
    );
    await tester.tap(find.text('Save'));
    await tester.pump(_latency);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Aqua Wash'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('удаление мойки через диалог', (tester) async {
    usePhoneScreen(tester);
    router.go('/search/2');
    await tester.pumpWidget(AppHarness().build());
    await tester.pump(_latency);

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pump();

    await tester.tap(find.byTooltip('Delete car wash'));
    await tester.pump(_transition);
    expect(find.text('Delete car wash?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pump(_latency);
    await tester.pump(_transition);

    await _open(tester, '/search');
    expect(find.byType(CarWashCard), findsNWidgets(2));
    expect(find.text('E-Wash'), findsNothing);

    await _open(tester, '/home');
    expect(find.byType(Badge), findsOneWidget);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsNothing,
    );
  });

  testWidgets('детали для мойки которой нет', (tester) async {
    usePhoneScreen(tester);
    router.go('/search/999');
    await tester.pumpWidget(AppHarness().build());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(_latency);
    expect(find.text('Car wash does not exist'), findsOneWidget);
  });

  testWidgets('карта I-Wash: загрузка, ошибка и retry', (tester) async {
    usePhoneScreen(tester);
    final app = AppHarness();
    router.go('/search/3/map');
    await tester.pumpWidget(app.build());
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(_latency);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.byType(ErrorView), findsNothing);

    app.simulateError = true;
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump(_latency);
    expect(find.byType(ErrorView), findsOneWidget);

    app.simulateError = false;
    await tester.tap(find.text('Retry'));
    await tester.pump(_latency);
    expect(find.byType(ErrorView), findsNothing);
  });

  testWidgets('переключатель в профиле включает ошибку', (tester) async {
    usePhoneScreen(tester);
    final app = AppHarness();
    router.go('/profile');
    await tester.pumpWidget(app.build());
    await tester.pump(_transition);

    final toggle = find.byType(SwitchListTile);
    await tester.scrollUntilVisible(toggle, 200);
    await tester.tap(toggle);
    await tester.pump();

    expect(app.carWashRepository.simulateError, isTrue);
    expect(app.iWashRepository.simulateError, isTrue);
  });
}
