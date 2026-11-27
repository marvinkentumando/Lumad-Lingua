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
  return FirestoreSentimentRepository();
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
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mansaka Sentiment', style: AppTypography.h2.copyWith(color: Colors.white)),
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
                          label: Text(preset['label']!, style: AppTypography.labelBold.copyWith(color: AppColors.textColor(context), fontSize: 12)),
                          backgroundColor: AppColors.cardColor(context),
                          side: BorderSide(color: Theme.of(context).brightness == Brightness.dark ? AppColors.forest700 : AppColors.creamBorder),
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
                                'Sentiment Polarity:',
                                style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getSentimentEmoji(_result!.sentiment),
                              style: const TextStyle(fontSize: 32),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getSentimentExplanation(_result!.sentiment),
                          style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder, fontStyle: FontStyle.italic),
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

  String _getSentimentExplanation(SentimentLabel label) {
    switch (label) {
      case SentimentLabel.positive:
        return 'This expression feels happy, warm, and full of joy! 🎉';
      case SentimentLabel.negative:
        return 'This expression feels serious, thoughtful, or challenging. 💭';
      case SentimentLabel.neutral:
        return 'This expression feels calm, peaceful, and steady. 🌿';
    }
  }
}
