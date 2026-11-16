import '../models/learning_unit_model.dart';
import '../models/lesson_model.dart';
import '../models/activity_model.dart';
import '../data/mock_lessons.dart';

abstract class LessonRepository {
  Future<List<LearningUnitModel>> getUnits({String? userId});
  Future<List<LessonModel>> getLessonsForUnit(String unitId, {String? userId});
  Future<List<ActivityModel>> getActivitiesForLesson(String lessonId);
  Future<void> updateLessonProgress(String lessonId, int starsEarned, {String? userId});

  Stream<List<LearningUnitModel>> watchUnits({String? userId});
  Stream<List<LessonModel>> watchLessonsForUnit(String unitId, {String? userId});
  Stream<List<ActivityModel>> watchActivitiesForLesson(String lessonId);
}

class MockLessonRepository implements LessonRepository {
  final List<LessonModel> _lessons = List.from(mockLessons);

  @override
  Future<List<LearningUnitModel>> getUnits({String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockUnits;
  }

  @override
  Future<List<LessonModel>> getLessonsForUnit(String unitId, {String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _lessons.where((l) => l.unitId == unitId).toList();
  }

  @override
  Future<List<ActivityModel>> getActivitiesForLesson(String lessonId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return mockLesson1Activities;
  }

  @override
  Future<void> updateLessonProgress(String lessonId, int starsEarned, {String? userId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _lessons.indexWhere((l) => l.id == lessonId);
    if (index != -1) {
      _lessons[index] = _lessons[index].copyWith(
        status: LessonStatus.completed,
        starsEarned: starsEarned,
      );
      if (index + 1 < _lessons.length) {
        if (_lessons[index + 1].status == LessonStatus.locked) {
          _lessons[index + 1] = _lessons[index + 1].copyWith(
            status: LessonStatus.available,
          );
        }
      }
    }
  }

  @override
  Stream<List<LearningUnitModel>> watchUnits({String? userId}) {
    return Stream.value(mockUnits..sort((a, b) => a.unitNumber.compareTo(b.unitNumber)));
  }

  @override
  Stream<List<LessonModel>> watchLessonsForUnit(String unitId, {String? userId}) {
    return Stream.value(_lessons.where((l) => l.unitId == unitId).toList()..sort((a, b) => a.lessonOrder.compareTo(b.lessonOrder)));
  }

  @override
  Stream<List<ActivityModel>> watchActivitiesForLesson(String lessonId) {
    return Stream.value(mockLesson1Activities);
  }
}
