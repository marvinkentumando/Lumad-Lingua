import '../models/progress_model.dart';

final mockUserProgress = UserProgressModel(
  userId: 'user_1',
  lessonStars: {
    'lesson_1_1': 3,
  },
  completedLessonIds: ['lesson_1_1'],
  totalLessonsCompleted: 1,
  overallMasteryPercentage: 0.15,
);
