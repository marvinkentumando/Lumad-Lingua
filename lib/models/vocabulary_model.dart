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

  /// Resolves Supabase storage paths, full HTTPS URLs, and local asset paths
  String? get resolvedAudioUrl {
    if (audioUrl == null || audioUrl!.isEmpty) return null;
    if (audioUrl!.startsWith('http://') || audioUrl!.startsWith('https://')) {
      return audioUrl;
    }
    String cleanPath = audioUrl!;
    if (cleanPath.startsWith('audio/')) {
      cleanPath = cleanPath.substring(6); // strip leading 'audio/'
    }
    return 'https://ovdwgowtnlujnbcyldkk.supabase.co/storage/v1/object/public/audio/$cleanPath';
  }

  factory VocabularyModel.fromJson(Map<String, dynamic> json) {
    // Extract first example from examples list if available
    String exMansaka = json['exampleSentenceMansaka'] as String? ?? json['exampleSentence'] as String? ?? '';
    String exEnglish = json['exampleSentenceEnglish'] as String? ?? json['exampleTranslation'] as String? ?? '';

    final examplesList = json['examples'] as List<dynamic>?;
    if (examplesList != null && examplesList.isNotEmpty) {
      final firstEx = examplesList.first;
      if (firstEx is Map<String, dynamic>) {
        if (exMansaka.isEmpty) exMansaka = firstEx['mansaka'] as String? ?? '';
        if (exEnglish.isEmpty) exEnglish = firstEx['english'] as String? ?? '';
      }
    }

    return VocabularyModel(
      id: json['id'] as String? ?? json['wordId'] as String? ?? '',
      headword: json['mansakaWord'] as String? ?? json['headword'] as String? ?? json['word'] as String? ?? json['term'] as String? ?? '',
      translation: json['englishTranslation'] as String? ?? json['translation'] as String? ?? json['english'] as String? ?? json['meaning'] as String? ?? '',
      partOfSpeech: json['partOfSpeech'] as String? ?? json['part_of_speech'] as String? ?? json['pos'] as String? ?? 'Noun',
      exampleSentence: exMansaka,
      exampleTranslation: exEnglish,
      audioUrl: json['audioUrl'] as String? ?? json['audio_url'] as String? ?? json['audioPath'] as String?,
      category: json['category'] as String? ?? json['topic'] as String? ?? json['domain'] as String? ?? 'General',
      relatedWords: (json['relatedWords'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      pronunciation: json['pronunciation'] as String? ?? json['phonetic'] as String? ?? json['ipa'] as String?,
      notes: json['notes'] as String? ?? json['note'] as String? ?? json['culturalNote'] as String?,
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
