class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progressRatio;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progressRatio = 0.0,
  });

  AchievementModel copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progressRatio,
  }) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      iconAsset: iconAsset,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progressRatio: progressRatio ?? this.progressRatio,
    );
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconAsset: json['iconAsset'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt'] as String) : null,
      progressRatio: (json['progressRatio'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconAsset': iconAsset,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progressRatio': progressRatio,
    };
  }
}
