import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Display & Headings (GoogleFonts.fredoka)
  static TextStyle display = GoogleFonts.fredoka(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: AppColors.creamText,
  );

  static TextStyle displayBold = GoogleFonts.fredoka(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.creamText,
  );

  static TextStyle h1ExtraBold = GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.creamText,
  );

  static TextStyle h1 = GoogleFonts.fredoka(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.creamText,
  );

  static TextStyle h2ExtraBold = GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.creamText,
  );

  static TextStyle h2 = GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.creamText,
  );

  static TextStyle h3 = GoogleFonts.fredoka(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.creamText,
  );

  // Body & Labels (GoogleFonts.nunito)
  static TextStyle bodyLarge = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.creamText,
  );

  static TextStyle body = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.creamText,
  );

  static TextStyle label = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.creamText2,
  );

  static TextStyle labelBold = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.creamText,
  );

  static TextStyle caption = GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.creamText2,
  );

  // Code / Monospace (GoogleFonts.dmMono)
  static TextStyle mono = GoogleFonts.dmMono(
    fontSize: 13,
    color: AppColors.creamText,
  );

  // Backward Compatibility Aliases
  static TextStyle get heading1 => h1;
  static TextStyle get heading2 => h2;
  static TextStyle get heading3 => h3;
  static TextStyle get button => GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
  static TextStyle get smallLabel => label;
}
