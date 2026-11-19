class UserModel {
  final String id;
  final String name;
  final String email;
  final int totalXp;
  final int level;
  final int streakDays;
  final int crystals;
  final String currentUnitId;
  final String currentLessonId;
  final String? avatarUrl;
  final List<String> inventory;
  final int streakFreezes;
  final String? equippedFrame;
  final String? equippedBanner;
  final DateTime? lastActiveDate;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.totalXp = 0,
    this.level = 1,
    this.streakDays = 0,
    this.crystals = 150,
    this.currentUnitId = 'unit_1',
    this.currentLessonId = 'lesson_1_2',
    this.avatarUrl,
    this.inventory = const [],
    this.streakFreezes = 0,
    this.equippedFrame,
    this.equippedBanner,
    this.lastActiveDate,
  });

  /// Returns the first word/name of the user's display name for greetings (e.g., "Juan" from "Juan Dela Cruz").
  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Learner';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? totalXp,
    int? level,
    int? streakDays,
    int? crystals,
    String? currentUnitId,
    String? currentLessonId,
    String? avatarUrl,
    List<String>? inventory,
    int? streakFreezes,
    String? equippedFrame,
    String? equippedBanner,
    DateTime? lastActiveDate,
    bool clearEquippedFrame = false,
    bool clearEquippedBanner = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      streakDays: streakDays ?? this.streakDays,
      crystals: crystals ?? this.crystals,
      currentUnitId: currentUnitId ?? this.currentUnitId,
      currentLessonId: currentLessonId ?? this.currentLessonId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      inventory: inventory ?? this.inventory,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      equippedFrame: clearEquippedFrame ? null : (equippedFrame ?? this.equippedFrame),
      equippedBanner: clearEquippedBanner ? null : (equippedBanner ?? this.equippedBanner),
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      totalXp: json['totalXp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      streakDays: json['streakDays'] as int? ?? 0,
      crystals: json['crystals'] as int? ?? 150,
      currentUnitId: json['currentUnitId'] as String? ?? 'unit_1',
      currentLessonId: json['currentLessonId'] as String? ?? 'lesson_1_1',
      avatarUrl: json['avatarUrl'] as String?,
      inventory: (json['inventory'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      streakFreezes: json['streakFreezes'] as int? ?? 0,
      equippedFrame: json['equippedFrame'] as String?,
      equippedBanner: json['equippedBanner'] as String?,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.tryParse(json['lastActiveDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'totalXp': totalXp,
      'level': level,
      'streakDays': streakDays,
      'crystals': crystals,
      'currentUnitId': currentUnitId,
      'currentLessonId': currentLessonId,
      'avatarUrl': avatarUrl,
      'inventory': inventory,
      'streakFreezes': streakFreezes,
      'equippedFrame': equippedFrame,
      'equippedBanner': equippedBanner,
      'lastActiveDate': lastActiveDate?.toIso8601String(),
    };
  }
}
