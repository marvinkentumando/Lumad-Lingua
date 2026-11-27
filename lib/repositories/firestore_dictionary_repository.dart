import '../models/vocabulary_model.dart';
import '../services/firestore_service.dart';
import '../services/database_service.dart';
import 'dictionary_repository.dart';

class FirestoreDictionaryRepository implements DictionaryRepository {
  final FirestoreService _firestoreService;
  final DatabaseService _databaseService;

  FirestoreDictionaryRepository({
    FirestoreService? firestoreService,
    DatabaseService? databaseService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _databaseService = databaseService ?? DatabaseService();

  Future<void> _syncToLocalIfNeeded({bool forceRefresh = false}) async {
    try {
      final count = await _databaseService.getVocabularyCount();
      if (count == 0 || forceRefresh) {
        final remoteWords = await _firestoreService.getVocabulary(forceRefresh: forceRefresh);
        if (remoteWords.isNotEmpty) {
          await _databaseService.insertVocabularyBatch(remoteWords);
        }
      }
    } catch (_) {}
  }

  @override
  Future<List<VocabularyModel>> getVocabularyPaged({
    int limit = 50,
    int offset = 0,
    String? searchQuery,
    String? partOfSpeech,
    bool forceRefresh = false,
  }) async {
    await _syncToLocalIfNeeded(forceRefresh: forceRefresh);
    return await _databaseService.getVocabularyPaged(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
      partOfSpeech: partOfSpeech,
    );
  }

  @override
  Future<int> getVocabularyCount({String? searchQuery, String? partOfSpeech}) async {
    return await _databaseService.getVocabularyCount(
      searchQuery: searchQuery,
      partOfSpeech: partOfSpeech,
    );
  }

  @override
  Future<List<String>> getAllPartsOfSpeech() async {
    await _syncToLocalIfNeeded();
    return await _databaseService.getAllPartsOfSpeech();
  }

  @override
  Future<List<VocabularyModel>> searchVocabulary(String query) async {
    await _syncToLocalIfNeeded();
    return await _databaseService.getVocabularyPaged(limit: 100, offset: 0, searchQuery: query);
  }

  @override
  Future<List<VocabularyModel>> getVocabulary({bool forceRefresh = false}) async {
    await _syncToLocalIfNeeded(forceRefresh: forceRefresh);
    return await _databaseService.getVocabularyPaged(limit: 10000, offset: 0);
  }

  @override
  Future<VocabularyModel?> getWordById(String id) async {
    final local = await _databaseService.getWordById(id);
    if (local != null) return local;
    return await _firestoreService.getWordById(id);
  }
}
