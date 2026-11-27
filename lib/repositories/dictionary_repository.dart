import '../models/vocabulary_model.dart';
import '../data/mock_vocabulary.dart';

abstract class DictionaryRepository {
  Future<List<VocabularyModel>> getVocabularyPaged({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    String? partOfSpeech,
    bool forceRefresh = false,
  });

  Future<int> getVocabularyCount({String? searchQuery, String? partOfSpeech});

  Future<List<String>> getAllPartsOfSpeech();

  Future<List<VocabularyModel>> searchVocabulary(String query);
  Future<List<VocabularyModel>> getVocabulary({bool forceRefresh = false});
  Future<VocabularyModel?> getWordById(String id);
}

class MockDictionaryRepository implements DictionaryRepository {
  @override
  Future<List<VocabularyModel>> getVocabularyPaged({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    String? partOfSpeech,
    bool forceRefresh = false,
  }) async {
    final all = await searchVocabulary(searchQuery ?? '');
    var filtered = all;
    if (partOfSpeech != null && partOfSpeech != 'All') {
      filtered = filtered.where((w) => w.partOfSpeech.toLowerCase() == partOfSpeech.toLowerCase()).toList();
    }
    final start = offset.clamp(0, filtered.length);
    final end = (offset + limit).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  @override
  Future<int> getVocabularyCount({String? searchQuery, String? partOfSpeech}) async {
    final all = await searchVocabulary(searchQuery ?? '');
    var filtered = all;
    if (partOfSpeech != null && partOfSpeech != 'All') {
      filtered = filtered.where((w) => w.partOfSpeech.toLowerCase() == partOfSpeech.toLowerCase()).toList();
    }
    return filtered.length;
  }

  @override
  Future<List<String>> getAllPartsOfSpeech() async {
    return mockVocabularyList.map((w) => w.partOfSpeech).toSet().toList()..sort();
  }

  @override
  Future<List<VocabularyModel>> searchVocabulary(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.trim().isEmpty) {
      return mockVocabularyList;
    }
    final q = query.toLowerCase();
    return mockVocabularyList.where((word) {
      return word.headword.toLowerCase().contains(q) ||
          word.translation.toLowerCase().contains(q) ||
          word.partOfSpeech.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Future<List<VocabularyModel>> getVocabulary({bool forceRefresh = false}) async {
    return searchVocabulary('');
  }

  @override
  Future<VocabularyModel?> getWordById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return mockVocabularyList.firstWhere((word) => word.id == id);
    } catch (_) {
      return null;
    }
  }
}
