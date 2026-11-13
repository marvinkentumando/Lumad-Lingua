import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminConfigService {
  final FirebaseFirestore _firestore;

  AdminConfigService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches the active algorithm configuration set by the web admin panel
  Future<Map<String, dynamic>> getActiveAlgorithmConfig() async {
    try {
      final doc = await _firestore.collection('system_config').doc('app_settings').get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!;
      }
    } catch (e) {
      debugPrint('Error fetching admin config from Firestore: $e');
    }

    // Default fallback configuration if unconfigured or offline
    return {
      'pronunciation_algorithm': 'dtw_hmm',
      'sentiment_model': 'ensemble',
      'mfcc_coefficients': 13,
    };
  }
}
