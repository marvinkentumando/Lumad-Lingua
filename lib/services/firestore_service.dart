import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/learning_unit_model.dart';
import '../models/lesson_model.dart';
import '../models/activity_model.dart';
import '../models/progress_model.dart';
import '../models/achievement_model.dart';
import '../models/vocabulary_model.dart';
import '../data/mock_vocabulary.dart';
import '../data/mock_achievements.dart';
import 'offline_sync_service.dart';
import 'local_cache_service.dart';

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

  // --- Units & Lessons (Directly from Firebase) ---
  Future<List<LearningUnitModel>> getUnits({String? userId}) async {
    try {
      final snapshot = await _unitsCol.get();
      var units = snapshot.docs.map((d) => LearningUnitModel.fromJson(d.data(), documentId: d.id)).toList();
      units.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));

      if (userId == null || userId.isEmpty) {
        return units.map((u) => u.copyWith(isUnlocked: u.unitNumber == 1)).toList();
      }

      List<LearningUnitModel> evaluated = [];
      for (int i = 0; i < units.length; i++) {
        final unit = units[i];
        bool unlocked = unit.unitNumber == 1;
        if (!unlocked && i > 0) {
          final prevUnit = units[i - 1];
          final prevLessons = await getLessonsForUnitInternal(prevUnit.id, userId: userId);
          unlocked = prevLessons.isNotEmpty && prevLessons.every((l) => l.status == LessonStatus.completed);
        }
        evaluated.add(unit.copyWith(isUnlocked: unlocked));
      }
      return evaluated;
    } catch (e) {
      return [];
    }
  }

  Future<List<LessonModel>> getLessonsForUnitInternal(String unitId, {String? userId}) async {
    try {
      final altUnitId = unitId.contains('_') && !unitId.contains('_0')
          ? unitId.replaceFirst('unit_', 'unit_0')
          : (unitId.contains('_0') ? unitId.replaceFirst('unit_0', 'unit_') : unitId);

      final snapshot = await _lessonsCol.get();
      List<LessonModel> baseLessons = snapshot.docs
          .map((d) => LessonModel.fromJson(d.data(), documentId: d.id))
          .where((l) => l.unitId == unitId || l.unitId == altUnitId || l.unitId == unitId.replaceAll('unit_', 'unit_0'))
          .toList();

      // Sort by lessonOrder
      baseLessons.sort((a, b) => a.lessonOrder.compareTo(b.lessonOrder));

      if (userId == null || userId.isEmpty) {
        return baseLessons.map((lesson) {
          final lessonIndex = baseLessons.indexOf(lesson);
          if (lessonIndex == 0) {
            return lesson.copyWith(status: LessonStatus.available);
          }
          return lesson.copyWith(status: LessonStatus.locked);
        }).toList();
      }

      // Merge with user progress locally
      final userProgress = await getUserProgress(userId);
      final userModel = await getUser(userId);
      final completedIds = userProgress?.completedLessonIds ?? [];
      final lessonStars = userProgress?.lessonStars ?? {};
      final currentLessonId = userModel?.currentLessonId;

      return baseLessons.map((lesson) {
        final lessonIndex = baseLessons.indexOf(lesson);
        if (completedIds.contains(lesson.id)) {
          return lesson.copyWith(
            status: LessonStatus.completed,
            starsEarned: lessonStars[lesson.id] ?? 3,
          );
        } else if (lesson.id == currentLessonId) {
          return lesson.copyWith(status: LessonStatus.inProgress);
        } else if (lessonIndex == 0) {
          return lesson.copyWith(status: LessonStatus.available);
        } else {
          final prevLesson = baseLessons[lessonIndex - 1];
          if (completedIds.contains(prevLesson.id)) {
            return lesson.copyWith(status: LessonStatus.available);
          } else {
            return lesson.copyWith(status: LessonStatus.locked);
          }
        }
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<LessonModel>> getLessonsForUnit(String unitId, {String? userId}) async {
    if (userId != null && userId.isNotEmpty) {
      final units = await getUnits(userId: userId);
      final unit = units.firstWhere((u) => u.id == unitId || u.unitNumber.toString() == unitId.replaceAll('unit_', ''), orElse: () => units.first);
      if (!unit.isUnlocked) {
        final base = await getLessonsForUnitInternal(unitId, userId: userId);
        return base.map((l) => l.copyWith(status: LessonStatus.locked)).toList();
      }
    }
    return await getLessonsForUnitInternal(unitId, userId: userId);
  }

  Future<List<ActivityModel>> getActivitiesForLesson(String lessonId) async {
    try {
      final snapshot = await _activitiesCol
          .where('lessonId', isEqualTo: lessonId)
          .get();
      return snapshot.docs.map((d) => ActivityModel.fromJson(d.data(), documentId: d.id)).toList();
    } catch (e) {
      return [];
    }
  }

  // --- Real-Time Streams for Units, Lessons, and Activities (.snapshots()) ---
  Stream<List<LearningUnitModel>> watchUnits({String? userId}) async* {
    yield* _unitsCol.snapshots().asyncMap((snapshot) async {
      var units = snapshot.docs.map((d) => LearningUnitModel.fromJson(d.data(), documentId: d.id)).toList();
      units.sort((a, b) => a.unitNumber.compareTo(b.unitNumber));

      if (userId == null || userId.isEmpty) {
        return units.map((u) => u.copyWith(isUnlocked: u.unitNumber == 1)).toList();
      }

      final evaluated = await Future.wait(units.asMap().entries.map((entry) async {
        final i = entry.key;
        final unit = entry.value;
        if (unit.unitNumber == 1) {
          return unit.copyWith(isUnlocked: true);
        }
        final prevUnit = units[i - 1];
        final prevLessons = await getLessonsForUnitInternal(prevUnit.id, userId: userId);
        final unlocked = prevLessons.isNotEmpty && prevLessons.every((l) => l.status == LessonStatus.completed);
        return unit.copyWith(isUnlocked: unlocked);
      }));

      return evaluated;
    });
  }

  Stream<List<LessonModel>> watchLessonsForUnit(String unitId, {String? userId}) async* {
    yield* _lessonsCol.snapshots().asyncMap((snapshot) async {
      return await getLessonsForUnit(unitId, userId: userId);
    });
  }

  Stream<List<ActivityModel>> watchActivitiesForLesson(String lessonId) {
    try {
      return _activitiesCol.where('lessonId', isEqualTo: lessonId).snapshots().map((snapshot) {
        return snapshot.docs.map((d) => ActivityModel.fromJson(d.data(), documentId: d.id)).toList();
      });
    } catch (_) {
      return Stream.value([]);
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

      await _progressCol.doc(userId).set(updatedProgress.toJson(), SetOptions(merge: true));
    } catch (e) {
      // Queue offline if network fails
      await OfflineSyncService().queueAction('complete_lesson', {
        'userId': userId,
        'lessonId': lessonId,
        'xpEarned': 50,
      });
    }
  }

  Future<void> addXp(String userId, int xp) async {
    try {
      final userDoc = await _usersCol.doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        final currentXp = (userDoc.data()!['xp'] as num?)?.toInt() ?? 0;
        await _usersCol.doc(userId).update({'xp': currentXp + xp});
      }
    } catch (e) {
      await OfflineSyncService().queueAction('update_xp', {
        'userId': userId,
        'xp': xp,
      });
    }
  }

  Future<void> updateStreak(String userId, int streakDays) async {
    try {
      await _usersCol.doc(userId).update({'streakDays': streakDays});
    } catch (e) {
      await OfflineSyncService().queueAction('update_streak', {
        'userId': userId,
        'streakDays': streakDays,
      });
    }
  }

  // --- User Progress ---
  Future<UserProgressModel?> getUserProgress(String userId) async {
    try {
      final doc = await _progressCol.doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserProgressModel.fromJson(doc.data()!);
    } catch (e) {
      return null;
    }
  }

  Stream<UserProgressModel?> watchUserProgress(String userId) {
    try {
      return _progressCol.doc(userId).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return UserProgressModel.fromJson(doc.data()!);
      });
    } catch (_) {
      return Stream.value(null);
    }
  }

  // --- Achievements ---
  Future<List<AchievementModel>> getAchievements([String? userId]) async {
    try {
      final snapshot = await _achievementsCol.get();
      if (snapshot.docs.isEmpty) {
        return mockAchievementsList;
      }
      return snapshot.docs.map((d) => AchievementModel.fromJson(d.data())).toList();
    } catch (e) {
      return mockAchievementsList;
    }
  }

  Stream<List<AchievementModel>> watchAchievements() {
    try {
      return _achievementsCol.snapshots().map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return mockAchievementsList;
        }
        return snapshot.docs.map((d) => AchievementModel.fromJson(d.data())).toList();
      });
    } catch (_) {
      return Stream.value(mockAchievementsList);
    }
  }

  // --- Vocabulary ---
  Future<List<VocabularyModel>> getVocabulary({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cached = LocalCacheService().getCachedJsonList('vocabulary');
        if (cached != null && cached.isNotEmpty) {
          return cached.map((json) => VocabularyModel.fromJson(json)).toList();
        }
      }

      final snapshot = await _vocabularyCol.get().timeout(const Duration(seconds: 4));
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((d) {
          final data = Map<String, dynamic>.from(d.data());
          data['id'] = d.id;
          return VocabularyModel.fromJson(data);
        }).toList();

        await LocalCacheService().cacheJsonList('vocabulary', list.map((w) => w.toJson()).toList());
        return list;
      }
      return mockVocabularyList;
    } catch (e) {
      debugPrint('Firestore getVocabulary error: $e');
      final cached = LocalCacheService().getCachedJsonList('vocabulary');
      if (cached != null && cached.isNotEmpty) {
        return cached.map((json) => VocabularyModel.fromJson(json)).toList();
      }
      return mockVocabularyList;
    }
  }

  Future<List<VocabularyModel>> searchVocabulary(String query) async {
    try {
      final list = await getVocabulary();
      if (query.isEmpty) return list;
      final q = query.toLowerCase();
      return list.where((w) => w.headword.toLowerCase().contains(q) || w.translation.toLowerCase().contains(q)).toList();
    } catch (e) {
      debugPrint('Firestore searchVocabulary error: $e');
      var list = mockVocabularyList;
      if (query.isEmpty) return list;
      final q = query.toLowerCase();
      return list.where((w) => w.headword.toLowerCase().contains(q) || w.translation.toLowerCase().contains(q)).toList();
    }
  }

  Stream<List<VocabularyModel>> watchLessonsVocabulary() {
    try {
      return _vocabularyCol.snapshots().map((snapshot) {
        return snapshot.docs.map((d) {
          final data = Map<String, dynamic>.from(d.data());
          data['id'] = d.id;
          return VocabularyModel.fromJson(data);
        }).toList();
      });
    } catch (_) {
      return Stream.value(mockVocabularyList);
    }
  }

  Future<VocabularyModel?> getWordById(String id) async {
    try {
      final doc = await _vocabularyCol.doc(id).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return VocabularyModel.fromJson(data);
    } catch (e) {
      debugPrint('Firestore getWordById error: $e');
      return null;
    }
  }
}
