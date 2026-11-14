import 'package:flutter/material.dart';

class AppColors {
  // Canvas & Surfaces (Cream Theme - Web Admin Console aligned)
  static const creamBg     = Color(0xFFFEF8ED); // Canvas Background
  static const creamSurface = Color(0xFFFFFDF8); // Surface / Cards
  static const creamTint   = Color(0xFFFAF1DF); // Subtle Tint
  static const creamBorder = Color(0xFFE0CFA8); // Border / Shadow Lip
  static const creamShadow = Color(0xFFB8A070); // Elevation shadow tone

  // Text
  static const creamText   = Color(0xFF1A0E05); // Primary Text
  static const creamText2  = Color(0xFF7A5C3A); // Secondary Text
  static const creamText3  = Color(0xFFA8906E); // Muted Text

  // Primary Forest Green
  static const forest900 = Color(0xFF030A04);
  static const forest800 = Color(0xFF061209);
  static const forest700 = Color(0xFF0D1E0D); // Dark Header / Nav & Dark Lip
  static const forest600 = Color(0xFF14241A);
  static const forest500 = Color(0xFF1E3A22); // Primary Forest Green
  static const forest400 = Color(0xFF2A5230); // Hover / Pressed
  static const forest300 = Color(0xFF3D7045);
  static const forest200 = Color(0xFF65A870);
  static const forest100 = Color(0xFFA8D4AE);
  static const forest50  = Color(0xFFE8F4EA); // Soft Highlight

  // Gamification Gold
  static const gold900 = Color(0xFF4A2E00);
  static const gold800 = Color(0xFF7A4F00); // Gold Text
  static const gold700 = Color(0xFFB88500); // Gold Lip
  static const gold600 = Color(0xFFD4A000);
  static const gold500 = Color(0xFFFFC200); // Gamification Gold
  static const gold400 = Color(0xFFFFD03A); // Light Gold
  static const gold300 = Color(0xFFFFE080); // Gold Border
  static const gold200 = Color(0xFFFFF0B3);
  static const gold100 = Color(0xFFFFF8DE); // Soft Gold
  static const gold50  = Color(0xFFFFFDF5);

  // Semantic
  static const semanticGreen   = Color(0xFF3DAF5C); // Success
  static const successDark     = Color(0xFF227B3B); // Success Dark
  static const semanticRed     = Color(0xFFF04848); // Error
  static const errorDark       = Color(0xFFC42B2B); // Error Dark
  static const semanticWarning = Color(0xFFFF9800); // Warning
  static const terracotta      = Color(0xFFC84E1A); // Terracotta
  static const semanticBlue    = Color(0xFF3B91E0); // Info
  static const forestDarkCard  = Color(0xFF0F1E11); // Dark mode card surface

  // Backward Compatibility & Semantic Aliases
  static const primary = forest500;
  static const secondary = forest300;
  static const gold = gold500;
  static const background = creamBg;
  static const blue = semanticBlue;
  static const textPrimary = creamText;
  static const textSecondary = creamText2;
  static const surface = creamSurface;
  static const surfaceGreen = forest50;
  static const progressTrack = forest100;
  static const border = creamBorder;
  static const success = semanticGreen;
  static const error = semanticRed;
  static const warning = semanticWarning;
  static const disabled = creamText3;

  static const forestGreen = forest500;
  static const brightGreen = forest200;
  static const warmYellow = gold500;
  static const creamWhite = creamBg;
  static const darkCharcoal = creamText;
  static const softGray = forest50;
  static const coralRed = semanticRed;
  static const lightGreenBackground = forest50;
  static const lockedGray = forest100;
  static const borderGray = creamBorder;

  // Dynamic Theme-Aware Helpers for Dark/Light Mode
  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : creamText;
  }

  static Color subtitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white70 : creamText2;
  }

  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? forestDarkCard : creamSurface;
  }
}
