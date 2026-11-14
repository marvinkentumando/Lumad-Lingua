import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/duel_service.dart';
import '../models/duel_model.dart';

final duelServiceProvider = Provider<DuelService>((ref) {
  return DuelService();
});

final duelSessionStreamProvider = StreamProvider.family<DuelSessionModel?, String>((ref, sessionId) {
  final service = ref.watch(duelServiceProvider);
  return service.watchDuelSession(sessionId);
});
