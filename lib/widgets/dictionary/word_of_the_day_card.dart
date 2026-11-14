import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/dictionary_provider.dart';
import '../common/app_card.dart';
import '../common/brand_button.dart';
import '../audio/audio_player_widget.dart';

class WordOfTheDayCard extends ConsumerWidget {
  const WordOfTheDayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordAsync = ref.watch(wordOfTheDayProvider);

    return wordAsync.when(
      data: (word) {
        if (word == null) return const SizedBox.shrink();

        return AppCard(
          backgroundColor: AppColors.gold500,
          border: Border.all(color: AppColors.gold700, width: 1.5),
          child: DefaultTextStyle(
            style: const TextStyle(color: AppColors.forest900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny, color: AppColors.forest900, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'WORD OF THE DAY',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.forest900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.forest900,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: Text(
                        word.partOfSpeech.toUpperCase(),
                        style: AppTypography.labelBold.copyWith(color: AppColors.gold500, fontSize: 10),
                      ),
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
                  'Meaning: "${word.translation}"',
                  style: AppTypography.h3.copyWith(color: AppColors.forest900),
                ),
                if (word.exampleSentence.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '"${word.exampleSentence}"',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.forest800, fontStyle: FontStyle.italic),
                  ),
                  if (word.exampleTranslation.isNotEmpty)
                    Text(
                      '(${word.exampleTranslation})',
                      style: AppTypography.body.copyWith(color: AppColors.forest900),
                    ),
                ],
                const SizedBox(height: AppSpacing.md),
                AudioPlayerWidget(
                  audioUrl: word.audioUrl,
                  title: 'Pronunciation: ${word.headword}',
                ),
                const SizedBox(height: AppSpacing.sm),
                BrandButton(
                  text: 'View Word Details in Dictionary',
                  type: BrandButtonType.primary,
                  onPressed: () => context.push('/dictionary/details', extra: word),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const AppCard(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator(color: AppColors.gold500)),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
