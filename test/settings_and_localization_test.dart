import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumad_lingua/utils/app_localizations.dart';
import 'package:lumad_lingua/providers/theme_provider.dart';
import 'package:lumad_lingua/providers/localization_provider.dart';
import 'package:lumad_lingua/providers/connectivity_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RegionalStrings Localization Tests', () {
    test('English translations fall back correctly', () {
      expect(RegionalStrings.get('en', 'welcome'), 'Welcome Back!');
      expect(RegionalStrings.get('en', 'dictionary'), 'Mansaka Dictionary');
    });

    test('Cebuano translations resolve correctly', () {
      expect(RegionalStrings.get('ceb', 'welcome'), 'Maayong Pagbalik!');
      expect(RegionalStrings.get('ceb', 'dictionary'), 'Mansaka nga Diksyonaryo');
    });

    test('Tagalog translations resolve correctly', () {
      expect(RegionalStrings.get('tl', 'welcome'), 'Maligayang Pagbálik!');
      expect(RegionalStrings.get('tl', 'dictionary'), 'Diksyunaryong Mansaka');
    });

    test('Unknown keys fallback to key string', () {
      expect(RegionalStrings.get('en', 'non_existent_key_123'), 'non_existent_key_123');
    });
  });

  group('Settings & Theme Providers Tests', () {
    test('Sound effects and haptics providers default to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(soundEffectsProvider), true);
      expect(container.read(hapticFeedbackProvider), true);
      expect(container.read(offlineDictionaryProvider), true);
    });

    test('Toggling settings updates provider state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(soundEffectsProvider.notifier).toggle(false);
      expect(container.read(soundEffectsProvider), false);

      container.read(hapticFeedbackProvider.notifier).toggle(false);
      expect(container.read(hapticFeedbackProvider), false);

      container.read(offlineDictionaryProvider.notifier).toggle(false);
      expect(container.read(offlineDictionaryProvider), false);
    });

    test('Localization provider switches languages correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(localizationProvider), 'en');

      container.read(localizationProvider.notifier).setLanguage('ceb');
      expect(container.read(localizationProvider), 'ceb');

      container.read(localizationProvider.notifier).setLanguage('tl');
      expect(container.read(localizationProvider), 'tl');
    });

    test('isOfflineProvider defaults to false when connectivity stream is loading or online', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(isOfflineProvider), false);
    });
  });
}
