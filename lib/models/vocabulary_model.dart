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
  final String? pronunciation;
  final String? notes;

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
    this.pronunciation,
    this.notes,
  });

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    return VocabularyModel(
      id: json['id'] as String? ?? '',
      headword: json['mansakaWord'] as String? ?? json['headword'] as String? ?? '',
      translation: json['englishTranslation'] as String? ?? json['translation'] as String? ?? '',
      partOfSpeech: json['partOfSpeech'] as String? ?? 'noun',
      exampleSentence: json['exampleSentenceMansaka'] as String? ?? json['exampleSentence'] as String? ?? '',
      exampleTranslation: json['exampleSentenceEnglish'] as String? ?? json['exampleTranslation'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
      category: json['category'] as String? ?? 'General',
      relatedWords: (json['relatedWords'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      pronunciation: json['pronunciation'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headword': headword,
      'mansakaWord': headword,
      'translation': translation,
      'englishTranslation': translation,
      'partOfSpeech': partOfSpeech,
      'exampleSentence': exampleSentence,
      'exampleSentenceMansaka': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'exampleSentenceEnglish': exampleTranslation,
      'audioUrl': audioUrl,
      'category': category,
      'relatedWords': relatedWords,
      'pronunciation': pronunciation,
      'notes': notes,
    };
  }
}
