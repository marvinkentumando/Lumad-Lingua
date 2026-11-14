import 'package:flutter/material.dart';
import '../../models/vocabulary_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/audio/audio_player_widget.dart';

class WordDetailsScreen extends StatelessWidget {
  final VocabularyModel vocabulary;

  const WordDetailsScreen({super.key, required this.vocabulary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(vocabulary.headword, style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          vocabulary.headword,
                          style: AppTypography.flashcard.copyWith(color: Colors.white, fontSize: 32),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold500,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          vocabulary.partOfSpeech.toUpperCase(),
                          style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  if (vocabulary.pronunciation != null && vocabulary.pronunciation!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '[ ${vocabulary.pronunciation} ]',
                      style: AppTypography.phoneticGuide.copyWith(color: AppColors.gold300, fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Translation: "${vocabulary.translation}"',
                    style: AppTypography.h3.copyWith(color: AppColors.creamBorder),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Reference Audio',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.xs),
            AudioPlayerWidget(
              audioUrl: vocabulary.audioUrl,
              title: vocabulary.headword,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Example Usage',
              style: AppTypography.h3,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vocabulary.exampleSentence,
                    style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'English: "${vocabulary.exampleTranslation}"',
                    style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                  ),
                ],
              ),
            ),
            if (vocabulary.relatedWords.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Related Vocabulary',
                style: AppTypography.h3,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vocabulary.relatedWords
                    .map((word) => Chip(
                          label: Text(word, style: AppTypography.labelBold.copyWith(color: AppColors.forest900)),
                          backgroundColor: AppColors.gold500,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
