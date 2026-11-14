import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF214D3A);      // Dark Forest Green
  static const Color secondary = Color(0xFF3D8060);    // Fern Green
  static const Color gold = Color(0xFFF3BE52);         // Harvest Gold
  static const Color background = Color(0xFFFAF7EF);   // Warm Ivory
  static const Color blue = Color(0xFF355F80);         // River Blue

  // Text Colors
  static const Color textPrimary = Color(0xFF272A22);  // Charcoal
  static const Color textSecondary = Color(0xFF62685F);// Muted Gray

  // Surface & Neutral Colors
  static const Color surface = Color(0xFFFFFFFF);      // Pure White
  static const Color surfaceGreen = Color(0xFFE4EEE5); // Pale Green
  static const Color progressTrack = Color(0xFFDDE8DE); // Light Sage
  static const Color border = Color(0xFFE2E6DE);       // Soft Border

  // Functional Colors
  static const Color success = Color(0xFF276749);
  static const Color error = Color(0xFFB43F45);
  static const Color warning = Color(0xFFA56A18);
  static const Color disabled = Color(0xFFB9C2B8);

  // Aliases for backwards compatibility
  static const Color forestGreen = primary;
  static const Color brightGreen = secondary;
  static const Color warmYellow = gold;
  static const Color creamWhite = background;
  static const Color darkCharcoal = textPrimary;
  static const Color softGray = surfaceGreen;
  static const Color coralRed = error;
  static const Color lightGreenBackground = surfaceGreen;
  static const Color lockedGray = disabled;
  static const Color borderGray = border;

  // Dynamic Theme-Aware Helpers for Dark/Light Mode
  static Color textColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : textPrimary;
  }

  static Color subtitleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? Colors.white70 : textSecondary;
  }

  static Color cardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E2923) : Colors.white;
  }
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double buttonHeight = 56.0;
  static const double iconSize = 24.0;
  static const double minTouchTarget = 48.0;

  static const double borderRadiusSm = 12.0;
  static const double borderRadiusMd = 18.0;
  static const double borderRadiusLg = 20.0;
  static const double borderRadiusXl = 24.0;
}

class AppRadius {
  static const double sm = 12.0;
  static const double md = 18.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
}

class AppStrings {
  static const String appName = 'Lumad Lingua';
  static const String tagline = 'Learn the language. Keep the stories alive.';
}
