import 'package:flutter/material.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const CarWashApp());
}

class CarWashApp extends StatelessWidget {
  const CarWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    const spaceGrey = Color(0xFF4E4C4B);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Car Wash',
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: spaceGrey,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: const Color(0xFFF5F5F2),

        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.w700,
            height: 0.95,
            letterSpacing: -2.0,
            color: Color(0xFF111111),
          ),
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.0,
            letterSpacing: -1.1,
            color: Color(0xFF111111),
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: Color(0xFF111111),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: Color(0xFF111111),
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: -0.2,
            color: Color(0xFF2A2A2A),
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.35,
            letterSpacing: -0.2,
            color: Color(0xFF2A2A2A),
          ),
          bodySmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B6B6B),
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          hintStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8A8A8A),
            letterSpacing: -0.2,
          ),
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
            letterSpacing: -0.2,
          ),
          prefixIconColor: const Color(0xFF6A6A6A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFE0E0E0),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: Color(0xFFE0E0E0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: spaceGrey,
              width: 1.4,
            ),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: spaceGrey,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF111111),
            side: const BorderSide(color: Color(0xFFD9D9D9)),
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF111111),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const MainShell(),
    );
  }
}