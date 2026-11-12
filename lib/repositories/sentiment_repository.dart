import '../models/sentiment_model.dart';

abstract class SentimentRepository {
  Future<SentimentAnalysisResult> analyzeText(String text);
}

class MockSentimentRepository implements SentimentRepository {
  @override
  Future<SentimentAnalysisResult> analyzeText(String text) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final lower = text.toLowerCase();
    SentimentLabel sentiment = SentimentLabel.neutral;
    double confidence = 0.88;

    if (lower.contains('madyaw') || lower.contains('marayaw') || lower.contains('salamat') || lower.contains('good')) {
      sentiment = SentimentLabel.positive;
      confidence = 0.94;
    } else if (lower.contains('samok') || lower.contains('gubat') || lower.contains('bad')) {
      sentiment = SentimentLabel.negative;
      confidence = 0.89;
    }

    bool isMansaka = lower.contains('madyaw') || lower.contains('masurom') || lower.contains('gabila') || lower.contains('gabi') || lower.contains('banwa');

    return SentimentAnalysisResult(
      text: text,
      sentiment: sentiment,
      languageClassification: isMansaka ? LanguageClassification.mansaka : LanguageClassification.mixed,
      confidenceScore: confidence,
      modelName: 'Mock SVM / BiLSTM (Mansaka Classifier Prototype)',
    );
  }
}
