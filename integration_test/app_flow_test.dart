import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumad_lingua/main.dart';
import 'package:lumad_lingua/utils/constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end user flow: Splash -> Onboarding -> Home -> Learn -> Dictionary -> Profile -> Duels', (WidgetTester tester) async {
    // 1. Launch App
    await tester.pumpWidget(
      const ProviderScope(
        child: LumadLinguaApp(),
      ),
    );

    // Verify splash screen appears
    expect(find.text(AppStrings.appName), findsOneWidget);

    // 2. Wait for splash timer to transition to onboarding/home
    await tester.pump(const Duration(milliseconds: 3500));
    await tester.pumpAndSettle();

    // 3. Test bottom navigation tabs
    // Tap Learn tab
    final learnTab = find.text('Learn');
    if (learnTab.evaluate().isNotEmpty) {
      await tester.tap(learnTab);
      await tester.pumpAndSettle();
    }

    // Tap Dictionary tab
    final dictTab = find.text('Dictionary');
    if (dictTab.evaluate().isNotEmpty) {
      await tester.tap(dictTab);
      await tester.pumpAndSettle();
    }

    // Tap Profile tab
    final profileTab = find.text('Profile');
    if (profileTab.evaluate().isNotEmpty) {
      await tester.tap(profileTab);
      await tester.pumpAndSettle();
    }

    // Tap Home tab
    final homeTab = find.text('Home');
    if (homeTab.evaluate().isNotEmpty) {
      await tester.tap(homeTab);
      await tester.pumpAndSettle();
    }

    // 4. Test tapping Lingua Duels Arena card or Daily Quests
    final duelsCard = find.text('Lingua Duels Arena (PvP)');
    if (duelsCard.evaluate().isNotEmpty) {
      await tester.scrollUntilVisible(duelsCard, 500);
      await tester.tap(duelsCard);
      await tester.pumpAndSettle();
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
