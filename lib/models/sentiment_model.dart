enum SentimentLabel { positive, neutral, negative }
enum LanguageClassification { mansaka, mixed, notMansaka }

class SentimentAnalysisResult {
  final String text;
  final SentimentLabel sentiment;
  final LanguageClassification languageClassification;
  final double confidenceScore;
  final String modelName;

  const SentimentAnalysisResult({
    required this.text,
    required this.sentiment,
    required this.languageClassification,
    required this.confidenceScore,
    required this.modelName,
  });
}
