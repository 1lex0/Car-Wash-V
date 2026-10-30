import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frontend/data/mock_car_wash_repository.dart';
import 'package:frontend/features/iwash/repositories/mock_iwash_repository.dart';
import 'package:frontend/main.dart';
import 'package:frontend/models/car_wash_catalog_model.dart';
import 'package:frontend/models/favorites_model.dart';
import 'package:frontend/models/iwash_live_model.dart';

class AppHarness {
  final carWashRepository = MockCarWashRepository();
  final iWashRepository = MockIWashRepository();

  static const latency = Duration(milliseconds: 900);

  Widget build() {
    return MultiProvider(
      providers: [
        Provider<MockCarWashRepository>.value(value: carWashRepository),
        Provider<MockIWashRepository>.value(value: iWashRepository),
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

void usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}
