import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sentiment_model.dart';
import '../services/local_ml_service.dart';
import '../services/admin_config_service.dart';

abstract class SentimentRepository {
  Future<SentimentAnalysisResult> analyzeText(String text);
}

class MockSentimentRepository implements SentimentRepository {
  final AdminConfigService _adminConfigService;

  MockSentimentRepository({AdminConfigService? adminConfigService})
      : _adminConfigService = adminConfigService ?? AdminConfigService();

  @override
  Future<SentimentAnalysisResult> analyzeText(String text) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final config = await _adminConfigService.getActiveAlgorithmConfig();
    final modelMode = config['sentiment_model'] as String? ?? 'ensemble';
    final result = LocalMlService.analyzeWithConfig(text, modelMode);

    // Log sentiment analysis result to Cloud Firestore for external admin dashboards
    try {
      await FirebaseFirestore.instance.collection('sentiment_logs').add({
        'text': result.text,
        'sentiment': result.sentiment.name,
        'languageClassification': result.languageClassification.name,
        'confidenceScore': result.confidenceScore,
        'modelName': result.modelName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Ignore network/offline logging failures to prevent disrupting user experience
    }

    return result;
  }
}
