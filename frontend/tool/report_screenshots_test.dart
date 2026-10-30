import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/router.dart';

import '../test/support/app_harness.dart';

const _latency = AppHarness.latency;
const _transition = Duration(milliseconds: 600);
const _spinnerFrame = Duration(milliseconds: 300);

final _boundaryKey = GlobalKey();
late final String _outDir;

Future<void> _loadFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? 'C:/dev/flutter';
  final fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';

  Future<ByteData> bytes(String file) async =>
      ByteData.view(File('$fonts/$file').readAsBytesSync().buffer);

  final roboto = FontLoader('Roboto');
  for (final f in [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-light.ttf',
    'roboto-black.ttf',
  ]) {
    roboto.addFont(bytes(f));
  }
  await roboto.load();

  await (FontLoader(
    'MaterialIcons',
  )..addFont(bytes('materialicons-regular.otf'))).load();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary =
        _boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_outDir/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
  });
}

Future<void> _go(WidgetTester tester, String location) async {
  router.go(location);
  await tester.pump();
  await tester.pump(_transition);
}

Future<void> _precacheLogos(WidgetTester tester) async {
  final context = _boundaryKey.currentContext!;
  await tester.runAsync(() async {
    for (final logo in ['Lux-wash', 'E-wash', 'I-wash']) {
      await precacheImage(AssetImage('assets/logos/$logo.png'), context);
    }
  });
}

void main() {
  setUpAll(() async {
    _outDir = Platform.environment['SHOTS_DIR'] ?? 'build/report_screenshots';
    Directory(_outDir).createSync(recursive: true);
    await _loadFonts();
  });

  testWidgets('скриншоты для отчета', (tester) async {
    usePhoneScreen(tester);
    final app = AppHarness();

    router.go('/login');
    await tester.pumpWidget(
      RepaintBoundary(key: _boundaryKey, child: app.build()),
    );
    await _precacheLogos(tester);
    await tester.pump();
    await _shot(tester, '01_login');

    app.simulateError = true;
    router.go('/search');
    await tester.pump();
    await tester.pump(_spinnerFrame);
    await _shot(tester, '02_search_loading');

    await tester.pump(_latency);
    await _shot(tester, '03_search_error');

    app.simulateError = false;
    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pump(_latency);
    await _shot(tester, '04_search_data');

    await tester.tap(find.text('I-Wash'));
    await tester.pump();
    await tester.pump(_transition);
    await _shot(tester, '05_details');

    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pump();
    await _shot(tester, '06_details_favorite');

    await _go(tester, '/home');
    await _shot(tester, '07_home_badge_1');

    await _go(tester, '/search');
    await tester.tap(find.byTooltip('Add car wash'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(_spinnerFrame);
    expect(find.text('Name is required'), findsOneWidget);
    await _shot(tester, '08_form_errors');

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Aqua Wash',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Area'),
      'Ciocana',
    );
    await tester.pump();
    await tester.pump(_spinnerFrame);
    await _shot(tester, '09_form_filled');

    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(_spinnerFrame);
    await _shot(tester, '10_form_saving');

    await tester.pump(_latency);
    await tester.pump(_transition);
    await _shot(tester, '11_search_grown');

    await tester.tap(find.text('Aqua Wash'));
    await tester.pump();
    await tester.pump(_transition);
    await tester.tap(find.byTooltip('Add to favorites'));
    await tester.pump();
    await _shot(tester, '12_new_details_favorite');

    await _go(tester, '/home');
    await _shot(tester, '13_home_badge_2_before');

    await _go(tester, '/search/favorites');
    await _shot(tester, '14_favorites_before');

    await _go(tester, '/search/1000');
    await tester.tap(find.byTooltip('Delete car wash'));
    await tester.pump();
    await tester.pump(_transition);
    await _shot(tester, '15_delete_dialog');

    await tester.tap(find.text('Delete'));
    await tester.pump(_latency);
    await tester.pump(_transition);
    await _shot(tester, '16_search_after');

    await _go(tester, '/home');
    await _shot(tester, '17_home_badge_1_after');

    await _go(tester, '/search/favorites');
    await _shot(tester, '18_favorites_after');

    await _go(tester, '/search/1000');
    await _shot(tester, '19_details_not_exist');

    router.go('/search/3/map');
    await tester.pump();
    await tester.pump();
    await tester.pump(_spinnerFrame);
    await _shot(tester, '20_map_loading');

    await tester.pump(_latency);
    await _shot(tester, '21_map_data');

    await _go(tester, '/profile');
    final toggle = find.byType(SwitchListTile);
    await tester.scrollUntilVisible(toggle, 200);
    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(_transition);
    await _shot(tester, '22_profile_failure_on');

    await _go(tester, '/search/3/map');
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pump();
    await tester.pump(_latency);
    await _shot(tester, '23_map_error');

    await _go(tester, '/search/new');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name'),
      'Aqua Wash',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Area'),
      'Ciocana',
    );
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump(_latency);
    await tester.pump(_transition);
    await _shot(tester, '24_form_error_snackbar');

    await tester.pump(const Duration(seconds: 6));
  });
}
