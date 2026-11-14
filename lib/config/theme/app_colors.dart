import 'package:flutter/material.dart';

class AppColors {
  // Primary Scale (Forest Greens)
  static const forest900 = Color(0xFF030A04);
  static const forest800 = Color(0xFF061209);
  static const forest700 = Color(0xFF0D1E0D);
  static const forest600 = Color(0xFF14241A);
  static const forest500 = Color(0xFF1E3A22); // Primary Light Theme Button & Element color
  static const forest400 = Color(0xFF2A5230);
  static const forest300 = Color(0xFF3D7045);
  static const forest200 = Color(0xFF65A870);
  static const forest100 = Color(0xFFA8D4AE);
  static const forest50  = Color(0xFFE8F4EA);

  // Accent Scale (Ancestral Gold)
  static const gold900 = Color(0xFF4A2E00);
  static const gold800 = Color(0xFF7A4F00);
  static const gold700 = Color(0xFFB88500);
  static const gold600 = Color(0xFFD4A000);
  static const gold500 = Color(0xFFFFC200); // Primary Accent CTA & Dark Theme Primary Color
  static const gold400 = Color(0xFFFFD03A);
  static const gold300 = Color(0xFFFFE080);
  static const gold200 = Color(0xFFFFF0B3);
  static const gold100 = Color(0xFFFFF8DE);
  static const gold50  = Color(0xFFFFFDF5);

  // Neutrals & Parchment (Cream Theme)
  static const creamBg     = Color(0xFFFEF8ED); // Warm parchment background
  static const creamBorder = Color(0xFFE0CFA8); // Soft border separator
  static const creamShadow = Color(0xFFB8A070); // Elevation shadow tone
  static const creamText   = Color(0xFF1A0E05); // High-contrast dark brown text
  static const creamText2  = Color(0xFF7A5C3A); // Secondary descriptive brown text
  static const creamText3  = Color(0xFFA8906E); // Subtle hint / muted text

  // Semantic & Special Colors
  static const semanticGreen   = Color(0xFF3DAF5C); // Success, completion, passing grade
  static const semanticRed     = Color(0xFFF04848); // Error, danger, deletion, alerts
  static const semanticBlue    = Color(0xFF3B91E0); // Information, selection, active states
  static const semanticWarning = Color(0xFFFF9800);  // Warnings, cautions (updated format)
  static const terracotta      = Color(0xFFC84E1A); // Earthy highlight tone
  static const forestDarkCard  = Color(0xFF0F1E11); // Dark mode card surface

  // Backward Compatibility & Semantic Aliases
  static const primary = forest500;
  static const secondary = forest300;
  static const gold = gold500;
  static const background = creamBg;
  static const blue = semanticBlue;
  static const textPrimary = creamText;
  static const textSecondary = creamText2;
  static const surface = Colors.white;
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
    return Theme.of(context).brightness == Brightness.dark ? forestDarkCard : Colors.white;
  }
}
