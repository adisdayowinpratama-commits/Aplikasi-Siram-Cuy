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
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.bgLight,
      primaryColor: AppColors.primaryGreen,
      textTheme: GoogleFonts.poppinsTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        primary: AppColors.primaryGreen,
      ),
    );
  }
}