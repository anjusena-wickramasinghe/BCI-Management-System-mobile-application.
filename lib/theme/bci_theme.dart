import 'package:flutter/material.dart';

/// BCI Campus brand colours used across the Management System.
class BciColors {
  BciColors._();

  /// Deep institutional navy (primary brand).
  static const Color navy = Color(0xFF173B63);

  /// Slightly lighter navy for surfaces and selected states.
  static const Color navyMid = Color(0xFF24507F);

  /// Soft blue used for containers and backgrounds.
  static const Color sky = Color(0xFFD6E4F5);

  /// Accent teal for secondary actions / enrolment.
  static const Color teal = Color(0xFF1B6B6B);

  /// Soft teal container.
  static const Color tealSoft = Color(0xFFD5EEEE);

  /// Warm gold accent for courses.
  static const Color gold = Color(0xFFB8841C);

  /// Soft gold container.
  static const Color goldSoft = Color(0xFFF5E8C8);

  /// Page background.
  static const Color canvas = Color(0xFFF3F6FA);

  /// Card / surface white.
  static const Color surface = Color(0xFFFFFFFF);
}

class BciTheme {
  BciTheme._();

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: BciColors.navy,
      primary: BciColors.navy,
      secondary: BciColors.teal,
      tertiary: BciColors.gold,
      surface: BciColors.surface,
      brightness: Brightness.light,
    ).copyWith(
      primaryContainer: BciColors.sky,
      onPrimaryContainer: BciColors.navy,
      secondaryContainer: BciColors.tealSoft,
      onSecondaryContainer: BciColors.teal,
      tertiaryContainer: BciColors.goldSoft,
      onTertiaryContainer: BciColors.gold,
      surfaceContainerHighest: BciColors.sky,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BciColors.canvas,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: BciColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      cardTheme: CardThemeData(
        color: BciColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: BciColors.navy.withValues(alpha: 0.08)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BciColors.surface,
        indicatorColor: BciColors.sky,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            final bool selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? BciColors.navy : BciColors.navyMid,
            );
          },
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) {
            final bool selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? BciColors.navy : BciColors.navyMid,
            );
          },
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: BciColors.surface,
        indicatorColor: BciColors.sky,
        selectedIconTheme: IconThemeData(color: BciColors.navy),
        unselectedIconTheme: IconThemeData(color: BciColors.navyMid),
        selectedLabelTextStyle: TextStyle(
          color: BciColors.navy,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(color: BciColors.navyMid),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BciColors.navy,
        foregroundColor: Colors.white,
        extendedPadding: EdgeInsets.symmetric(horizontal: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: BciColors.navy,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BciColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BciColors.navy, width: 1.6),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: BciColors.navy.withValues(alpha: 0.12),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: BciColors.navy,
      ),
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
