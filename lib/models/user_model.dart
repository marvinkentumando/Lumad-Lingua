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
  });

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
    };
  }
}
