class PronunciationAttemptModel {
  final String id;
  final String wordOrPhrase;
  final String? audioPath;
  final double? score;
  final String? feedback;
  final DateTime timestamp;
  final bool isEvaluated;

  const PronunciationAttemptModel({
    required this.id,
    required this.wordOrPhrase,
    this.audioPath,
    this.score,
    this.feedback,
    required this.timestamp,
    this.isEvaluated = false,
  });
}
