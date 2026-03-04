import 'package:flutter/material.dart';

/// OSRS-inspired theme — dark medieval browns, gold accents, parchment tones.
class AppTheme {
  AppTheme._();

  // ── OSRS Palette ──────────────────────────────────────────────────────
  static const osrsGold = Color(0xFFD4A017); // Classic OSRS gold text
  static const osrsOrange = Color(0xFFFF981F); // Orange hover / highlight
  static const osrsDarkBrown = Color(0xFF2B1D0E); // Deepest background
  static const osrsBrown = Color(0xFF3B2A14); // Surface / panels
  static const osrsMedBrown = Color(0xFF4A3621); // Cards / elevated
  static const osrsLightBrown = Color(0xFF5C4529); // Borders / hover
  static const osrsParchment = Color(0xFFD2C3A3); // Light text
  static const osrsCream = Color(0xFFF5E6C8); // Bright text
  static const osrsRed = Color(0xFFB33831); // Error / danger
  static const osrsGreen = Color(0xFF3B8132); // Success / primary action
  static const osrsDarkGreen = Color(0xFF2D5F27); // Button bg

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: osrsGreen,
      secondary: osrsGold,
      surface: osrsDarkBrown,
      error: osrsRed,
      onPrimary: osrsCream,
      onSecondary: osrsDarkBrown,
      onSurface: osrsParchment,
      onError: Colors.white,
      tertiary: osrsOrange,
    ),
    scaffoldBackgroundColor: osrsDarkBrown,
    cardTheme: CardThemeData(
      color: osrsBrown,
      elevation: 2,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: osrsLightBrown.withValues(alpha: 0.35)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: osrsBrown,
      elevation: 0,
      centerTitle: false,
      foregroundColor: osrsGold,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: osrsDarkBrown.withValues(alpha: 0.8),
      labelStyle: TextStyle(color: osrsParchment.withValues(alpha: 0.7)),
      hintStyle: TextStyle(color: osrsParchment.withValues(alpha: 0.4)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: osrsLightBrown.withValues(alpha: 0.6)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: osrsLightBrown.withValues(alpha: 0.6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: osrsGold, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: osrsDarkGreen,
        foregroundColor: osrsCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: osrsGreen.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 1,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: osrsGold,
        side: const BorderSide(color: osrsGold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: osrsGold),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: osrsMedBrown,
      selectedColor: osrsDarkGreen,
      labelStyle: const TextStyle(color: osrsParchment),
      side: BorderSide(color: osrsLightBrown.withValues(alpha: 0.4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    dividerTheme: DividerThemeData(
      color: osrsLightBrown.withValues(alpha: 0.4),
      thickness: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: osrsBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: osrsLightBrown.withValues(alpha: 0.6)),
      ),
      titleTextStyle: const TextStyle(
        color: osrsGold,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: osrsMedBrown,
      contentTextStyle: const TextStyle(color: osrsCream),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: osrsGold.withValues(alpha: 0.6)),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: osrsBrown,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: osrsLightBrown.withValues(alpha: 0.6)),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: osrsGold,
      linearTrackColor: osrsMedBrown,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: osrsMedBrown,
        border: Border.all(color: osrsGold.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(color: osrsCream, fontSize: 12),
      waitDuration: const Duration(milliseconds: 400),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return osrsDarkGreen;
          return osrsMedBrown;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return osrsCream;
          return osrsParchment;
        }),
        side: WidgetStateProperty.all(
          const BorderSide(color: osrsLightBrown),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: osrsParchment,
      iconColor: osrsGold,
    ),
    iconTheme: const IconThemeData(color: osrsGold),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: osrsGold, fontWeight: FontWeight.w700),
      headlineMedium: TextStyle(color: osrsGold, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(color: osrsGold, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: osrsCream, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: osrsCream, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: osrsParchment),
      bodyLarge: TextStyle(color: osrsParchment),
      bodyMedium: TextStyle(color: osrsParchment),
      bodySmall: TextStyle(color: Color(0xFF9E8B72)),
      labelLarge: TextStyle(color: osrsCream, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: osrsParchment),
      labelSmall: TextStyle(color: Color(0xFF9E8B72)),
    ),
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: osrsBrown,
      selectedIconTheme: IconThemeData(color: osrsGold),
      unselectedIconTheme: IconThemeData(color: osrsParchment),
      selectedLabelTextStyle:
          TextStyle(color: osrsGold, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: osrsParchment),
    ),
  );
}
