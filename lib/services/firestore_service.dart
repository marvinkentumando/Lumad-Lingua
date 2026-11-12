import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/learning_unit_model.dart';
import '../models/lesson_model.dart';
import '../models/activity_model.dart';
import '../models/progress_model.dart';
import '../models/achievement_model.dart';
import '../models/vocabulary_model.dart';
import '../data/mock_lessons.dart';
import '../data/mock_vocabulary.dart';
import '../data/mock_achievements.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection References
  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _unitsCol =>
      _firestore.collection('learning_units');
  CollectionReference<Map<String, dynamic>> get _lessonsCol =>
      _firestore.collection('lessons');
  CollectionReference<Map<String, dynamic>> get _activitiesCol =>
      _firestore.collection('learning_activities');
  CollectionReference<Map<String, dynamic>> get _progressCol =>
      _firestore.collection('user_progress');
  CollectionReference<Map<String, dynamic>> get _vocabularyCol =>
      _firestore.collection('vocabulary');

  // --- Users ---
  Future<UserModel?> getUser(String userId) async {
    final doc = await _usersCol.doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    data['id'] = userId;
    return UserModel.fromJson(data);
  }

  Future<void> saveUser(UserModel user) async {
    await _usersCol.doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  // --- Units & Lessons ---
  Future<List<LearningUnitModel>> getUnits() async {
    final snapshot = await _unitsCol.orderBy('unitNumber').get();
    if (snapshot.docs.isEmpty) {
      await seedCurriculumIfEmpty();
      final reFetch = await _unitsCol.orderBy('unitNumber').get();
      return reFetch.docs.map((d) => LearningUnitModel.fromJson(d.data())).toList();
    }
    return snapshot.docs.map((d) => LearningUnitModel.fromJson(d.data())).toList();
  }

  Future<List<LessonModel>> getLessonsForUnit(String unitId) async {
    final snapshot = await _lessonsCol
        .where('unitId', isEqualTo: unitId)
        .orderBy('lessonOrder')
        .get();
    if (snapshot.docs.isEmpty) {
      final filtered = mockLessons.where((l) => l.unitId == unitId).toList();
      return filtered;
    }
    return snapshot.docs.map((d) => LessonModel.fromJson(d.data())).toList();
  }

  Future<List<ActivityModel>> getActivitiesForLesson(String lessonId) async {
    final snapshot = await _activitiesCol
        .where('lessonId', isEqualTo: lessonId)
        .get();
    if (snapshot.docs.isEmpty) {
      return mockLesson1Activities;
    }
    return snapshot.docs.map((d) => ActivityModel.fromJson(d.data())).toList();
  }

  Future<void> updateLessonProgress(String lessonId, int starsEarned) async {
    await _lessonsCol.doc(lessonId).set({
      'status': LessonStatus.completed.name,
      'starsEarned': starsEarned,
    }, SetOptions(merge: true));
  }

  // --- User Progress ---
  Future<UserProgressModel?> getUserProgress(String userId) async {
    final doc = await _progressCol.doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    final data = doc.data()!;
    data['userId'] = userId;
    return UserProgressModel.fromJson(data);
  }

  Future<void> saveUserProgress(UserProgressModel progress) async {
    await _progressCol.doc(progress.userId).set(progress.toJson(), SetOptions(merge: true));
  }

  // --- Achievements ---
  Future<List<AchievementModel>> getAchievements(String userId) async {
    final snapshot = await _usersCol.doc(userId).collection('achievements').get();
    if (snapshot.docs.isEmpty) {
      return mockAchievementsList;
    }
    return snapshot.docs.map((d) => AchievementModel.fromJson(d.data())).toList();
  }

  // --- Vocabulary / Dictionary ---
  Future<List<VocabularyModel>> searchVocabulary(String query) async {
    final snapshot = await _vocabularyCol.get();
    if (snapshot.docs.isEmpty) {
      await seedVocabularyIfEmpty();
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return mockVocabularyList;
      return mockVocabularyList
          .where((w) =>
              w.headword.toLowerCase().contains(q) ||
              w.translation.toLowerCase().contains(q) ||
              w.category.toLowerCase().contains(q))
          .toList();
    }
    final docs = snapshot.docs.map((d) => VocabularyModel.fromJson(d.data())).toList();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return docs;
    return docs
        .where((w) =>
            w.headword.toLowerCase().contains(q) ||
            w.translation.toLowerCase().contains(q) ||
            w.category.toLowerCase().contains(q))
        .toList();
  }

  Future<VocabularyModel?> getWordById(String id) async {
    final doc = await _vocabularyCol.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return VocabularyModel.fromJson(doc.data()!);
    }
    try {
      return mockVocabularyList.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Database Seeding ---
  Future<void> seedCurriculumIfEmpty() async {
    final unitsCheck = await _unitsCol.limit(1).get();
    if (unitsCheck.docs.isEmpty) {
      final batch = _firestore.batch();
      for (final unit in mockUnits) {
        batch.set(_unitsCol.doc(unit.id), unit.toJson());
      }
      for (final lesson in mockLessons) {
        batch.set(_lessonsCol.doc(lesson.id), lesson.toJson());
      }
      for (final activity in mockLesson1Activities) {
        batch.set(_activitiesCol.doc(activity.id), activity.toJson());
      }
      await batch.commit();
    }
  }

  Future<void> seedVocabularyIfEmpty() async {
    final vocabCheck = await _vocabularyCol.limit(1).get();
    if (vocabCheck.docs.isEmpty) {
      final batch = _firestore.batch();
      for (final word in mockVocabularyList) {
        batch.set(_vocabularyCol.doc(word.id), word.toJson());
      }
      await batch.commit();
    }
  }
}
