import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../models/vocabulary_model.dart';
import '../../providers/dictionary_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_filter_chip.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/lumad_background.dart';
import '../../utils/audio_helper.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  late TextEditingController _searchController;
  String _selectedCategory = 'All';
  String? _playingVocabId;

  final List<String> _categories = ['All', 'Saved', 'Noun', 'Verb', 'Greeting', 'Phrase', 'General'];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(dictionarySearchResultsProvider);
    final savedBookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const ScreenHeader(
                title: 'Mansaka Dictionary',
                centerTitle: true,
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(searchQueryProvider.notifier).updateQuery(val);
                  setState(() {});
                },
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textColor(context)),
                decoration: InputDecoration(
                  hintText: 'Search Mansaka or English words...',
                  hintStyle: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.forest500),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: AppColors.subtitleColor(context)),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(searchQueryProvider.notifier).updateQuery('');
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.creamSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: const BorderSide(color: AppColors.creamBorder, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: const BorderSide(color: AppColors.creamBorder, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                    borderSide: const BorderSide(color: AppColors.forest500, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: BrandFilterChip(
                        label: cat,
                        isSelected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Dynamic Search Results Section ONLY
              searchResultsAsync.when(
                data: (words) {
                  List<VocabularyModel> filteredWords;
                  if (_selectedCategory == 'Saved') {
                    final savedList = savedBookmarks.values.toList();
                    final query = _searchController.text.trim().toLowerCase();
                    if (query.isEmpty) {
                      filteredWords = savedList;
                    } else {
                      filteredWords = savedList.where((w) {
                        return w.headword.toLowerCase().contains(query) ||
                            w.translation.toLowerCase().contains(query);
                      }).toList();
                    }
                  } else {
                    filteredWords = _selectedCategory == 'All'
                        ? words
                        : words.where((w) {
                            final catLower = _selectedCategory.toLowerCase();
                            final posMatch = w.partOfSpeech.toLowerCase().contains(catLower);
                            final catMatch = w.category.toLowerCase().contains(catLower);
                            return posMatch || catMatch;
                          }).toList();
                  }

                  if (filteredWords.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedCategory == 'Saved' ? Icons.bookmark_border : Icons.search_off,
                            size: 64,
                            color: AppColors.creamText3,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _selectedCategory == 'Saved'
                                ? 'No saved study bookmarks yet.\nTap the bookmark icon on any word to save it!'
                                : 'No dictionary entries match your search.',
                            style: AppTypography.h3.copyWith(color: AppColors.subtitleColor(context)),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: filteredWords.map((vocab) {
                      final isBookmarked = ref.read(bookmarksProvider.notifier).isBookmarked(vocab);
                      final isPlaying = _playingVocabId == vocab.id;

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
                              // Right: Action buttons (Bookmark, Play/Pause audio, Chevron)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final nowSaved = await ref.read(bookmarksProvider.notifier).toggleBookmark(vocab);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).clearSnackBars();
                                        ScaffoldMessenger.of(context).showSnackBar(
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
                                  GestureDetector(
                                    onTap: () async {
                                      if (isPlaying) {
                                        await AudioHelper.stopAudio();
                                        if (mounted) {
                                          setState(() => _playingVocabId = null);
                                        }
                                      } else {
                                        if (vocab.audioUrl != null && vocab.audioUrl!.isNotEmpty) {
                                          setState(() => _playingVocabId = vocab.id);
                                          await AudioHelper.playAudio(vocab.audioUrl!);
                                          Future.delayed(const Duration(milliseconds: 2200), () {
                                            if (mounted && _playingVocabId == vocab.id) {
                                              setState(() => _playingVocabId = null);
                                            }
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context).clearSnackBars();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Playing reference pronunciation audio...')),
                                          );
                                        }
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Icon(
                                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                        color: AppColors.gold500,
                                        size: 26,
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
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: CircularProgressIndicator(color: AppColors.gold500)),
                ),
                error: (err, stack) => AppErrorWidget(
                  message: 'Failed to search dictionary: $err',
                  onRetry: () => ref.invalidate(dictionarySearchResultsProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
