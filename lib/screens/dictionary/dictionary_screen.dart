import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../models/vocabulary_model.dart';
import '../../providers/dictionary_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_filter_chip.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/lumad_background.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  late FocusNode _searchFocusNode;
  bool _isSearchFocused = false;
  List<String> _recentSearches = ['Madyaw', 'Salamat', 'Good morning', 'Water', 'Family'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
    _searchFocusNode = FocusNode()..addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
    });
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(dictionaryPaginationProvider.notifier).loadMore();
    }
  }

  Future<void> _loadRecentSearches() async {
    try {
      final user = ref.read(authStateProvider).value;
      final userId = user?.id ?? 'guest';
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('lumad_recent_searches_$userId');
      if (saved != null && saved.isNotEmpty) {
        if (mounted) {
          setState(() {
            _recentSearches = saved;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveSearchTerm(String term) async {
    final clean = term.trim();
    if (clean.length < 2) return;

    final updated = List<String>.from(_recentSearches);
    updated.remove(clean);
    updated.insert(0, clean);
    if (updated.length > 6) {
      updated.removeLast();
    }

    if (mounted) {
      setState(() => _recentSearches = updated);
    }

    try {
      final user = ref.read(authStateProvider).value;
      final userId = user?.id ?? 'guest';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('lumad_recent_searches_$userId', updated);
    } catch (_) {}
  }

  void _applySearchChip(String term) {
    _searchController.text = term;
    ref.read(dictionaryFilterProvider.notifier).updateQuery(term);
    _saveSearchTerm(term);
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(dictionaryFilterProvider);
    final paginationAsync = ref.watch(dictionaryPaginationProvider);
    final partsOfSpeechAsync = ref.watch(partsOfSpeechProvider);
    final savedBookmarks = ref.watch(bookmarksProvider);
    final langCode = ref.watch(localizationProvider);

    final rawParts = partsOfSpeechAsync.value ?? ['Noun', 'Verb', 'Phrase', 'Prefix', 'Suffix', 'Locative'];
    final kidFriendlyParts = rawParts.where((p) => !['Prefix', 'Suffix', 'Locative'].contains(p)).toList();
    final categories = ['All', 'Saved', ...kidFriendlyParts];
    final selectedCategory = filterState.selectedCategory;

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
                ScreenHeader(
                  title: RegionalStrings.get(langCode, 'dictionary'),
                  centerTitle: true,
                ),
                const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (val) {
                  ref.read(dictionaryFilterProvider.notifier).updateQuery(val);
                },
                onSubmitted: (val) {
                  _saveSearchTerm(val);
                  _searchFocusNode.unfocus();
                },
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textColor(context)),
                decoration: InputDecoration(
                  hintText: RegionalStrings.get(langCode, 'searchHint'),
                  hintStyle: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.forest500),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.subtitleColor(context)),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(dictionaryFilterProvider.notifier).updateQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.cardColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.forest700 : AppColors.creamBorder, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.forest700 : AppColors.creamBorder, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: const BorderSide(color: AppColors.gold500, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Recent Lookups Dropdown Panel when search bar is focused
              if (_isSearchFocused && _recentSearches.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardColor(context),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.gold500.withValues(alpha: 0.6)
                          : AppColors.creamBorder,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.history, size: 14, color: Theme.of(context).brightness == Brightness.dark ? AppColors.gold500 : AppColors.forest500),
                                const SizedBox(width: 6),
                                Text(
                                  'Recent Lookups',
                                  style: AppTypography.labelBold.copyWith(
                                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.gold400 : AppColors.forest700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                setState(() => _recentSearches.clear());
                                try {
                                  final user = ref.read(authStateProvider).value;
                                  final userId = user?.id ?? 'guest';
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.remove('lumad_recent_searches_$userId');
                                } catch (_) {}
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(40, 24),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Clear',
                                style: AppTypography.caption.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark ? AppColors.creamText3 : AppColors.forest500.withValues(alpha: 0.7),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Theme.of(context).brightness == Brightness.dark ? AppColors.gold500.withValues(alpha: 0.4) : AppColors.creamBorder,
                        height: 1,
                        thickness: 0.5,
                      ),
                      ..._recentSearches.map((term) {
                        return InkWell(
                          onTap: () {
                            _applySearchChip(term);
                            _searchFocusNode.unfocus();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Icon(Icons.search, size: 16, color: Theme.of(context).brightness == Brightness.dark ? AppColors.gold400 : AppColors.forest500),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    term,
                                    style: AppTypography.bodyLarge.copyWith(
                                      color: AppColors.textColor(context),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Icon(Icons.north_west, size: 14, color: AppColors.subtitleColor(context)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // Category (Part of Speech) Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: BrandFilterChip(
                        label: cat,
                        isSelected: isSelected,
                        onSelected: (_) {
                          ref.read(dictionaryFilterProvider.notifier).updateCategory(cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Dynamic Search Results Section with Pagination
              selectedCategory == 'Saved'
                  ? _buildWordList(
                      selectedCategory == 'Saved'
                          ? (filterState.searchQuery.isEmpty
                              ? savedBookmarks.values.toList()
                              : savedBookmarks.values.where((w) {
                                  final q = filterState.searchQuery.toLowerCase();
                                  return w.headword.toLowerCase().contains(q) || w.translation.toLowerCase().contains(q);
                                }).toList())
                          : [],
                      selectedCategory,
                      false,
                    )
                  : paginationAsync.when(
                      skipLoadingOnRefresh: true,
                      data: (pagedState) => _buildWordList(
                        pagedState.words,
                        selectedCategory,
                        pagedState.isLoadingMore,
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: CircularProgressIndicator(color: AppColors.gold500)),
                      ),
                      error: (err, stack) => AppErrorWidget(
                        message: 'Failed to search dictionary: $err',
                        onRetry: () => ref.invalidate(dictionaryPaginationProvider),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordList(List<VocabularyModel> filteredWords, String selectedCategory, bool isLoadingMore) {
    if (filteredWords.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selectedCategory == 'Saved' ? Icons.bookmark_border : Icons.search_off,
              size: 64,
              color: AppColors.creamText3,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              selectedCategory == 'Saved'
                  ? 'No saved study bookmarks yet.\nTap the bookmark icon on any word to save it!'
                  : 'No dictionary entries match your search.',
              style: AppTypography.h3.copyWith(color: AppColors.subtitleColor(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            BrandButton(
              text: selectedCategory == 'Saved'
                  ? 'Explore All Dictionary Words 📖'
                  : 'Clear Search & Filters 🔄',
              type: BrandButtonType.gold,
              onPressed: () {
                _searchController.clear();
                ref.read(dictionaryFilterProvider.notifier).updateQuery('');
                ref.read(dictionaryFilterProvider.notifier).updateCategory('All');
              },
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...filteredWords.map((vocab) {
          final isBookmarked = ref.read(bookmarksProvider.notifier).isBookmarked(vocab);

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: BrandCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              onTap: () {
                context.push('/dictionary/details', extra: vocab);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Headword and translation
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vocab.headword,
                          style: AppTypography.lessonTitle.copyWith(color: Colors.white, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vocab.translation,
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Right: Action buttons (Bookmark, Chevron)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final nowSaved = await ref.read(bookmarksProvider.notifier).toggleBookmark(vocab);
                          if (context.mounted) {
                            messenger.clearSnackBars();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(nowSaved
                                    ? 'Saved "${vocab.headword}" to study bookmarks!'
                                    : 'Removed "${vocab.headword}" from bookmarks.'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? AppColors.gold500 : AppColors.creamText3,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.creamText3,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        if (selectedCategory != 'Saved' && isLoadingMore) ...[
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Center(child: CircularProgressIndicator(color: AppColors.gold500)),
          ),
        ],
      ],
    );
  }
}
