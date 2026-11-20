import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vocabulary_model.dart';
import 'auth_provider.dart';

class BookmarksNotifier extends Notifier<Map<String, VocabularyModel>> {
  @override
  Map<String, VocabularyModel> build() {
    _loadFromPrefs();
    return {};
  }

  Future<void> _loadFromPrefs() async {
    try {
      final user = ref.read(authStateProvider).value;
      final userId = user?.id ?? 'guest';
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString('lumad_saved_bookmarks_$userId');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = jsonDecode(jsonStr);
        final Map<String, VocabularyModel> loaded = {};
        for (final item in list) {
          final vocab = VocabularyModel.fromJson(item as Map<String, dynamic>);
          final key = vocab.id.isNotEmpty ? vocab.id : vocab.headword;
          loaded[key] = vocab;
        }
        state = loaded;
      }
    } catch (_) {}
  }

  Future<bool> toggleBookmark(VocabularyModel vocab) async {
    final key = vocab.id.isNotEmpty ? vocab.id : vocab.headword;
    final updated = Map<String, VocabularyModel>.from(state);
    final bool willBeSaved = !updated.containsKey(key);

    if (willBeSaved) {
      updated[key] = vocab;
    } else {
      updated.remove(key);
    }

    state = updated;
    await _saveToPrefs(updated);
    return willBeSaved;
  }

  bool isBookmarked(VocabularyModel vocab) {
    final key = vocab.id.isNotEmpty ? vocab.id : vocab.headword;
    return state.containsKey(key);
  }

  Future<void> _saveToPrefs(Map<String, VocabularyModel> map) async {
    try {
      final user = ref.read(authStateProvider).value;
      final userId = user?.id ?? 'guest';
      final prefs = await SharedPreferences.getInstance();
      final listJson = map.values.map((v) => v.toJson()).toList();
      await prefs.setString('lumad_saved_bookmarks_$userId', jsonEncode(listJson));
    } catch (_) {}
  }
}

final bookmarksProvider = NotifierProvider<BookmarksNotifier, Map<String, VocabularyModel>>(() {
  return BookmarksNotifier();
});
