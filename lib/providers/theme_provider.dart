import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
