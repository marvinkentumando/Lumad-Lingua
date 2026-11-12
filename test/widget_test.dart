import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumad_lingua/main.dart';
import 'package:lumad_lingua/utils/constants.dart';

void main() {
  testWidgets('Lumad Lingua app smoke test - splash screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LumadLinguaApp(),
      ),
    );

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.tagline), findsOneWidget);

    // Advance fake async timer to complete splash screen timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
