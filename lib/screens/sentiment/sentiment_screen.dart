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
      'text': 'Madyaw na masurom sang tanan sakop sang banwa!',
      'translation': 'Good morning to everyone in the community!',
    },
    {
      'text': 'Malipayon ako nga nakita ko kamo.',
      'translation': 'I am happy to see you all.',
    },
    {
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
    if (_textController.text.trim().isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    final repo = ref.read(sentimentRepositoryProvider);
    final result = await repo.analyzeText(_textController.text.trim());

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
        title: Text('Sentiment Analysis Lab', style: AppTypography.h2.copyWith(color: Colors.white)),
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
                // Info Banner
                BrandCard(
                  child: Row(
                    children: [
                      const Icon(Icons.analytics_outlined, color: AppColors.gold500, size: 28),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Classifies community sentiment using admin-configured NLP models tailored for indigenous language preservation.',
                          style: AppTypography.body.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Preset Selector
                Text('Preset Sample Phrases', style: AppTypography.h3),
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
                          label: Text('${preset['text']!.substring(0, 22)}...', style: AppTypography.labelBold.copyWith(fontSize: 12)),
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
                  maxLines: 4,
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textColor(context)),
                  decoration: const InputDecoration(
                    hintText: 'Type or select a preset Mansaka text...',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                BrandButton(
                  text: 'Analyze Sentiment',
                  icon: Icons.psychology,
                  type: BrandButtonType.gold,
                  isLoading: _isLoading,
                  onPressed: _analyzeText,
                ),

                if (_result != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('Analysis Results', style: AppTypography.h3),
                  const SizedBox(height: AppSpacing.sm),
                  BrandCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sentiment:', style: AppTypography.labelBold.copyWith(color: Colors.white)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getSentimentColor(_result!.sentiment),
                                borderRadius: BorderRadius.circular(AppRadius.chip),
                              ),
                              child: Text(
                                _result!.sentiment.name.toUpperCase(),
                                style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.forest700),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Language Classification:', style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder)),
                            Text(
                              _result!.languageClassification.name.toUpperCase(),
                              style: AppTypography.labelBold.copyWith(color: AppColors.gold500),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Confidence Score:', style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder)),
                            Text(
                              '${(_result!.confidenceScore * 100).toStringAsFixed(1)}%',
                              style: AppTypography.mono.copyWith(color: AppColors.gold500, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _result!.confidenceScore,
                            backgroundColor: AppColors.forest700,
                            color: AppColors.gold500,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Active Model Engine:', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                            Text(
                              _result!.modelName,
                              style: AppTypography.mono.copyWith(color: AppColors.gold300, fontSize: 11),
                            ),
                          ],
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
}
