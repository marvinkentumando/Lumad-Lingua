import '../models/vocabulary_model.dart';
import '../data/mock_vocabulary.dart';

abstract class DictionaryRepository {
  Future<List<VocabularyModel>> searchVocabulary(String query);
  Future<VocabularyModel?> getWordById(String id);
}

class MockDictionaryRepository implements DictionaryRepository {
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
          word.category.toLowerCase().contains(q);
    }).toList();
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
