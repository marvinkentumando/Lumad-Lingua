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
import '../data/mock_progress.dart';

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
  CollectionReference<Map<String, dynamic>> get _achievementsCol =>
      _firestore.collection('achievements');

  // --- Users ---
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _usersCol.doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      data['id'] = userId;
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await _usersCol.doc(user.id).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      // Ignore offline errors
    }
  }

  // --- Units & Lessons ---
  Future<List<LearningUnitModel>> getUnits() async {
    try {
      final snapshot = await _unitsCol.orderBy('unitNumber').get();
      if (snapshot.docs.isEmpty) {
        await seedCurriculumIfEmpty();
        final reFetch = await _unitsCol.orderBy('unitNumber').get();
        return reFetch.docs.map((d) => LearningUnitModel.fromJson(d.data())).toList();
      }
      return snapshot.docs.map((d) => LearningUnitModel.fromJson(d.data())).toList();
    } catch (e) {
      return mockUnits;
    }
  }

  Future<List<LessonModel>> getLessonsForUnit(String unitId, {String? userId}) async {
    try {
      final altUnitId = unitId.contains('_') && !unitId.contains('_0')
          ? unitId.replaceFirst('unit_', 'unit_0')
          : (unitId.contains('_0') ? unitId.replaceFirst('unit_0', 'unit_') : unitId);

      var snapshot = await _lessonsCol
          .where('unitId', isEqualTo: unitId)
          .get();

      if (snapshot.docs.isEmpty) {
        snapshot = await _lessonsCol
            .where('unitId', isEqualTo: altUnitId)
            .get();
      }

      List<LessonModel> baseLessons = [];
      if (snapshot.docs.isEmpty) {
        baseLessons = mockLessons.where((l) => l.unitId == unitId || l.unitId == altUnitId).toList();
      } else {
        baseLessons = snapshot.docs.map((d) => LessonModel.fromJson(d.data())).toList();
      }

      // Sort by lessonOrder
      baseLessons.sort((a, b) => a.lessonOrder.compareTo(b.lessonOrder));

      if (userId == null || userId.isEmpty) {
        return baseLessons;
      }

      // Merge with user progress locally
      final userProgress = await getUserProgress(userId);
      final userModel = await getUser(userId);
      final completedIds = userProgress?.completedLessonIds ?? [];
      final lessonStars = userProgress?.lessonStars ?? {};
      final currentLessonId = userModel?.currentLessonId;

      return baseLessons.map((lesson) {
        if (completedIds.contains(lesson.id)) {
          return lesson.copyWith(
            status: LessonStatus.completed,
            starsEarned: lessonStars[lesson.id] ?? 3,
          );
        } else if (lesson.id == currentLessonId) {
          return lesson.copyWith(status: LessonStatus.inProgress);
        } else if (lesson.lessonOrder == 1 || completedIds.isNotEmpty) {
          return lesson.copyWith(status: LessonStatus.available);
        } else {
          return lesson.copyWith(status: LessonStatus.locked);
        }
      }).toList();
    } catch (e) {
      return mockLessons.where((l) => l.unitId == unitId).toList();
    }
  }

  Future<List<ActivityModel>> getActivitiesForLesson(String lessonId) async {
    try {
      final snapshot = await _activitiesCol
          .where('lessonId', isEqualTo: lessonId)
          .get();
      if (snapshot.docs.isEmpty) {
        return mockLesson1Activities;
      }
      return snapshot.docs.map((d) => ActivityModel.fromJson(d.data())).toList();
    } catch (e) {
      return mockLesson1Activities;
    }
  }

  /// Updates learner progress in `user_progress/{userId}` WITHOUT modifying shared `lessons/{lessonId}`
  Future<void> updateLessonProgress(String userId, String lessonId, int starsEarned, {int totalLessonsCount = 12}) async {
    try {
      final currentProgress = await getUserProgress(userId) ?? UserProgressModel(userId: userId);
      final updatedCompletedIds = List<String>.from(currentProgress.completedLessonIds);
      if (!updatedCompletedIds.contains(lessonId)) {
        updatedCompletedIds.add(lessonId);
      }

      final updatedStars = Map<String, int>.from(currentProgress.lessonStars);
      final existingStars = updatedStars[lessonId] ?? 0;
      if (starsEarned > existingStars) {
        updatedStars[lessonId] = starsEarned;
      }

      final totalCompleted = updatedCompletedIds.length;
      final overallMastery = ((totalCompleted / (totalLessonsCount > 0 ? totalLessonsCount : 1)) * 100).round().clamp(0, 100);

      final updatedProgress = currentProgress.copyWith(
        userId: userId,
        completedLessonIds: updatedCompletedIds,
        lessonStars: updatedStars,
        totalLessonsCompleted: totalCompleted,
        overallMasteryPercentage: overallMastery.toDouble(),
      );

      await saveUserProgress(updatedProgress);
    } catch (e) {
      // Ignore offline errors
    }
  }

  // --- User Progress ---
  Future<UserProgressModel?> getUserProgress(String userId) async {
    try {
      final doc = await _progressCol.doc(userId).get();
      if (!doc.exists || doc.data() == null) return mockUserProgress.copyWith(userId: userId);
      final data = doc.data()!;
      data['userId'] = userId;
      return UserProgressModel.fromJson(data);
    } catch (e) {
      return mockUserProgress.copyWith(userId: userId);
    }
  }

  Future<void> saveUserProgress(UserProgressModel progress) async {
    try {
      await _progressCol.doc(progress.userId).set(progress.toJson(), SetOptions(merge: true));
    } catch (e) {
      // Ignore offline errors
    }
  }

  // --- Achievements ---
  Future<List<AchievementModel>> getAchievements(String userId) async {
    try {
      final snapshot = await _achievementsCol.get();
      final user = await getUser(userId);
      final userXp = user?.totalXp ?? 0;

      List<AchievementModel> baseAchievements = [];
      if (snapshot.docs.isEmpty) {
        baseAchievements = mockAchievementsList;
      } else {
        baseAchievements = snapshot.docs.map((d) => AchievementModel.fromJson(d.data())).toList();
      }

      // Compute local unlocked and progressRatio without overwriting global docs
      return baseAchievements.map((ach) {
        final isUnlocked = userXp >= ach.xpRequirement;
        final ratio = (userXp / (ach.xpRequirement > 0 ? ach.xpRequirement : 1)).clamp(0.0, 1.0);
        return ach.copyWith(
          isUnlocked: isUnlocked,
          progressRatio: ratio,
        );
      }).toList();
    } catch (e) {
      return mockAchievementsList;
    }
  }

  // --- Vocabulary / Dictionary ---
  Future<List<VocabularyModel>> searchVocabulary(String query) async {
    try {
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
    } catch (e) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return mockVocabularyList;
      return mockVocabularyList
          .where((w) =>
              w.headword.toLowerCase().contains(q) ||
              w.translation.toLowerCase().contains(q) ||
              w.category.toLowerCase().contains(q))
          .toList();
    }
  }

  Future<VocabularyModel?> getWordById(String id) async {
    try {
      final doc = await _vocabularyCol.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return VocabularyModel.fromJson(doc.data()!);
      }
    } catch (_) {}
    try {
      return mockVocabularyList.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- Database Seeding ---
  Future<void> seedCurriculumIfEmpty() async {
    try {
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
    } catch (_) {}
  }

  Future<void> seedVocabularyIfEmpty() async {
    try {
      final vocabCheck = await _vocabularyCol.limit(1).get();
      if (vocabCheck.docs.isEmpty) {
        final batch = _firestore.batch();
        for (final word in mockVocabularyList) {
          batch.set(_vocabularyCol.doc(word.id), word.toJson());
        }
        await batch.commit();
      }
    } catch (_) {}
  }
}
