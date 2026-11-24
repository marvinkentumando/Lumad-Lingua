import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CulturalThemeSkin {
  lumadForest, // Ancestral Green & Gold (Mindanao Higaonon/Manobo)
  tnalakWeave, // Crimson Red & Earth Brown (T'boli Dreamweaver)
  inabelMotif, // Indigo Blue & Bright Gold (Ilocano Inabel Weave)
}

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

class CustomThemeAccentNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setAccent(bool value) => state = value;
}

class ElderModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setElderMode(bool value) => state = value;
}

class BackgroundPatternNotifier extends Notifier<String> {
  @override
  String build() => 'woven_waves'; // 'woven_waves', 'tribal_geom', 'solid_forest', 'royal_crimson'

  void setPattern(String pattern) {
    state = pattern;
  }
}

class CulturalThemeNotifier extends Notifier<CulturalThemeSkin> {
  @override
  CulturalThemeSkin build() => CulturalThemeSkin.lumadForest;

  void setThemeSkin(CulturalThemeSkin skin) {
    state = skin;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

final customThemeAccentProvider = NotifierProvider<CustomThemeAccentNotifier, bool>(() {
  return CustomThemeAccentNotifier();
});

final elderModeProvider = NotifierProvider<ElderModeNotifier, bool>(() {
  return ElderModeNotifier();
});

final backgroundPatternProvider = NotifierProvider<BackgroundPatternNotifier, String>(() {
  return BackgroundPatternNotifier();
});

final culturalThemeProvider = NotifierProvider<CulturalThemeNotifier, CulturalThemeSkin>(() {
  return CulturalThemeNotifier();
});
