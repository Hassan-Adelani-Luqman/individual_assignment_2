import 'package:flutter/material.dart';

class AppTheme {
  // Dark blue theme colors matching the UI design
  static const Color primaryDark = Color(0xFF0F1B2E);
  static const Color secondaryDark = Color(0xFF1A2942);
  static const Color accentGold = Color(0xFFEAA24A);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB0B0B0);
  static const Color cardBackground = Color(0xFF1E2B3F);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      primaryColor: accentGold,
      
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        secondary: accentGold,
        surface: secondaryDark,
        onPrimary: primaryDark,
        onSecondary: primaryDark,
        onSurface: textWhite,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textWhite),
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarTheme(
        backgroundColor: secondaryDark,
        selectedItemColor: accentGold,
        unselectedItemColor: textGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGold, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        labelStyle: const TextStyle(color: textGray),
        hintStyle: const TextStyle(color: textGray),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentGold,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      chipTheme: ChipThemeData(
        backgroundColor: secondaryDark,
        selectedColor: accentGold,
        labelStyle: const TextStyle(color: textWhite),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textWhite,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textGray,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textGray,
          fontSize: 12,
        ),
      ),
    );
  }
}
