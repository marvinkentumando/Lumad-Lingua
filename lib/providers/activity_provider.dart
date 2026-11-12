import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../repositories/lesson_repository.dart';
import 'lesson_provider.dart';
import 'auth_provider.dart';

class LessonSessionState {
  final String lessonId;
  final List<ActivityModel> activities;
  final int currentIndex;
  final int score;
  final bool isFinished;
  final int earnedXp;
  final int stars;

  const LessonSessionState({
    required this.lessonId,
    required this.activities,
    this.currentIndex = 0,
    this.score = 0,
    this.isFinished = false,
    this.earnedXp = 0,
    this.stars = 0,
  });

  ActivityModel? get currentActivity =>
      currentIndex < activities.length ? activities[currentIndex] : null;

  LessonSessionState copyWith({
    int? currentIndex,
    int? score,
    bool? isFinished,
    int? earnedXp,
    int? stars,
  }) {
    return LessonSessionState(
      lessonId: lessonId,
      activities: activities,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      isFinished: isFinished ?? this.isFinished,
      earnedXp: earnedXp ?? this.earnedXp,
      stars: stars ?? this.stars,
    );
  }
}

class LessonSessionNotifier extends AsyncNotifier<LessonSessionState> {
  late final LessonRepository _repository;

  @override
  Future<LessonSessionState> build() async {
    _repository = ref.watch(lessonRepositoryProvider);
    return const LessonSessionState(lessonId: '', activities: []);
  }

  Future<void> startLesson(String lessonId) async {
    state = const AsyncValue.loading();
    try {
      final activities = await _repository.getActivitiesForLesson(lessonId);
      state = AsyncValue.data(LessonSessionState(
        lessonId: lessonId,
        activities: activities,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void answerCurrentActivity(bool isCorrect, int activityXp) {
    if (state.value == null) return;
    final session = state.value!;
    final newScore = session.score + (isCorrect ? 1 : 0);
    final nextIndex = session.currentIndex + 1;

    if (nextIndex >= session.activities.length) {
      final total = session.activities.length;
      final percentage = total > 0 ? (newScore / total) * 100 : 0;
      int stars = 1;
      if (percentage >= 90) {
        stars = 3;
      } else if (percentage >= 75) {
        stars = 2;
      }

      final earnedXp = newScore * 10 + 30;

      _repository.updateLessonProgress(session.lessonId, stars);
      ref.read(authStateProvider.notifier).addXp(earnedXp);

      state = AsyncValue.data(session.copyWith(
        currentIndex: nextIndex,
        score: newScore,
        isFinished: true,
        earnedXp: earnedXp,
        stars: stars,
      ));
    } else {
      state = AsyncValue.data(session.copyWith(
        currentIndex: nextIndex,
        score: newScore,
      ));
    }
  }
}

final lessonSessionProvider =
    AsyncNotifierProvider<LessonSessionNotifier, LessonSessionState>(() {
  return LessonSessionNotifier();
});
