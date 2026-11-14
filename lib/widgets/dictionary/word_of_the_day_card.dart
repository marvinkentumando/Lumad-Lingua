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
          backgroundColor: AppColors.gold500.withValues(alpha: 0.15),
          border: Border.all(color: AppColors.gold500, width: 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny, color: AppColors.gold500, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'WORD OF THE DAY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: AppColors.textColor(context),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Text(
                      word.partOfSpeech.toUpperCase(),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                word.headword,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor(context),
                ),
              ),
              if (word.pronunciation != null && word.pronunciation!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  '[ ${word.pronunciation} ]',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.forestGreen),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Meaning: "${word.translation}"',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textColor(context)),
              ),
              if (word.exampleSentence.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '"${word.exampleSentence}"',
                  style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.subtitleColor(context)),
                ),
                if (word.exampleTranslation.isNotEmpty)
                  Text(
                    '(${word.exampleTranslation})',
                    style: TextStyle(fontSize: 12, color: AppColors.subtitleColor(context)),
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
                type: BrandButtonType.secondary,
                onPressed: () => context.push('/dictionary/details', extra: word),
              ),
            ],
          ),
        );
      },
      loading: () => const AppCard(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
