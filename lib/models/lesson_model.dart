enum LessonStatus { locked, available, inProgress, completed }

class LessonModel {
  final String id;
  final String unitId;
  final String title;
  final String description;
  final int lessonOrder;
  final int xpReward;
  final LessonStatus status;
  final int starsEarned;

  const LessonModel({
    required this.id,
    required this.unitId,
    required this.title,
    required this.description,
    required this.lessonOrder,
    this.xpReward = 30,
    this.status = LessonStatus.locked,
    this.starsEarned = 0,
  });

  LessonModel copyWith({
    String? id,
    String? unitId,
    String? title,
    String? description,
    int? lessonOrder,
    int? xpReward,
    LessonStatus? status,
    int? starsEarned,
  }) {
    return LessonModel(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      title: title ?? this.title,
      description: description ?? this.description,
      lessonOrder: lessonOrder ?? this.lessonOrder,
      xpReward: xpReward ?? this.xpReward,
      status: status ?? this.status,
      starsEarned: starsEarned ?? this.starsEarned,
    );
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      unitId: json['unitId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      lessonOrder: json['lessonOrder'] as int,
      xpReward: json['xpReward'] as int? ?? 30,
      status: LessonStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LessonStatus.locked,
      ),
      starsEarned: json['starsEarned'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unitId': unitId,
      'title': title,
      'description': description,
      'lessonOrder': lessonOrder,
      'xpReward': xpReward,
      'status': status.name,
      'starsEarned': starsEarned,
    };
  }
}
