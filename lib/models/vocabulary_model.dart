class VocabularyExample {
  final String mansaka;
  final String english;

  const VocabularyExample({
    required this.mansaka,
    required this.english,
  });

  factory VocabularyExample.fromJson(Map<String, dynamic> json) {
    return VocabularyExample(
      mansaka: json['mansaka'] as String? ?? json['mansakaWord'] as String? ?? json['sentence'] as String? ?? json['mansakaSentence'] as String? ?? '',
      english: json['english'] as String? ?? json['englishTranslation'] as String? ?? json['translation'] as String? ?? json['englishSentence'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'mansaka': mansaka,
    'english': english,
  };
}

class VocabularyModel {
  final String id;
  final String headword;
  final String translation;
  final String partOfSpeech;
  final List<VocabularyExample> examples;
  final String? audioUrl;
  final String? pronunciation;
  final String? notes;

  const VocabularyModel({
    required this.id,
    required this.headword,
    required this.translation,
    required this.partOfSpeech,
    required this.examples,
    this.audioUrl,
    this.pronunciation,
    this.notes,
  });

  // Backward compatibility getters
  String get exampleSentence => examples.isNotEmpty ? examples.first.mansaka : '';
  String get exampleTranslation => examples.isNotEmpty ? examples.first.english : '';

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
    List<VocabularyExample> parsedExamples = [];

    // Extract from 'examples' array if available in Firebase
    final examplesList = json['examples'] as List<dynamic>?;
    if (examplesList != null && examplesList.isNotEmpty) {
      for (var item in examplesList) {
        if (item is Map<String, dynamic>) {
          parsedExamples.add(VocabularyExample.fromJson(item));
        } else if (item is String && item.isNotEmpty) {
          parsedExamples.add(VocabularyExample(mansaka: item, english: ''));
        }
      }
    }

    // Fallback to single example fields if examples list is empty
    if (parsedExamples.isEmpty) {
      String exMansaka = json['exampleSentenceMansaka'] as String? ?? json['exampleSentence'] as String? ?? '';
      String exEnglish = json['exampleSentenceEnglish'] as String? ?? json['exampleTranslation'] as String? ?? '';
      if (exMansaka.isNotEmpty || exEnglish.isNotEmpty) {
        parsedExamples.add(VocabularyExample(mansaka: exMansaka, english: exEnglish));
      }
    }

    // Resolve audioUrl from flat fields OR audioRecordings array
    String? resolvedAudioUrl = json['audioUrl'] as String? ?? json['audio_url'] as String? ?? json['audioPath'] as String?;
    final audioRecordings = json['audioRecordings'] as List<dynamic>?;
    if ((resolvedAudioUrl == null || resolvedAudioUrl.isEmpty) && audioRecordings != null && audioRecordings.isNotEmpty) {
      final primary = audioRecordings.firstWhere(
        (rec) => rec is Map<String, dynamic> && (rec['isPrimary'] == true || rec['is_primary'] == true),
        orElse: () => audioRecordings.first,
      );
      if (primary is Map<String, dynamic>) {
        resolvedAudioUrl = primary['path'] as String? ?? primary['url'] as String? ?? primary['audioUrl'] as String?;
      }
    }

    return VocabularyModel(
      id: json['id'] as String? ?? json['wordId'] as String? ?? '',
      headword: json['mansakaWord'] as String? ?? json['headword'] as String? ?? json['word'] as String? ?? json['term'] as String? ?? json['mansaka'] as String? ?? json['title'] as String? ?? '',
      translation: json['englishTranslation'] as String? ?? json['translation'] as String? ?? json['english'] as String? ?? json['meaning'] as String? ?? json['definition'] as String? ?? '',
      partOfSpeech: json['partOfSpeech'] as String? ?? json['part_of_speech'] as String? ?? json['pos'] as String? ?? 'Noun',
      examples: parsedExamples,
      audioUrl: resolvedAudioUrl,
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
      'examples': examples.map((e) => e.toJson()).toList(),
      'exampleSentence': exampleSentence,
      'exampleSentenceMansaka': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'exampleSentenceEnglish': exampleTranslation,
      'audioUrl': audioUrl,
      'pronunciation': pronunciation,
      'notes': notes,
    };
  }
}
