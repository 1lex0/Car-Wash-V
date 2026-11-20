import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/auth_api.dart';
import 'data/http_account_repository.dart';
import 'data/http_car_wash_repository.dart';
import 'data/token_store.dart';
import 'features/iwash/repositories/http_iwash_repository.dart';
import 'models/car_wash_catalog_model.dart';
import 'models/favorites_model.dart';
import 'models/iwash_live_model.dart';
import 'models/profile_model.dart';
import 'models/settings_model.dart';
import 'router.dart';

const apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:8080',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final tokens = TokenStore();
  final loggedIn = await tokens.read() != null;

  router = GoRouter(
    initialLocation: loggedIn ? '/home' : '/login',
    errorBuilder: routeErrorBuilder,
    routes: appRoutes,
  );

  void toLogin() => router.go('/login');
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
  final accountRepository = HttpAccountRepository(
    apiBase,
    tokens,
    onUnauthorized: toLogin,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthApi>(create: (_) => AuthApi(apiBase, tokens)),

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

      builder: (context, child) {
        final scale = context.watch<SettingsModel>().textScale;
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        );
      },
    );
  }
}
