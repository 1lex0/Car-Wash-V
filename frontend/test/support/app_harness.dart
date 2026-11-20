import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_repositories.dart';

import 'package:frontend/main.dart';
import 'package:frontend/models/car_wash_catalog_model.dart';
import 'package:frontend/models/favorites_model.dart';
import 'package:frontend/models/iwash_live_model.dart';
import 'package:frontend/models/profile_model.dart';
import 'package:frontend/models/settings_model.dart';
import 'package:frontend/router.dart';

class AppHarness {
  final carWashRepository = FakeCarWashRepository();
  final iWashRepository = FakeIWashRepository();
  final accountRepository = FakeAccountRepository();

  static const latency = Duration(milliseconds: 900);

  Widget build() {
    ensureTestRouter();
    SharedPreferences.setMockInitialValues({});
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CarWashCatalogModel(carWashRepository)..load(),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesModel()),
        ChangeNotifierProvider(create: (_) => IWashLiveModel(iWashRepository)),
        ChangeNotifierProvider(
          create: (_) => ProfileModel(accountRepository)..load(),
        ),
        ChangeNotifierProvider(create: (_) => SettingsModel()..load()),
      ],
      child: const CarWashApp(),
    );
  }

  set simulateError(bool value) {
    carWashRepository.simulateError = value;
    iWashRepository.simulateError = value;
  }
}

bool _routerReady = false;
void ensureTestRouter() {
  if (_routerReady) return;
  router = GoRouter(
    initialLocation: '/login',
    errorBuilder: routeErrorBuilder,
    routes: appRoutes,
  );
  _routerReady = true;
}

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}
