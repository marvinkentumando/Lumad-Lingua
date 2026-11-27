import '../models/vocabulary_model.dart';

final List<VocabularyModel> mockVocabularyList = [
  const VocabularyModel(
    id: 'word_1990_0001_s01_e01',
    headword: 'a-',
    translation: 'Active, past dependent tense, subject orientation.',
    partOfSpeech: 'Prefix',
    examples: [
      VocabularyExample(
        mansaka: 'Akono ako akaan sang manok?',
        english: 'When did I eat the chicken?',
      ),
    ],
    notes: 'Svelmoe & Svelmoe (1990), p. 1 · Check source · Compare entry boundary',
  ),
  const VocabularyModel(
    id: 'word_1990_0002_s01_e01',
    headword: '-a',
    translation: 'Active, imperative mode, object orientation.',
    partOfSpeech: 'Suffix',
    examples: [
      VocabularyExample(
        mansaka: 'Kaana yang manok.',
        english: 'Eat the chicken.',
      ),
    ],
    notes: 'Svelmoe & Svelmoe (1990), p. 1 · Visually transcribed',
  ),
  const VocabularyModel(
    id: 'word_1990_0003_s01_e01',
    headword: 'a- -Ø',
    translation: 'Active, future tense, associate orientation.',
    partOfSpeech: 'pref/suf comb',
    examples: [
      VocabularyExample(
        mansaka: 'Akamang ko tkaw sang manok.',
        english: 'I will get you a chicken.',
      ),
    ],
    notes: 'Svelmoe & Svelmoe (1990), p. 1 · Check source',
  ),
  const VocabularyModel(
    id: 'word_1990_0009_s01_e01',
    headword: 'à',
    translation: 'Expression of negative feeling.',
    partOfSpeech: 'Exclamation',
    examples: [
      VocabularyExample(
        mansaka: 'À! Dili ako mapanaw.',
        english: 'No! I will not go.',
      ),
    ],
    notes: 'Svelmoe & Svelmoe (1990), p. 1 · Visually transcribed',
  ),
  const VocabularyModel(
    id: 'word_1990_0010_s01_e01',
    headword: 'aadi',
    translation: 'Here.',
    partOfSpeech: 'Locative',
    examples: [
      VocabularyExample(
        mansaka: 'Aadi yang kanmo mga isu kanami.',
        english: 'Your children are here with us.',
      ),
      VocabularyExample(
        mansaka: 'Laong mo sa aadi yang kanak sanggut. Wain da sa?',
        english: 'You said my sickle was here. Where is it?',
      ),
    ],
    notes: 'Svelmoe & Svelmoe (1990), p. 1 · Visually transcribed',
  ),
  const VocabularyModel(
    id: 'word_1990_0011_s01_e01',
    headword: 'aadto',
    translation: 'There.',
    partOfSpeech: 'Locative',
    examples: [
      VocabularyExample(
        mansaka: 'Aadto kamayo si ina kagabi.',
        english: 'My mother was there with you (pl) yesterday.',
      ),
    ],
    notes: 'Svelmoe & Svelmoe (1990), p. 1 · Visually transcribed',
  ),
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
  ),
  const VocabularyModel(
    id: 'vocab_4',
    headword: 'Madyaw na allaw',
    translation: 'Good day',
    partOfSpeech: 'Phrase',
    examples: [
      VocabularyExample(
        mansaka: 'Madyaw na allaw sang kamayo hurot.',
        english: 'Good day to all of you.',
      ),
    ],
  ),
  const VocabularyModel(
    id: 'vocab_5',
    headword: 'Salamat',
    translation: 'Thank you',
    partOfSpeech: 'Phrase',
    examples: [
      VocabularyExample(
        mansaka: 'Salamat sang tabang mo.',
        english: 'Thank you for your help.',
      ),
    ],
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
  ),
];
