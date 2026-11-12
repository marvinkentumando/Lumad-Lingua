import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const primary = Color(0xFF214D3A);      // Dark Forest Green
  static const secondary = Color(0xFF3D8060);    // Fern Green
  static const gold = Color(0xFFF3BE52);         // Harvest Gold
  static const background = Color(0xFFFAF7EF);   // Warm Ivory
  static const blue = Color(0xFF355F80);         // River Blue

  // Text Colors
  static const textPrimary = Color(0xFF272A22);  // Charcoal
  static const textSecondary = Color(0xFF62685F);// Muted Gray

  // Surface & Neutral Colors
  static const surface = Color(0xFFFFFFFF);      // Pure White
  static const surfaceGreen = Color(0xFFE4EEE5); // Pale Green
  static const progressTrack = Color(0xFFDDE8DE); // Light Sage
  static const border = Color(0xFFE2E6DE);       // Soft Border

  // Functional Colors
  static const success = Color(0xFF276749);
  static const error = Color(0xFFB43F45);
  static const warning = Color(0xFFA56A18);
  static const disabled = Color(0xFFB9C2B8);

  // Backward Compatibility Aliases
  static const forestGreen = primary;
  static const brightGreen = secondary;
  static const warmYellow = gold;
  static const creamWhite = background;
  static const darkCharcoal = textPrimary;
  static const softGray = surfaceGreen;
  static const coralRed = error;
  static const lightGreenBackground = surfaceGreen;
  static const lockedGray = disabled;
  static const borderGray = border;
}
