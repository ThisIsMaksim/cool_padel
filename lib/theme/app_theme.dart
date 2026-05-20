import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _courtGreen = Color(0xFF1B5E3B);
  static const _courtLight = Color(0xFF2E7D52);
  static const _accent = Color(0xFFE8F5A3);
  static const _surface = Color(0xFFF4F7F2);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _courtGreen,
      primary: _courtGreen,
      secondary: _courtLight,
      surface: _surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: _courtGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _courtGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _courtLight,
        foregroundColor: Colors.white,
      ),
    );
  }

  static const team1Color = Color(0xFF1565C0);
  static const team2Color = Color(0xFFC62828);
  static const accentColor = _accent;
}
