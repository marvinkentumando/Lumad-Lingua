import '../models/progress_model.dart';
import '../models/achievement_model.dart';
import '../data/mock_progress.dart';
import '../data/mock_achievements.dart';

abstract class ProgressRepository {
  Future<UserProgressModel> getUserProgress(String userId);
  Future<List<AchievementModel>> getAchievements(String userId);
}

class MockProgressRepository implements ProgressRepository {
  final UserProgressModel _progress = mockUserProgress;

  @override
  Future<UserProgressModel> getUserProgress(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _progress;
  }

  @override
  Future<List<AchievementModel>> getAchievements(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockAchievementsList;
  }
}
