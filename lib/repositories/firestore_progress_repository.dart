import '../models/progress_model.dart';
import '../models/achievement_model.dart';
import '../services/firestore_service.dart';
import '../services/local_cache_service.dart';
import '../data/mock_progress.dart';
import '../data/mock_achievements.dart';
import 'progress_repository.dart';

class FirestoreProgressRepository implements ProgressRepository {
  final FirestoreService _firestoreService;
  final LocalCacheService _cacheService = LocalCacheService();

  FirestoreProgressRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<UserProgressModel> getUserProgress(String userId) async {
    try {
      final progress = await _firestoreService.getUserProgress(userId);
      if (progress != null) {
        await _cacheService.cacheJson('progress_$userId', progress.toJson());
        return progress;
      }
    } catch (_) {
      // Offline fallback
    }

    // Try local cache
    final cached = _cacheService.getCachedJson('progress_$userId');
    if (cached != null) {
      try {
        return UserProgressModel.fromJson(cached);
      } catch (_) {}
    }

    return mockUserProgress.copyWith(userId: userId);
  }

  @override
  Future<List<AchievementModel>> getAchievements(String userId) async {
    try {
      final achievements = await _firestoreService.getAchievements(userId);
      if (achievements.isNotEmpty) {
        await _cacheService.cacheJsonList(
          'achievements_$userId',
          achievements.map((a) => a.toJson()).toList(),
        );
        return achievements;
      }
    } catch (_) {
      // Offline fallback
    }

    // Try local cache
    final cachedList = _cacheService.getCachedJsonList('achievements_$userId');
    if (cachedList != null && cachedList.isNotEmpty) {
      try {
        return cachedList.map((map) => AchievementModel.fromJson(map)).toList();
      } catch (_) {}
    }

    return mockAchievementsList;
  }
}
