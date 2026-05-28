import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFB8943A);
  static const Color primaryDark = Color(0xFF1A2A3A);
  static const Color primaryDarkLight = Color(0xFF2C3E50);
  static const Color accentGold = Color(0xFFD4A843);
  static const Color textLight = Color(0xFFF5F5F5);
  static const Color textMuted = Color(0xFF7F8C8D);
  static const Color textDark = Color(0xFF1A2A3A);
  static const Color surfaceDark = Color(0xFFECF0F1);
  static const Color cardDark = Color(0xFFFFFFFF);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: surfaceDark,
      primaryColor: primaryGold,
      colorScheme: const ColorScheme.light(
        primary: primaryGold,
        secondary: accentGold,
        surface: cardDark,
      ),
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: textDark,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: textDark,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.cinzel(
          color: primaryGold,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.cinzel(
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textDark,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textMuted,
          fontSize: 14,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cinzel(
          color: primaryGold,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: primaryGold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: primaryGold,
        unselectedItemColor: textMuted,
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: primaryGold, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: primaryGold,
        thickness: 0.5,
      ),
    );
  }
}
