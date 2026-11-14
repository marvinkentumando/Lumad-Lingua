enum LessonStatus { locked, available, inProgress, completed }

class LessonFlashcard {
  final String id;
  final String mansaka;
  final String english;
  final String? pronunciation;
  final String? partOfSpeech;
  final String? exampleMansaka;
  final String? exampleEnglish;
  final String? audioPath;
  final String? vocabularyWordId;

  const LessonFlashcard({
    required this.id,
    required this.mansaka,
    required this.english,
    this.pronunciation,
    this.partOfSpeech,
    this.exampleMansaka,
    this.exampleEnglish,
    this.audioPath,
    this.vocabularyWordId,
  });

  factory LessonFlashcard.fromJson(Map<String, dynamic> json) {
    return LessonFlashcard(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      mansaka: json['mansaka'] as String? ?? '',
      english: json['english'] as String? ?? '',
      pronunciation: json['pronunciation'] as String?,
      partOfSpeech: json['partOfSpeech'] as String?,
      exampleMansaka: json['exampleMansaka'] as String?,
      exampleEnglish: json['exampleEnglish'] as String?,
      audioPath: json['audioPath'] as String?,
      vocabularyWordId: json['vocabularyWordId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mansaka': mansaka,
      'english': english,
      'pronunciation': pronunciation,
      'partOfSpeech': partOfSpeech,
      'exampleMansaka': exampleMansaka,
      'exampleEnglish': exampleEnglish,
      'audioPath': audioPath,
      'vocabularyWordId': vocabularyWordId,
    };
  }
}

class LessonModel {
  final String id;
  final String unitId;
  final String title;
  final String description;
  final int lessonOrder;
  final int xpReward;
  final LessonStatus status;
  final int starsEarned;
  final List<LessonFlashcard> flashcards;

  const LessonModel({
    required this.id,
    required this.unitId,
    required this.title,
    required this.description,
    required this.lessonOrder,
    this.xpReward = 30,
    this.status = LessonStatus.locked,
    this.starsEarned = 0,
    this.flashcards = const [],
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
    List<LessonFlashcard>? flashcards,
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
      flashcards: flashcards ?? this.flashcards,
    );
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    var rawFlashcards = json['flashcards'] as List<dynamic>? ?? [];
    List<LessonFlashcard> parsedFlashcards = rawFlashcards
        .map((f) => LessonFlashcard.fromJson(f as Map<String, dynamic>))
        .toList();

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
      flashcards: parsedFlashcards,
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
      'flashcards': flashcards.map((f) => f.toJson()).toList(),
    };
  }
}
