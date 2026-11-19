import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'fake_repositories.dart';

import 'package:frontend/main.dart';
import 'package:frontend/models/car_wash_catalog_model.dart';
import 'package:frontend/models/favorites_model.dart';
import 'package:frontend/models/iwash_live_model.dart';
import 'package:frontend/router.dart';

class AppHarness {
  final carWashRepository = FakeCarWashRepository();
  final iWashRepository = FakeIWashRepository();

  static const latency = Duration(milliseconds: 900);

  Widget build() {
    ensureTestRouter();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CarWashCatalogModel(carWashRepository)..load(),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesModel()),
        ChangeNotifierProvider(create: (_) => IWashLiveModel(iWashRepository)),
      ],
      child: const CarWashApp(),
    );
  }

  set simulateError(bool value) {
    carWashRepository.simulateError = value;
    iWashRepository.simulateError = value;
  }
}

// router — late final (L5): в тестах присваиваем один раз на isolate,
// стартуя с login, как приложение без token-а.
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
