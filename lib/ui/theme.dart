import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color appBackground = Color(0xFFFFF7FB);
  static const Color secondaryBackground = Color(0xFFF6FAFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  static const Color pastelPink = Color(0xFFF8BBD0);
  static const Color pastelLavender = Color(0xFFDCC6FF);
  static const Color pastelPeach = Color(0xFFFFD6C0);
  static const Color pastelBlue = Color(0xFFBFE6FF);
  static const Color pastelMint = Color(0xFFCFF7E6);

  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textMuted = Color(0xFF9A9A9A);

  static const Color border = Color(0xFFF0E6EF);
  static const Color divider = Color(0xFFF3EDF2);

  static const Color success = Color(0xFF8DE0C2);
  static const Color disabled = Color(0xFFD9D9D9);
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.appBackground,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.pastelPink,
      secondary: AppColors.pastelLavender,
      surface: AppColors.cardBackground,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).copyWith(
      titleLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.textMuted,
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppColors.cardBackground,
      elevation: 1.5,
      shadowColor: Color(0x22000000),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
    ),
    dividerColor: AppColors.divider,
  );
}
