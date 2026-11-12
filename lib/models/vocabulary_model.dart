class VocabularyModel {
  final String id;
  final String headword;
  final String translation;
  final String partOfSpeech;
  final String exampleSentence;
  final String exampleTranslation;
  final String? audioUrl;
  final String category;
  final List<String> relatedWords;

  const VocabularyModel({
    required this.id,
    required this.headword,
    required this.translation,
    required this.partOfSpeech,
    required this.exampleSentence,
    required this.exampleTranslation,
    this.audioUrl,
    required this.category,
    this.relatedWords = const [],
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'] as String,
      headword: json['headword'] as String,
      translation: json['translation'] as String,
      partOfSpeech: json['partOfSpeech'] as String? ?? 'noun',
      exampleSentence: json['exampleSentence'] as String? ?? '',
      exampleTranslation: json['exampleTranslation'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
      category: json['category'] as String? ?? 'General',
      relatedWords: (json['relatedWords'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headword': headword,
      'translation': translation,
      'partOfSpeech': partOfSpeech,
      'exampleSentence': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'audioUrl': audioUrl,
      'category': category,
      'relatedWords': relatedWords,
    };
  }
}
