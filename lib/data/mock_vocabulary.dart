import '../models/vocabulary_model.dart';

final List<VocabularyModel> mockVocabularyList = [
  const VocabularyModel(
    id: 'vocab_1',
    headword: 'Madyaw na masurom',
    translation: 'Good morning',
    partOfSpeech: 'Phrase',
    examples: [
      VocabularyExample(
        mansaka: 'Madyaw na masurom sang kanami pag-eskwela.',
        english: 'Good morning to our school.',
      ),
    ],
    category: 'Greetings',
    relatedWords: ['Madyaw', 'Masurom', 'Gabila'],
  ),
  const VocabularyModel(
    id: 'vocab_2',
    headword: 'Madyaw na gabila',
    translation: 'Good afternoon',
    partOfSpeech: 'Phrase',
    examples: [
      VocabularyExample(
        mansaka: 'Madyaw na gabila sang kanimo, amigo.',
        english: 'Good afternoon to you, my friend.',
      ),
    ],
    category: 'Greetings',
    relatedWords: ['Madyaw', 'Gabila'],
  ),
  const VocabularyModel(
    id: 'vocab_3',
    headword: 'Madyaw na gabi',
    translation: 'Good evening',
    partOfSpeech: 'Phrase',
    examples: [
      VocabularyExample(
        mansaka: 'Madyaw na gabi sang panimalay.',
        english: 'Good evening to the household.',
      ),
    ],
    category: 'Greetings',
    relatedWords: ['Madyaw', 'Gabi'],
  ),
  const VocabularyModel(
    id: 'vocab_4',
    headword: 'Madyaw na aras dose',
    translation: 'Good noon',
    partOfSpeech: 'Phrase',
    examples: [
      VocabularyExample(
        mansaka: 'Madyaw na aras dose sang kamayo hurot.',
        english: 'Good noon to all of you.',
      ),
    ],
    category: 'Greetings',
    relatedWords: ['Madyaw', 'Aras dose'],
  ),
  const VocabularyModel(
    id: 'vocab_5',
    headword: 'Madyaw',
    translation: 'Good / Fine',
    partOfSpeech: 'Adjective',
    examples: [
      VocabularyExample(
        mansaka: 'Madyaw ya kanami pagsugod.',
        english: 'Our start is good.',
      ),
    ],
    category: 'General',
    relatedWords: ['Madyaw na masurom'],
  ),
  const VocabularyModel(
    id: 'vocab_6',
    headword: 'Banwa',
    translation: 'Community / Village',
    partOfSpeech: 'Noun',
    examples: [
      VocabularyExample(
        mansaka: 'Madyaw sang kanami banwa.',
        english: 'Peace in our community.',
      ),
    ],
    category: 'Society',
    relatedWords: ['Sakop'],
  ),
];
