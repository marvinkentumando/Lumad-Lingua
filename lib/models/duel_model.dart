class DuelQuestion {
  final String id;
  final String questionText;
  final String targetMansaka;
  final String targetEnglish;
  final List<String> options;
  final int correctOptionIndex;

  const DuelQuestion({
    required this.id,
    required this.questionText,
    required this.targetMansaka,
    required this.targetEnglish,
    required this.options,
    required this.correctOptionIndex,
  });

  factory DuelQuestion.fromJson(Map<String, dynamic> json) {
    return DuelQuestion(
      id: json['id'] as String? ?? '',
      questionText: json['questionText'] as String? ?? '',
      targetMansaka: json['targetMansaka'] as String? ?? '',
      targetEnglish: json['targetEnglish'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      correctOptionIndex: json['correctOptionIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'targetMansaka': targetMansaka,
      'targetEnglish': targetEnglish,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }
}

class DuelSessionModel {
  final String id;
  final String player1Id;
  final String player1Name;
  final int player1Score;
  final int player1Hp;
  final String? player2Id;
  final String? player2Name;
  final int player2Score;
  final int player2Hp;
  final String status; // 'waiting', 'active', 'completed'
  final int currentRound;
  final List<DuelQuestion> questions;
  final String? winnerId;
  final DateTime? createdAt;

  const DuelSessionModel({
    required this.id,
    required this.player1Id,
    required this.player1Name,
    this.player1Score = 0,
    this.player1Hp = 100,
    this.player2Id,
    this.player2Name,
    this.player2Score = 0,
    this.player2Hp = 100,
    this.status = 'waiting',
    this.currentRound = 0,
    this.questions = const [],
    this.winnerId,
    this.createdAt,
  });

  factory DuelSessionModel.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? [];
    return DuelSessionModel(
      id: json['id'] as String? ?? '',
      player1Id: json['player1Id'] as String? ?? '',
      player1Name: json['player1Name'] as String? ?? 'Player 1',
      player1Score: json['player1Score'] as int? ?? 0,
      player1Hp: json['player1Hp'] as int? ?? 100,
      player2Id: json['player2Id'] as String?,
      player2Name: json['player2Name'] as String?,
      player2Score: json['player2Score'] as int? ?? 0,
      player2Hp: json['player2Hp'] as int? ?? 100,
      status: json['status'] as String? ?? 'waiting',
      currentRound: json['currentRound'] as int? ?? 0,
      questions: rawQuestions.map((q) => DuelQuestion.fromJson(Map<String, dynamic>.from(q as Map))).toList(),
      winnerId: json['winnerId'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player1Id': player1Id,
      'player1Name': player1Name,
      'player1Score': player1Score,
      'player1Hp': player1Hp,
      'player2Id': player2Id,
      'player2Name': player2Name,
      'player2Score': player2Score,
      'player2Hp': player2Hp,
      'status': status,
      'currentRound': currentRound,
      'questions': questions.map((q) => q.toJson()).toList(),
      'winnerId': winnerId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
