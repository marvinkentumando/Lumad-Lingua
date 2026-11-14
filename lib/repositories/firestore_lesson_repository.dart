import '../models/learning_unit_model.dart';
import '../models/lesson_model.dart';
import '../models/activity_model.dart';
import '../services/firestore_service.dart';
import 'lesson_repository.dart';

class FirestoreLessonRepository implements LessonRepository {
  final FirestoreService _firestoreService;

  FirestoreLessonRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  @override
  Future<List<LearningUnitModel>> getUnits() async {
    return await _firestoreService.getUnits();
  }

  @override
  Future<List<LessonModel>> getLessonsForUnit(String unitId, {String? userId}) async {
    return await _firestoreService.getLessonsForUnit(unitId, userId: userId);
  }

  @override
  Future<List<ActivityModel>> getActivitiesForLesson(String lessonId) async {
    return await _firestoreService.getActivitiesForLesson(lessonId);
  }

  @override
  Future<void> updateLessonProgress(String lessonId, int starsEarned, {String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      await _firestoreService.updateLessonProgress(userId, lessonId, starsEarned);
    }
  }
}
