import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color appBackground = Color(0xFFFFF7FB);
  static const Color secondaryBackground = Color(0xFFF6FAFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  static const Color pastelPink = Color(0xFFE56B98);
  static const Color pastelLavender = Color(0xFF9D7AE0);
  static const Color pastelPeach = Color(0xFFFA8155);
  static const Color pastelBlue = Color(0xFF5AB1F9);
  static const Color pastelMint = Color(0xFF38CC98);

  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textMuted = Color(0xFF888888);

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
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: AppColors.textSecondary.withValues(alpha: 0.8),
        fontWeight: FontWeight.w500,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
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
