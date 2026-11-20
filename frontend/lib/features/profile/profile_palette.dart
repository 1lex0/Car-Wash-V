import 'package:flutter/material.dart';

class ProfilePalette {
  final Color background;
  final Color card;
  final Color text;
  final Color subtext;
  final Color divider;
  final Color header;
  final Color headerSubtext;
  final Color avatar;

  const ProfilePalette({
    required this.background,
    required this.card,
    required this.text,
    required this.subtext,
    required this.divider,
    required this.header,
    required this.headerSubtext,
    required this.avatar,
  });

  static const light = ProfilePalette(
    background: Color(0xFFECE8DF),
    card: Color(0xFFF7F4EE),
    text: Color(0xFF1F3A33),
    subtext: Color(0xFF6F7D78),
    divider: Color(0xFFE0DCD4),
    header: Color(0xFF1F3A33),
    headerSubtext: Color(0xFF9DAAA5),
    avatar: Color(0xFF4E7469),
  );

  static const dark = ProfilePalette(
    background: Color(0xFF121816),
    card: Color(0xFF1C2421),
    text: Color(0xFFE4ECE8),
    subtext: Color(0xFF93A39D),
    divider: Color(0xFF2C3632),
    header: Color(0xFF2A3D37),
    headerSubtext: Color(0xFF9DAAA5),
    avatar: Color(0xFF4E7469),
  );

  static ProfilePalette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  static ThemeData themeFor(Brightness brightness, ThemeData base) {
    if (brightness == Brightness.light) return base;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1F3A33),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: dark.background,
    );
  }
}
