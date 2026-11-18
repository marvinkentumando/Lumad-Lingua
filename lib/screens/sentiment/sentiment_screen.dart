import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../models/sentiment_model.dart';
import '../../repositories/sentiment_repository.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';

final sentimentRepositoryProvider = Provider<SentimentRepository>((ref) {
  return MockSentimentRepository();
});

class SentimentScreen extends ConsumerStatefulWidget {
  const SentimentScreen({super.key});

  @override
  ConsumerState<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends ConsumerState<SentimentScreen> {
  final _textController = TextEditingController(
    text: 'Madyaw na masurom sang tanan sakop sang banwa!',
  );
  bool _isLoading = false;
  SentimentAnalysisResult? _result;

  final List<Map<String, String>> _presets = [
    {
      'label': 'Good Morning ☀️',
      'text': 'Madyaw na masurom sang tanan sakop sang banwa!',
      'translation': 'Good morning to everyone in the community!',
    },
    {
      'label': 'Happy to See You 😊',
      'text': 'Malipayon ako nga nakita ko kamo.',
      'translation': 'I am happy to see you all.',
    },
    {
      'label': 'Overcoming Challenge 📚',
      'text': 'Mabudlay ang pagtuon apang madalag-on kita.',
      'translation': 'Learning is difficult, but we will succeed.',
    },
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _analyzeText() async {
    final rawText = _textController.text.trim();
    if (rawText.isEmpty) return;

    final queryText = rawText.length > 500 ? rawText.substring(0, 500) : rawText;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    final repo = ref.read(sentimentRepositoryProvider);
    final result = await repo.analyzeText(queryText);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _result = SentimentAnalysisResult(
          text: result.text,
          sentiment: result.sentiment,
          languageClassification: result.languageClassification,
          confidenceScore: result.confidenceScore,
          modelName: 'Admin Active Model (BiLSTM/SVM)',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mansaka Sentiment & Tone', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LumadBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Friendly Info Banner
                BrandCard(
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_emotions_outlined, color: AppColors.gold500, size: 36),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Discover the emotion, tone, and feeling hidden inside Mansaka expressions!',
                          style: AppTypography.bodyLarge.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Preset Selector
                Text('Sample Expressions to Try', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presets.length,
                    itemBuilder: (context, index) {
                      final preset = _presets[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ActionChip(
                          label: Text(preset['label']!, style: AppTypography.labelBold.copyWith(fontSize: 12)),
                          backgroundColor: AppColors.creamSurface,
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _textController.text = preset['text']!;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Input Field
                Text('Mansaka Text Input', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: _textController,
                  maxLines: 3,
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textColor(context)),
                  decoration: const InputDecoration(
                    hintText: 'Type or select a sample Mansaka sentence...',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                BrandButton(
                  text: 'Check Sentence Tone',
                  icon: Icons.psychology,
                  type: BrandButtonType.gold,
                  isLoading: _isLoading,
                  onPressed: _analyzeText,
                ),

                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('Sentiment Result', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.sm),
                  BrandCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Emotional Mood:',
                                style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getSentimentColor(_result!.sentiment),
                                  borderRadius: BorderRadius.circular(AppRadius.chip),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _getSentimentEmoji(_result!.sentiment),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        _getSentimentTitle(_result!.sentiment),
                                        style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSentimentExplanation(_result!.sentiment),
                          style: AppTypography.body.copyWith(color: AppColors.creamBorder, fontStyle: FontStyle.italic),
                        ),
                        const Divider(color: AppColors.forest700, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Language Identity:',
                                style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gold500,
                                  borderRadius: BorderRadius.circular(AppRadius.chip),
                                ),
                                child: Text(
                                  _result!.languageClassification.name == 'mansaka' ? 'AUTHENTIC MANSAKA 🌿' : 'MIXED EXPRESSION 💬',
                                  style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Accuracy Rating:',
                                style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(_result!.confidenceScore * 100).toInt()}% Certainty 🌟',
                              style: AppTypography.mono.copyWith(color: AppColors.gold400, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: _result!.confidenceScore),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            builder: (context, animatedVal, child) {
                              return LinearProgressIndicator(
                                value: animatedVal,
                                backgroundColor: AppColors.forest700,
                                color: AppColors.gold500,
                                minHeight: 10,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSentimentColor(SentimentLabel label) {
    switch (label) {
      case SentimentLabel.positive:
        return AppColors.semanticGreen;
      case SentimentLabel.negative:
        return AppColors.semanticRed;
      case SentimentLabel.neutral:
        return AppColors.semanticWarning;
    }
  }

  String _getSentimentEmoji(SentimentLabel label) {
    switch (label) {
      case SentimentLabel.positive:
        return '😊';
      case SentimentLabel.negative:
        return '😔';
      case SentimentLabel.neutral:
        return '😐';
    }
  }

  String _getSentimentTitle(SentimentLabel label) {
    switch (label) {
      case SentimentLabel.positive:
        return 'JOYFUL & POSITIVE';
      case SentimentLabel.negative:
        return 'SOLEMN / CHALLENGING';
      case SentimentLabel.neutral:
        return 'CALM & BALANCED';
    }
  }

  String _getSentimentExplanation(SentimentLabel label) {
    switch (label) {
      case SentimentLabel.positive:
        return 'This phrase expresses warmth, joy, gratitude, and community happiness!';
      case SentimentLabel.negative:
        return 'This phrase touches on solemn, serious, or difficult learning challenges.';
      case SentimentLabel.neutral:
        return 'This phrase states a calm, balanced daily expression.';
    }
  }
}
