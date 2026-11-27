import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumad_lingua/screens/dictionary/dictionary_screen.dart';
import 'package:lumad_lingua/screens/profile/settings_screen.dart';

void main() {
  testWidgets('DictionaryScreen renders search bar and UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DictionaryScreen(),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('SettingsScreen renders sound and haptic toggles', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.byType(Switch), findsWidgets);
  });
}
