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
    return LocalMlService.analyzeWithConfig(text, modelMode);
  }
}
