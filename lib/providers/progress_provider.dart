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
  final baseList = await repo.getAchievements(userId);

  if (user == null) {
    return baseList;
  }

  // Calculate live dynamic achievement progress ratios based on user state
  return baseList.map((ach) {
    double ratio = ach.progressRatio;
    bool unlocked = ach.isUnlocked;

    switch (ach.id) {
      case 'ach_first_lesson':
        ratio = user.totalXp >= 30 ? 1.0 : (user.totalXp / 30).clamp(0.0, 1.0);
        unlocked = ratio >= 1.0;
        break;
      case 'ach_streak_3':
        ratio = (user.streakDays / 3.0).clamp(0.0, 1.0);
        unlocked = ratio >= 1.0;
        break;
      case 'ach_streak_7':
        ratio = (user.streakDays / 7.0).clamp(0.0, 1.0);
        unlocked = ratio >= 1.0;
        break;
      case 'ach_xp_500':
        ratio = (user.totalXp / 500.0).clamp(0.0, 1.0);
        unlocked = ratio >= 1.0;
        break;
      case 'ach_crystal_collector':
        ratio = (user.crystals / 100.0).clamp(0.0, 1.0);
        unlocked = ratio >= 1.0;
        break;
      case 'ach_unit_1':
        ratio = (user.level / 2.0).clamp(0.0, 1.0);
        unlocked = ratio >= 1.0;
        break;
    }

    return ach.copyWith(
      isUnlocked: unlocked || ach.isUnlocked,
      progressRatio: unlocked ? 1.0 : ratio,
      unlockedAt: unlocked && ach.unlockedAt == null ? DateTime.now() : ach.unlockedAt,
    );
  }).toList();
});
