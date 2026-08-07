import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------
/// AppColors — the full Atelier palette, dark/brass "heritage garage"
/// theme. Import this wherever you need a raw colour value; use
/// AppTheme.dark (below) wherever you need it wired into widgets via
/// Theme.of(context).
/// ---------------------------------------------------------------------
class AppColors {
  static const ink = Color(0xFF14110E);
  static const panel = Color(0xFF1C1812);
  static const panelAlt = Color(0xFF221D16);
  static const line = Color(0xFF3A3225);
  static const brass = Color(0xFFC08A3E);
  static const brassHigh = Color(0xFFE0AE64);
  static const ember = Color(0xFFC0542E);
  static const cream = Color(0xFFE9E1D0);
  static const muted = Color(0xFF9C9081);
  static const mutedDark = Color(0xFF6E6555);
}

/// ---------------------------------------------------------------------
/// AppTheme — a single ThemeData built from AppColors + IBM Plex Sans.
/// Wire it up in main.dart:
///
///   MaterialApp(
///     theme: AppTheme.dark,
///     home: const HomeScreen(),
///   )
/// ---------------------------------------------------------------------

class AppTheme {
  AppTheme._();

  static const _fontFamily = 'IBMPlexSans';

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.ink,
      primaryColor: AppColors.brass,

      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.brass,
        onPrimary: AppColors.ink,
        secondary: AppColors.brassHigh,
        onSecondary: AppColors.ink,
        surface: AppColors.panel,
        onSurface: AppColors.cream,
        error: AppColors.ember,
        onError: AppColors.cream,
        outline: AppColors.line,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.cream),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: AppColors.cream,
        ),
      ),

      textTheme: base.textTheme
          .apply(
            fontFamily: _fontFamily,
            bodyColor: AppColors.cream,
            displayColor: AppColors.cream,
          )
          .copyWith(
            headlineLarge: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
              height: 1.05,
            ),
            headlineMedium: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
            titleLarge: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.cream,
            ),
            titleMedium: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.cream,
            ),
            bodyLarge: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
              height: 1.6,
            ),
            bodyMedium: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
              height: 1.5,
            ),
            labelSmall: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
              color: AppColors.brass,
            ),
            labelMedium: const TextStyle(
              fontFamily: _fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.muted,
            ),
          ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brass,
          foregroundColor: AppColors.ink,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cream,
          side: const BorderSide(color: AppColors.line),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),

      iconTheme: const IconThemeData(color: AppColors.cream),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.panel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: AppColors.brass),
        ),
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.mutedDark,
        ),
      ),
    );
  }
}
