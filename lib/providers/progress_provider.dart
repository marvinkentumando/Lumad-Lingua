import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_model.dart';
import '../models/achievement_model.dart';
import '../repositories/progress_repository.dart';
import '../repositories/firestore_progress_repository.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return FirestoreProgressRepository();
});

final userProgressProvider = FutureProvider<UserProgressModel>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getUserProgress('user_1');
});

final achievementsProvider = FutureProvider<List<AchievementModel>>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getAchievements('user_1');
});
