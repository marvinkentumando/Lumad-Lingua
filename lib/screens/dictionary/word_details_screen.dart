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
        title: Text(vocabulary.headword),
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
                      Text(
                        vocabulary.headword,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.forestGreen,
                        ),
                      ),
                      Chip(
                        label: Text(vocabulary.partOfSpeech),
                        backgroundColor: AppColors.lightGreenBackground,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Translation: ${vocabulary.translation}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Reference Audio',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            AudioPlayerWidget(
              audioUrl: vocabulary.audioUrl,
              title: vocabulary.headword,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Example Usage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vocabulary.exampleSentence,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'English: "${vocabulary.exampleTranslation}"',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkCharcoal.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (vocabulary.relatedWords.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Related Vocabulary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: 8,
                children: vocabulary.relatedWords
                    .map((word) => Chip(label: Text(word)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
