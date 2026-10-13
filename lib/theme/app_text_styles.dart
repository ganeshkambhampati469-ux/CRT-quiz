import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings - Poppins
  static TextStyle h1({Color color = AppColors.textPrimary}) =>
      GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle h2({Color color = AppColors.textPrimary}) =>
      GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle h3({Color color = AppColors.textPrimary}) =>
      GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  static TextStyle h4({Color color = AppColors.textPrimary}) =>
      GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // Body Text - Inter
  static TextStyle bodyLarge({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMedium({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySmall({Color color = AppColors.textMuted}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  // Subtitles & Labels
  static TextStyle subtitle({Color color = AppColors.textMuted}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle label({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  // Buttons & Badges
  static TextStyle button({Color color = Colors.white}) =>
      GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: color,
      );

  static TextStyle caption({Color color = AppColors.textMuted}) =>
      GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: color,
      );
}
