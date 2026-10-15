import 'package:flutter/material.dart';

import 'router.dart';

void main() {
  runApp(const CarWashApp());
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

        scaffoldBackgroundColor:
            const Color(0xFFECE8DF),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F3A33),
          brightness: Brightness.light,
        ),
      ),

      routerConfig: router,
    );
  }
}