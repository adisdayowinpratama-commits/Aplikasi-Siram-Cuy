import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryGreen = Color(0xFF0F8A4A);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color darkBlue = Color(0xFF101B37);
  static const Color greyText = Color(0xFF757575);
  static const Color bgLight = Color(0xFFF7F9FA);
  static const Color surfaceWhite = Colors.white;
  static const Color borderGrey = Color(0xFFEEEEEE);

  static const Color bgDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color borderDark = Color(0xFF2C2C2C);
  static const Color mutedTextDark = Color(0xFFB0B6C0);

  static const Color orangeBg = Color(0xFFFFF3E0);
  static const Color blueBg = Color(0xFFE3F2FD);
  static const Color greenBg = Color(0xFFE8F5E9);
}

class AppTheme {
  // TEMA TERANG
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primaryGreen,
      textTheme: GoogleFonts.poppinsTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
      ),
    );
  }

  // TEMA GELAP
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212), // Warna latar gelap
      primaryColor: AppColors.primaryGreen,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
        surface: const Color(0xFF1E1E1E), // Warna card gelap
      ),
    );
  }
}

extension BuildContextThemeExtension on BuildContext {
  Color get bg => Theme.of(this).scaffoldBackgroundColor;
  Color get surface => Theme.of(this).colorScheme.surface;
  Color get textMain =>
      Theme.of(this).textTheme.bodyLarge?.color ??
      Theme.of(this).colorScheme.onBackground;
  Color get textMuted =>
      Theme.of(this).textTheme.bodySmall?.color ??
      Theme.of(this).colorScheme.onSurfaceVariant;
  Color get border => Theme.of(this).dividerColor;

  Color get orangeBg => AppColors.orangeBg;
  Color get blueBg => AppColors.blueBg;
  Color get greenBg => AppColors.greenBg;
}
