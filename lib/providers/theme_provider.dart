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

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(() {
  return ThemeModeNotifier();
});

final customThemeAccentProvider = NotifierProvider<CustomThemeAccentNotifier, bool>(() {
  return CustomThemeAccentNotifier();
});
