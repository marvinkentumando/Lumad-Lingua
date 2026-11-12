import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_unit_model.dart';
import '../models/lesson_model.dart';
import '../repositories/lesson_repository.dart';
import '../repositories/firestore_lesson_repository.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return FirestoreLessonRepository();
});

final unitsProvider = FutureProvider<List<LearningUnitModel>>((ref) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getUnits();
});

final unitLessonsProvider = FutureProvider.family<List<LessonModel>, String>((ref, unitId) async {
  final repo = ref.watch(lessonRepositoryProvider);
  return repo.getLessonsForUnit(unitId);
});
