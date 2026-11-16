import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/dictionary_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_filter_chip.dart';
import '../../widgets/common/loading_widget.dart';
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
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Greeting', 'Phrase', 'Number', 'Interjection', 'General'];

  @override
  Widget build(BuildContext context) {
    final searchResultsAsync = ref.watch(dictionarySearchResultsProvider);

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: searchResultsAsync.when(
        data: (words) {
          final filteredWords = _selectedCategory == 'All'
              ? words
              : words.where((w) => w.partOfSpeech.toLowerCase().contains(_selectedCategory.toLowerCase()) || w.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const ScreenHeader(
                title: 'Mansaka Dictionary',
                centerTitle: true,
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                onChanged: (val) {
                  ref.read(searchQueryProvider.notifier).updateQuery(val);
                },
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textColor(context)),
                decoration: InputDecoration(
                  hintText: 'Search Mansaka or English words...',
                  hintStyle: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                  prefixIcon: const Icon(Icons.search, color: AppColors.forest500),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear, color: AppColors.subtitleColor(context)),
                    onPressed: () {
                      ref.read(searchQueryProvider.notifier).updateQuery('');
                    },
                  ),
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

              if (filteredWords.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 64, color: AppColors.creamText3),
                      const SizedBox(height: AppSpacing.md),
                      Text('No dictionary entries match your search.', style: AppTypography.h3.copyWith(color: AppColors.subtitleColor(context)), textAlign: TextAlign.center),
                    ],
                  ),
                )
              else
                ...filteredWords.map((vocab) {
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
                          // Right: Audio speaker button and navigation chevron affordance
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (vocab.audioUrl != null && vocab.audioUrl!.isNotEmpty) {
                                    AudioHelper.playAudio(vocab.audioUrl!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Playing reference pronunciation audio...')),
                                    );
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.volume_up_rounded,
                                    color: AppColors.gold500,
                                    size: 26,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
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
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Searching dictionary...'),
        error: (err, stack) => AppErrorWidget(
          message: 'Failed to search dictionary: $err',
          onRetry: () => ref.invalidate(dictionarySearchResultsProvider),
        ),
      ),
    ),
  );
  }
}
