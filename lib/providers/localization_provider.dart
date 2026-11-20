import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefLangCode = 'lumad_pref_lang_code';

class LocalizationNotifier extends Notifier<String> {
  @override
  String build() {
    _loadLang();
    return 'en'; // Default English
  }

  Future<void> _loadLang() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefLangCode);
      if (code != null && (code == 'en' || code == 'ceb' || code == 'tl')) {
        state = code;
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String langCode) async {
    if (langCode == 'en' || langCode == 'ceb' || langCode == 'tl') {
      state = langCode;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefLangCode, langCode);
      } catch (_) {}
    }
  }
}

final localizationProvider = NotifierProvider<LocalizationNotifier, String>(() {
  return LocalizationNotifier();
});
