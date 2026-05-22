import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Peak Performance design tokens (whoop dark).
abstract final class AppTheme {
  static const background = Color(0xFF0F1513);
  static const surface = Color(0xFF0F1513);
  static const surfaceContainerLow = Color(0xFF171D1B);
  static const surfaceContainer = Color(0xFF1B211F);
  static const surfaceContainerHigh = Color(0xFF252B29);
  static const surfaceContainerHighest = Color(0xFF303634);
  static const onSurface = Color(0xFFDEE4E0);
  static const onSurfaceVariant = Color(0xFFBACBBD);
  static const primary = Color(0xFF43ED9E);
  static const onPrimary = Color(0xFF003920);
  static const primaryContainer = Color(0xFF00D084);
  static const secondary = Color(0xFFC8C6C5);
  static const outline = Color(0xFF859588);
  static const error = Color(0xFFFFB4AB);
  static const glassFill = Color(0xCC1A1A1A);
  static const glassBorder = Color(0x1AFFFFFF);

  static const marginMobile = 16.0;
  static const cardPadding = 20.0;
  static const radiusSm = 8.0;
  static const radiusMd = 12.0;
  static const radiusLg = 16.0;
  static const radiusXl = 24.0;

  // Legacy aliases used across the app.
  static const brandDark = onSurface;
  static const brandPrimary = primary;
  static const brandLight = primaryContainer;
  static const accent = primary;
  static const accentGold = Color(0xFFF4D03F);
  static const surfaceDim = surfaceContainer;
  static const card = surfaceContainer;

  static const team1Color = Color(0xFF43ED9E);
  static const team2Color = Color(0xFFFFB4AB);

  static TextStyle get _sora => GoogleFonts.sora();

  static TextTheme _buildTextTheme(ColorScheme scheme) {
    return TextTheme(
      displayLarge: _sora.copyWith(
        fontSize: 48,
        height: 56 / 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 48,
        color: scheme.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      headlineMedium: _sora.copyWith(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      headlineSmall: _sora.copyWith(
        fontSize: 20,
        height: 24 / 20,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleLarge: _sora.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: _sora.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: _sora.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: _sora.copyWith(
        fontSize: 16,
        height: 24 / 16,
        color: scheme.onSurface,
      ),
      bodyMedium: _sora.copyWith(
        fontSize: 16,
        height: 24 / 16,
        color: scheme.onSurfaceVariant,
      ),
      bodySmall: _sora.copyWith(
        fontSize: 12,
        height: 16 / 12,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: labelCaps(scheme),
      labelSmall: _sora.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.08 * 10,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  static TextStyle labelCaps(ColorScheme scheme, {Color? color}) {
    return _sora.copyWith(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.08 * 12,
      color: color ?? scheme.onSurfaceVariant,
    );
  }

  static TextStyle dataMono(ColorScheme scheme, {Color? color, double size = 20}) {
    return _sora.copyWith(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color ?? scheme.primary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimary,
      secondary: secondary,
      onSecondary: Color(0xFF313030),
      error: error,
      onError: Color(0xFF690005),
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: GoogleFonts.sora().fontFamily,
      textTheme: _buildTextTheme(scheme),
      appBarTheme: AppBarTheme(
        backgroundColor: background.withValues(alpha: 0.8),
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: _sora.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: glassBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: labelCaps(scheme).copyWith(color: onPrimary, fontSize: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: const BorderSide(color: glassBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        labelStyle: TextStyle(color: onSurfaceVariant),
        hintStyle: TextStyle(color: onSurfaceVariant.withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceContainerHigh,
        labelStyle: labelCaps(scheme).copyWith(fontSize: 10),
        side: BorderSide(color: primary.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),
      dividerTheme: const DividerThemeData(color: glassBorder, thickness: 1),
      iconTheme: const IconThemeData(color: onSurface),
    );
  }

  /// Back-compat: app is dark-first.
  static ThemeData get light => dark;

  static BoxDecoration glass({
    bool glow = false,
    double radius = radiusLg,
  }) {
    return BoxDecoration(
      color: glassFill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: glassBorder),
      boxShadow: glow
          ? [
              BoxShadow(
                color: primary.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ]
          : null,
    );
  }

  static Widget glassSurface({
    required Widget child,
    bool glow = false,
    double radius = radiusLg,
    EdgeInsetsGeometry? padding,
    VoidCallback? onTap,
  }) {
    final box = Container(
      padding: padding ?? const EdgeInsets.all(cardPadding),
      decoration: glass(glow: glow, radius: radius),
      child: child,
    );

    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: box,
      ),
    );
  }

  static BoxDecoration get heroGradient => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            surfaceContainerHigh,
            primary.withValues(alpha: 0.35),
            surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      );
}
