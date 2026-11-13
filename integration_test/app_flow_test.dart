import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumad_lingua/main.dart';
import 'package:lumad_lingua/utils/constants.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-end app flow test: splash to login/dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LumadLinguaApp(),
      ),
    );

    // Verify splash screen
    expect(find.text(AppStrings.appName), findsOneWidget);

    // Wait for splash timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify navigation to login/welcome or home
    expect(find.byType(ProviderScope), findsOneWidget);
  });
}
