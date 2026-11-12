import '../models/progress_model.dart';
import '../models/achievement_model.dart';
import '../services/firestore_service.dart';
import '../data/mock_progress.dart';
import 'progress_repository.dart';

class FirestoreProgressRepository implements ProgressRepository {
  final FirestoreService _firestoreService;

  FirestoreProgressRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<UserProgressModel> getUserProgress(String userId) async {
    final progress = await _firestoreService.getUserProgress(userId);
    if (progress != null) return progress;
    return mockUserProgress.copyWith(userId: userId);
  }

  @override
  Future<List<AchievementModel>> getAchievements(String userId) async {
    return await _firestoreService.getAchievements(userId);
  }
}
