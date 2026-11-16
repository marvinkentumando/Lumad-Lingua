import 'package:flutter/material.dart';
import '../../models/vocabulary_model.dart';
import '../../utils/constants.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';
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

              // Example Usage (Editorial Flush Layout without Boxy Card)
              Text(
                'Example Usage',
                style: AppTypography.h3.copyWith(color: AppColors.textColor(context)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
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
                      '"${vocabulary.exampleSentence}"',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textColor(context), fontStyle: FontStyle.italic, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vocabulary.exampleTranslation,
                      style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
