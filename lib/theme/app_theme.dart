import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const brandDark = Color(0xFF0D3B2E);
  static const brandPrimary = Color(0xFF1B5E3B);
  static const brandLight = Color(0xFF2E7D52);
  static const accent = Color(0xFFB8F397);
  static const accentGold = Color(0xFFF4D03F);
  static const surface = Color(0xFFF5F7F4);
  static const card = Colors.white;

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      primary: brandPrimary,
      secondary: brandLight,
      surface: surface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: brandDark,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: accent.withValues(alpha: 0.45),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontWeight: FontWeight.w600,
              color: brandDark,
              fontSize: 12,
            );
          }
          return const TextStyle(fontSize: 12, color: Colors.black54);
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: card,
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandPrimary,
          side: const BorderSide(color: brandLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static const team1Color = Color(0xFF1565C0);
  static const team2Color = Color(0xFFC62828);

  static BoxDecoration heroGradient = const BoxDecoration(
    gradient: LinearGradient(
      colors: [brandDark, brandPrimary, brandLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}
