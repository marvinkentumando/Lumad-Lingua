class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int xpRequirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progressRatio;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    this.iconName = '🏆',
    this.xpRequirement = 100,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progressRatio = 0.0,
  });

  static const Map<String, String> legacyIconMap = {
    'Award': '🏆',
    'BookOpen': '📚',
    'Compass': '🧭',
    'Crown': '👑',
    'Feather': '🪶',
    'Flame': '🔥',
    'Milestone': '🎯',
    'Shield': '🛡️',
    'Star': '🌟',
    'Sunrise': '🌅',
    'Trophy': '🏆',
    'Volume2': '🗣️',
  };

  String get resolvedEmoji {
    if (legacyIconMap.containsKey(iconName)) {
      return legacyIconMap[iconName]!;
    }
    if (iconName.trim().isNotEmpty) {
      return iconName.trim();
    }
    return '🏆';
  }

  AchievementModel copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progressRatio,
    int? xpRequirement,
    String? iconName,
  }) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      iconName: iconName ?? this.iconName,
      xpRequirement: xpRequirement ?? this.xpRequirement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progressRatio: progressRatio ?? this.progressRatio,
    );
  }

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconName: json['iconName'] as String? ?? json['iconAsset'] as String? ?? '🏆',
      xpRequirement: json['xpRequirement'] as int? ?? 100,
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
      'iconName': iconName,
      'xpRequirement': xpRequirement,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progressRatio': progressRatio,
    };
  }
}
