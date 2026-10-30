import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/mock_car_wash_repository.dart';
import 'features/iwash/repositories/mock_iwash_repository.dart';
import 'models/car_wash_catalog_model.dart';
import 'models/favorites_model.dart';
import 'models/iwash_live_model.dart';
import 'router.dart';

void main() {
  final carWashRepository = MockCarWashRepository();
  final iWashRepository = MockIWashRepository();

  runApp(
    MultiProvider(
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
    ),
  );
}

class CarWashApp extends StatelessWidget {
  const CarWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: '2D Wash',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFECE8DF),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F3A33),
          brightness: Brightness.light,
        ),
      ),

      routerConfig: router,
    );
  }
}
