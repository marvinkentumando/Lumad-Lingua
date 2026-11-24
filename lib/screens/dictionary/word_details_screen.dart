import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/vocabulary_model.dart';
import '../../models/daily_quest_model.dart';
import '../../utils/constants.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/daily_quests_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/audio/audio_player_widget.dart';

class WordDetailsScreen extends ConsumerWidget {
  final VocabularyModel vocabulary;

  const WordDetailsScreen({super.key, required this.vocabulary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(bookmarksProvider);
    final isBookmarked = ref.read(bookmarksProvider.notifier).isBookmarked(vocabulary);

    // Increment dictionary exploration daily quest progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyQuestsProvider.notifier).incrementProgress(QuestType.dictionary);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(vocabulary.headword, style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.gold500 : Colors.white,
            ),
            tooltip: isBookmarked ? 'Remove Bookmark' : 'Save Bookmark',
            onPressed: () async {
              final nowSaved = await ref.read(bookmarksProvider.notifier).toggleBookmark(vocabulary);
              if (context.mounted) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(nowSaved
                        ? 'Saved "${vocabulary.headword}" to study bookmarks!'
                        : 'Removed "${vocabulary.headword}" from bookmarks.'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: LumadBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Ancestral Gold Headword Banner (With Dual-Tone Gold Gradient)
              BrandCard(
                backgroundColor: AppColors.gold500,
                child: DefaultTextStyle(
                  style: const TextStyle(color: AppColors.forest900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vocabulary.headword,
                              style: AppTypography.flashcard.copyWith(color: AppColors.forest900, fontSize: 32),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.forest900,
                              borderRadius: BorderRadius.circular(AppRadius.chip),
                            ),
                            child: Text(
                              vocabulary.partOfSpeech.toUpperCase(),
                              style: AppTypography.labelBold.copyWith(color: AppColors.gold500, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      if (vocabulary.pronunciation != null && vocabulary.pronunciation!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '[ ${vocabulary.pronunciation} ]',
                          style: AppTypography.phoneticGuide.copyWith(color: AppColors.gold900, fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Translation: "${vocabulary.translation}"',
                        style: AppTypography.h3.copyWith(color: AppColors.forest900),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Reference Audio',
                style: AppTypography.h3.copyWith(color: AppColors.textColor(context)),
              ),
              const SizedBox(height: AppSpacing.xs),
              AudioPlayerWidget(
                audioUrl: vocabulary.audioUrl,
                title: vocabulary.headword,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Example Usages (Editorial Flush Layout for all examples)
              Text(
                vocabulary.examples.length > 1 ? 'Example Usages (${vocabulary.examples.length})' : 'Example Usage',
                style: AppTypography.h3.copyWith(color: AppColors.textColor(context)),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...vocabulary.examples.asMap().entries.map((entry) {
                final index = entry.key;
                final ex = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index < vocabulary.examples.length - 1 ? AppSpacing.md : 0),
                  child: Container(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: AppColors.gold500, width: 4.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"${ex.mansaka}"',
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.textColor(context), fontStyle: FontStyle.italic, fontSize: 16),
                        ),
                        if (ex.english.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            ex.english,
                            style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
