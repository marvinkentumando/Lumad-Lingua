import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/dictionary_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../common/brand_button.dart';

class WordOfTheDayCard extends ConsumerWidget {
  const WordOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordAsync = ref.watch(wordOfTheDayProvider);
    ref.watch(bookmarksProvider);

    return wordAsync.when(
      data: (word) {
        if (word == null) return const SizedBox.shrink();

        final isSaved = ref.read(bookmarksProvider.notifier).isBookmarked(word);

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFD54F), AppColors.gold500, Color(0xFFFFA000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.gold700, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFC78C00),
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Stack(
              children: [
                // Traditional Mansaka Geometric Watermark in Background
                Positioned(
                  right: -20,
                  bottom: -20,
                  child: Icon(
                    Icons.filter_vintage,
                    size: 140,
                    color: AppColors.forest900.withValues(alpha: 0.08),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: AppColors.forest900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'WORD OF THE DAY',
                              style: AppTypography.labelBold.copyWith(
                                color: AppColors.forest900,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    final nowSaved = await ref.read(bookmarksProvider.notifier).toggleBookmark(word);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(nowSaved ? 'Saved "${word.headword}" to study bookmarks!' : 'Removed "${word.headword}" from bookmarks.'),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.forest900.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                                      color: AppColors.forest900,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          word.headword,
                          style: AppTypography.flashcard.copyWith(color: AppColors.forest900, fontSize: 30),
                        ),
                        if (word.pronunciation != null && word.pronunciation!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '[ ${word.pronunciation} ]',
                            style: AppTypography.phoneticGuide.copyWith(color: AppColors.gold900, fontSize: 14),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          '"${word.translation}"',
                          style: AppTypography.h3.copyWith(color: AppColors.forest900),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        BrandButton(
                          text: 'View Word Details',
                          type: BrandButtonType.primary,
                          onPressed: () => context.push('/dictionary/details', extra: word),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.gold500,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.forest900)),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
