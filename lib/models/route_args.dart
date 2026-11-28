/// Strongly-typed argument classes for GoRouter route navigation
library;

class ClassroomDashboardArgs {
  final String classId;
  final Map<String, dynamic> classroomData;

  const ClassroomDashboardArgs({
    required this.classId,
    required this.classroomData,
  });

  factory ClassroomDashboardArgs.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const ClassroomDashboardArgs(classId: '', classroomData: {});
    }
    return ClassroomDashboardArgs(
      classId: map['classId'] as String? ?? '',
      classroomData: (map['classroomData'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'classroomData': classroomData,
    };
  }
}

class DuelBattleArgs {
  final String sessionId;

  const DuelBattleArgs({
    required this.sessionId,
  });

  factory DuelBattleArgs.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const DuelBattleArgs(sessionId: '');
    }
    return DuelBattleArgs(
      sessionId: map['sessionId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
    };
  }
}

class LessonResultArgs {
  final String? lessonId;
  final int earnedXp;
  final int stars;
  final int score;
  final int total;

  const LessonResultArgs({
    this.lessonId,
    this.earnedXp = 30,
    this.stars = 3,
    this.score = 0,
    this.total = 0,
  });

  factory LessonResultArgs.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const LessonResultArgs();
    }
    return LessonResultArgs(
      lessonId: map['lessonId'] as String?,
      earnedXp: (map['earnedXp'] as num?)?.toInt() ?? 30,
      stars: (map['stars'] as num?)?.toInt() ?? 3,
      score: (map['score'] as num?)?.toInt() ?? 0,
      total: (map['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'earnedXp': earnedXp,
      'stars': stars,
      'score': score,
      'total': total,
    };
  }
}
