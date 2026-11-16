import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_model.dart';
import '../models/achievement_model.dart';
import '../repositories/progress_repository.dart';
import '../repositories/firestore_progress_repository.dart';
import 'auth_provider.dart';

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return FirestoreProgressRepository();
});

final userProgressProvider = FutureProvider<UserProgressModel>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  final userId = user?.id ?? 'guest';
  return repo.getUserProgress(userId);
});

final achievementsProvider = FutureProvider<List<AchievementModel>>((ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  final user = ref.watch(authStateProvider).value;
  final userId = user?.id ?? 'guest';
  return repo.getAchievements(userId);
});

