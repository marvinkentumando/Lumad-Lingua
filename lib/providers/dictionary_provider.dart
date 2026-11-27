import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vocabulary_model.dart';
import '../repositories/dictionary_repository.dart';
import '../repositories/firestore_dictionary_repository.dart';

final dictionaryRepositoryProvider = Provider<DictionaryRepository>((ref) {
  return FirestoreDictionaryRepository();
});

class DictionaryFilterState {
  final String searchQuery;
  final String selectedCategory; // 'All', 'Saved', or PartOfSpeech

  const DictionaryFilterState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  DictionaryFilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
  }) {
    return DictionaryFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class DictionaryFilterNotifier extends Notifier<DictionaryFilterState> {
  @override
  DictionaryFilterState build() => const DictionaryFilterState();

  void updateQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final dictionaryFilterProvider = NotifierProvider<DictionaryFilterNotifier, DictionaryFilterState>(() {
  return DictionaryFilterNotifier();
});

// Backward compatibility providers
final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(dictionaryFilterProvider).searchQuery;
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => ref.read(searchQueryProvider);

  void updateQuery(String newQuery) {
    ref.read(dictionaryFilterProvider.notifier).updateQuery(newQuery);
  }
}

class DictionaryPaginationState {
  final List<VocabularyModel> words;
  final bool isLoadingMore;
  final bool hasMore;
  final int offset;

  const DictionaryPaginationState({
    this.words = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.offset = 0,
  });

  DictionaryPaginationState copyWith({
    List<VocabularyModel>? words,
    bool? isLoadingMore,
    bool? hasMore,
    int? offset,
  }) {
    return DictionaryPaginationState(
      words: words ?? this.words,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
    );
  }
}

class DictionaryPaginationNotifier extends AsyncNotifier<DictionaryPaginationState> {
  static const int pageSize = 50;

  @override
  Future<DictionaryPaginationState> build() async {
    ref.watch(dictionaryFilterProvider);
    return _fetchPage(reset: true);
  }

  Future<DictionaryPaginationState> _fetchPage({bool reset = false}) async {
    final repo = ref.watch(dictionaryRepositoryProvider);
    final filter = ref.watch(dictionaryFilterProvider);

    final current = reset ? const DictionaryPaginationState() : (state.value ?? const DictionaryPaginationState());
    final offset = reset ? 0 : current.offset;

    if (filter.selectedCategory == 'Saved') {
      return const DictionaryPaginationState(words: [], hasMore: false, offset: 0);
    }

    final newWords = await repo.getVocabularyPaged(
      limit: pageSize,
      offset: offset,
      searchQuery: filter.searchQuery,
      partOfSpeech: filter.selectedCategory,
    );

    final updatedWords = reset ? newWords : [...current.words, ...newWords];
    final hasMore = newWords.length >= pageSize;

    return DictionaryPaginationState(
      words: updatedWords,
      isLoadingMore: false,
      hasMore: hasMore,
      offset: offset + newWords.length,
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || (state.value?.isLoadingMore ?? false) || !(state.value?.hasMore ?? true)) return;

    state = AsyncData((state.value ?? const DictionaryPaginationState()).copyWith(isLoadingMore: true));

    try {
      final nextState = await _fetchPage(reset: false);
      state = AsyncData(nextState);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchPage(reset: true));
  }
}

final dictionaryPaginationProvider = AsyncNotifierProvider<DictionaryPaginationNotifier, DictionaryPaginationState>(() {
  return DictionaryPaginationNotifier();
});

final dictionaryListProvider = FutureProvider<List<VocabularyModel>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.getVocabulary();
});

final dictionarySearchResultsProvider = FutureProvider<List<VocabularyModel>>((ref) async {
  final pagedState = ref.watch(dictionaryPaginationProvider);
  return pagedState.value?.words ?? [];
});

final partsOfSpeechProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(dictionaryRepositoryProvider);
  return repo.getAllPartsOfSpeech();
});

final wordOfTheDayProvider = FutureProvider<VocabularyModel?>((ref) async {
  final allWords = await ref.watch(dictionaryListProvider.future);
  if (allWords.isEmpty) return null;

  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
  final index = (now.year * 365 + dayOfYear).abs() % allWords.length;
  return allWords[index];
});
