import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle display = GoogleFonts.baloo2(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle heading1 = GoogleFonts.baloo2(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.baloo2(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = GoogleFonts.nunitoSans(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyLarge = GoogleFonts.nunitoSans(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static TextStyle button = GoogleFonts.nunitoSans(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static TextStyle caption = GoogleFonts.nunitoSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle smallLabel = GoogleFonts.nunitoSans(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondary,
  );
}
