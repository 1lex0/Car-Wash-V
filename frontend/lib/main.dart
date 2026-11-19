import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/auth_api.dart';
import 'data/http_car_wash_repository.dart';
import 'data/token_store.dart';
import 'features/iwash/repositories/http_iwash_repository.dart';
import 'models/car_wash_catalog_model.dart';
import 'models/favorites_model.dart';
import 'models/iwash_live_model.dart';
import 'router.dart';

// Сервер на ноутбуке: эмулятор Android видит его как 10.0.2.2
// (десктоп — localhost, телефон — IP ноутбука). Переопределение:
// flutter run --dart-define=API_BASE=http://192.168.0.10:8080
const apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:8080',
);

// Корень композиции: здесь решается, откуда приходят данные.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // prefs до runApp (C9)
  final tokens = TokenStore();
  final loggedIn = await tokens.read() != null; // запуск решает по token-у

  router = GoRouter(
    initialLocation: loggedIn ? '/home' : '/login',
    errorBuilder: routeErrorBuilder,
    routes: appRoutes, // маршруты L3, без изменений
  );

  // L5: mock → http. ЕДИНСТВЕННОЕ место, где сменился источник данных.
  void toLogin() => router.go('/login'); // 401 → login, в одном месте
  final carWashRepository = HttpCarWashRepository(
    apiBase,
    tokens,
    onUnauthorized: toLogin,
  );
  final iWashRepository = HttpIWashRepository(
    apiBase,
    tokens,
    onUnauthorized: toLogin,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthApi>(create: (_) => AuthApi(apiBase, tokens)),

        // DI — как на L4: модели получают интерфейс и не знают, что он http.
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
