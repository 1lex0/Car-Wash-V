import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/profile_model.dart';
import 'package:frontend/models/settings_model.dart';
import 'package:frontend/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/app_harness.dart';
import 'support/fake_repositories.dart';

const _transition = Duration(milliseconds: 600);

Future<void> _openProfile(WidgetTester tester, AppHarness app) async {
  usePhoneScreen(tester);
  router.go('/profile');
  await tester.pumpWidget(app.build());
  await tester.pump();
  await tester.pump(_transition);
}

Future<void> _tapRow(WidgetTester tester, String title) async {
  final row = find.text(title);
  await tester.scrollUntilVisible(row, 200);
  await tester.tap(row);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(ensureTestRouter);

  group('ProfileModel', () {
    test('load берёт пользователя из repository', () async {
      final model = ProfileModel(FakeAccountRepository());
      await model.load();
      expect(model.user!.email, 'alex@test.md');
      expect(model.error, isNull);
    });

    test(
      'updateEmail: занятый email даёт текст ошибки, пользователь не меняется',
      () async {
        final model = ProfileModel(FakeAccountRepository());
        await model.load();
        final error = await model.updateEmail('taken@test.md');
        expect(error, 'Аккаунт с этим email уже существует');
        expect(model.user!.email, 'alex@test.md');
      },
    );

    test(
      'changePassword: неверный текущий пароль → ошибка, верный → null',
      () async {
        final model = ProfileModel(FakeAccountRepository());
        expect(
          await model.changePassword('gresit', 'nou12345'),
          'Неверный текущий пароль',
        );
        expect(await model.changePassword('parola123', 'nou12345'), isNull);
      },
    );
  });

  group('SettingsModel', () {
    test('настройка сохраняется в prefs и читается заново', () async {
      SharedPreferences.setMockInitialValues({});
      final first = SettingsModel();
      await first.setVehicleModel('Dacia Logan');
      await first.setTheme(AppThemeChoice.dark);
      await first.setTextSize(TextSizeChoice.large);

      final second = SettingsModel();
      await second.load();
      expect(second.vehicleModel, 'Dacia Logan');
      expect(second.theme, AppThemeChoice.dark);
      expect(second.textScale, 1.15);
    });
  });

  group('Экран профиля', () {
    testWidgets('показывает имя с сервера и скрытый email', (tester) async {
      await _openProfile(tester, AppHarness());
      expect(find.text('Alex'), findsOneWidget);
      expect(find.text('a***@test.md'), findsOneWidget);
    });

    testWidgets('смена имени через диалог', (tester) async {
      final app = AppHarness();
      await _openProfile(tester, app);

      await tester.tap(find.text('Alex'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Alexandr');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Alexandr'), findsOneWidget);
      expect(app.accountRepository.user.name, 'Alexandr');
      expect(find.text('Name updated'), findsOneWidget);
    });

    testWidgets('занятый email → SnackBar с переведённой ошибкой', (
      tester,
    ) async {
      await _openProfile(tester, AppHarness());

      await _tapRow(tester, 'Email');
      await tester.enterText(find.byType(TextFormField), 'taken@test.md');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Аккаунт с этим email уже существует'), findsOneWidget);
    });

    testWidgets('смена машины видна в строке профиля', (tester) async {
      await _openProfile(tester, AppHarness());

      await _tapRow(tester, 'Vehicle');
      await tester.enterText(find.byType(TextFormField), 'Dacia Logan');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Dacia Logan'), findsOneWidget);
    });

    testWidgets('тёмная тема перекрашивает профиль', (tester) async {
      await _openProfile(tester, AppHarness());

      await _tapRow(tester, 'Theme');
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
      expect(scaffold.backgroundColor, const Color(0xFF121816));
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('переключатель Location меняет настройку', (tester) async {
      await _openProfile(tester, AppHarness());

      final location = find.text('Location');
      await tester.scrollUntilVisible(location, 200);
      final before = tester.widget<Switch>(find.byType(Switch).last).value;
      await tester.tap(location);
      await tester.pump();
      expect(tester.widget<Switch>(find.byType(Switch).last).value, !before);
    });
  });
}
