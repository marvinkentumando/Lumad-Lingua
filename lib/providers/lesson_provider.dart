import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_unit_model.dart';
import '../models/lesson_model.dart';
import '../repositories/lesson_repository.dart';
import '../repositories/firestore_lesson_repository.dart';
import 'auth_provider.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return FirestoreLessonRepository();
});

final unitsProvider = StreamProvider<List<LearningUnitModel>>((ref) {
  final repo = ref.watch(lessonRepositoryProvider);
  final userId = ref.watch(authStateProvider.select((user) => user.value?.id));
  return repo.watchUnits(userId: userId);
});

final unitLessonsProvider = StreamProvider.family<List<LessonModel>, String>((ref, unitId) {
  final repo = ref.watch(lessonRepositoryProvider);
  final userId = ref.watch(authStateProvider.select((user) => user.value?.id));
  return repo.watchLessonsForUnit(unitId, userId: userId);
});
