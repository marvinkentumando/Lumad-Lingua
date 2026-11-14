import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary_model.dart';
import '../repositories/dictionary_repository.dart';
import '../repositories/firestore_dictionary_repository.dart';

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return FirestoreDictionaryRepository();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String newQuery) {
    state = newQuery;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

final dictionarySearchResultsProvider = FutureProvider<List<VocabularyModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.searchVocabulary(query);
});

final wordOfTheDayProvider = FutureProvider<VocabularyModel?>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  final allWords = await repo.searchVocabulary('');
  if (allWords.isEmpty) return null;

  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  final index = (now.year * 365 + dayOfYear) % allWords.length;
  return allWords[index];
});
