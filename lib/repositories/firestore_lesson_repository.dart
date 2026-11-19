import 'package:firebase_auth/firebase_auth.dart';
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
  Future<List<LearningUnitModel>> getUnits({String? userId}) async {
    return await _firestoreService.getUnits(userId: userId);
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
    final uid = (userId != null && userId.isNotEmpty)
        ? userId
        : FirebaseAuth.instance.currentUser?.uid;

    if (uid != null && uid.isNotEmpty) {
      await _firestoreService.updateLessonProgress(uid, lessonId, starsEarned);
    }
  }

  @override
  Stream<List<LearningUnitModel>> watchUnits({String? userId}) {
    return _firestoreService.watchUnits(userId: userId);
  }

  @override
  Stream<List<LessonModel>> watchLessonsForUnit(String unitId, {String? userId}) {
    return _firestoreService.watchLessonsForUnit(unitId, userId: userId);
  }

  @override
  Stream<List<ActivityModel>> watchActivitiesForLesson(String lessonId) {
    return _firestoreService.watchActivitiesForLesson(lessonId);
  }
}
