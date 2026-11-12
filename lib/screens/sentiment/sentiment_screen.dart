import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../models/sentiment_model.dart';
import '../../repositories/sentiment_repository.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';

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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _analyzeText() async {
    if (_textController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    final repo = ref.read(sentimentRepositoryProvider);
    final result = await repo.analyzeText(_textController.text.trim());

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
        title: const Text('Sentiment Analysis Lab'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warmYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warmYellow),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline, color: AppColors.darkCharcoal),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Research & Analytics Tool: Analyzes Mansaka social media text using Naive Bayes, SVM, and BiLSTM classification models.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Enter Mansaka Post or Text',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type or paste Mansaka text here...',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: 'Analyze Sentiment',
                isLoading: _isLoading,
                onPressed: _analyzeText,
              ),
              if (_result != null) ...[
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Analysis Results',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sentiment:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Chip(
                            label: Text(
                              _result!.sentiment.name.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: _getSentimentColor(_result!.sentiment),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Language Classification:'),
                          Text(
                            _result!.languageClassification.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Confidence Score:'),
                          Text(
                            '${(_result!.confidenceScore * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Model:'),
                          Flexible(
                            child: Text(
                              _result!.modelName,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                              textAlign: TextAlign.end,
                            ),
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
    );
  }

  Color _getSentimentColor(SentimentLabel label) {
    switch (label) {
      case SentimentLabel.positive:
        return AppColors.brightGreen;
      case SentimentLabel.negative:
        return AppColors.coralRed;
      case SentimentLabel.neutral:
        return Colors.orangeAccent;
    }
  }
}
