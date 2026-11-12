import '../models/vocabulary_model.dart';
import '../services/firestore_service.dart';
import 'dictionary_repository.dart';

class FirestoreDictionaryRepository implements DictionaryRepository {
  final FirestoreService _firestoreService;

  FirestoreDictionaryRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<List<VocabularyModel>> searchVocabulary(String query) async {
    return await _firestoreService.searchVocabulary(query);
  }

  @override
  Future<VocabularyModel?> getWordById(String id) async {
    return await _firestoreService.getWordById(id);
  }
}
