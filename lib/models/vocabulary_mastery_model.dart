enum VocabularyState {
  newWord,
  learning,
  practicing,
  mastered,
}

class VocabularyMasteryModel {
  final String wordId;
  final VocabularyState state;
  final int reviewCount;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewDueAt;

  const VocabularyMasteryModel({
    required this.wordId,
    this.state = VocabularyState.newWord,
    this.reviewCount = 0,
    this.lastReviewedAt,
    this.nextReviewDueAt,
  });

  bool get isDueForReview {
    if (nextReviewDueAt == null) return true;
    return DateTime.now().isAfter(nextReviewDueAt!);
  }

  VocabularyMasteryModel copyWith({
    VocabularyState? state,
    int? reviewCount,
    DateTime? lastReviewedAt,
    DateTime? nextReviewDueAt,
  }) {
    return VocabularyMasteryModel(
      wordId: wordId,
      state: state ?? this.state,
      reviewCount: reviewCount ?? this.reviewCount,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewDueAt: nextReviewDueAt ?? this.nextReviewDueAt,
    );
  }

  factory VocabularyMasteryModel.fromJson(Map<String, dynamic> json) {
    return VocabularyMasteryModel(
      wordId: json['wordId'] as String? ?? '',
      state: VocabularyState.values.firstWhere(
        (e) => e.name == json['state'],
        orElse: () => VocabularyState.newWord,
      ),
      reviewCount: json['reviewCount'] as int? ?? 0,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.tryParse(json['lastReviewedAt'] as String)
          : null,
      nextReviewDueAt: json['nextReviewDueAt'] != null
          ? DateTime.tryParse(json['nextReviewDueAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'state': state.name,
      'reviewCount': reviewCount,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'nextReviewDueAt': nextReviewDueAt?.toIso8601String(),
    };
  }
}
