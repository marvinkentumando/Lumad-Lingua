class UserProgressModel {
  final String userId;
  final Map<String, int> lessonStars; // lessonId -> stars
  final List<String> completedLessonIds;
  final int totalLessonsCompleted;
  final double overallMasteryPercentage;

  const UserProgressModel({
    required this.userId,
    this.lessonStars = const {},
    this.completedLessonIds = const [],
    this.totalLessonsCompleted = 0,
    this.overallMasteryPercentage = 0.0,
  });

  UserProgressModel copyWith({
    String? userId,
    Map<String, int>? lessonStars,
    List<String>? completedLessonIds,
    int? totalLessonsCompleted,
    double? overallMasteryPercentage,
  }) {
    return UserProgressModel(
      userId: userId ?? this.userId,
      lessonStars: lessonStars ?? this.lessonStars,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      totalLessonsCompleted: totalLessonsCompleted ?? this.totalLessonsCompleted,
      overallMasteryPercentage: overallMasteryPercentage ?? this.overallMasteryPercentage,
    );
  }

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    final rawStars = json['lessonStars'] as Map<String, dynamic>? ?? {};
    final Map<String, int> starsMap = rawStars.map((key, value) => MapEntry(key, (value as num).toInt()));
    return UserProgressModel(
      userId: json['userId'] as String? ?? '',
      lessonStars: starsMap,
      completedLessonIds: (json['completedLessonIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      totalLessonsCompleted: json['totalLessonsCompleted'] as int? ?? 0,
      overallMasteryPercentage: (json['overallMasteryPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'lessonStars': lessonStars,
      'completedLessonIds': completedLessonIds,
      'totalLessonsCompleted': totalLessonsCompleted,
      'overallMasteryPercentage': overallMasteryPercentage,
    };
  }
}
