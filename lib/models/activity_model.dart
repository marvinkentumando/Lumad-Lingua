enum ActivityType {
  multipleChoice,
  wordMatching,
  listeningExercise,
  wordArrangement,
  flashcard,
  pronunciationPractice,
}

class MatchingPair {
  final String mansaka;
  final String english;

  const MatchingPair({required this.mansaka, required this.english});

  factory MatchingPair.fromJson(Map<String, dynamic> json) {
    return MatchingPair(
      mansaka: json['mansaka'] as String,
      english: json['english'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mansaka': mansaka,
      'english': english,
    };
  }
}

class ActivityModel {
  final String id;
  final String lessonId;
  final ActivityType type;
  final String questionText;
  final String? audioAssetPath;
  final String? targetMansaka;
  final String? targetEnglish;
  final List<String>? options;
  final int? correctOptionIndex;
  final List<MatchingPair>? matchingPairs;
  final List<String>? wordsToArrange;
  final List<String>? correctArrangement;
  final int xpReward;

  const ActivityModel({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.questionText,
    this.audioAssetPath,
    this.targetMansaka,
    this.targetEnglish,
    this.options,
    this.correctOptionIndex,
    this.matchingPairs,
    this.wordsToArrange,
    this.correctArrangement,
    this.xpReward = 10,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.multipleChoice,
      ),
      questionText: json['questionText'] as String,
      audioAssetPath: json['audioAssetPath'] as String?,
      targetMansaka: json['targetMansaka'] as String?,
      targetEnglish: json['targetEnglish'] as String?,
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      correctOptionIndex: json['correctOptionIndex'] as int?,
      matchingPairs: (json['matchingPairs'] as List<dynamic>?)
          ?.map((e) => MatchingPair.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      wordsToArrange: (json['wordsToArrange'] as List<dynamic>?)?.map((e) => e as String).toList(),
      correctArrangement: (json['correctArrangement'] as List<dynamic>?)?.map((e) => e as String).toList(),
      xpReward: json['xpReward'] as int? ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'type': type.name,
      'questionText': questionText,
      'audioAssetPath': audioAssetPath,
      'targetMansaka': targetMansaka,
      'targetEnglish': targetEnglish,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'matchingPairs': matchingPairs?.map((e) => e.toJson()).toList(),
      'wordsToArrange': wordsToArrange,
      'correctArrangement': correctArrangement,
      'xpReward': xpReward,
    };
  }
}
