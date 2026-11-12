import '../models/learning_unit_model.dart';
import '../models/lesson_model.dart';
import '../models/activity_model.dart';

final List<LearningUnitModel> mockUnits = [
  const LearningUnitModel(
    id: 'unit_1',
    unitNumber: 1,
    title: 'Unit 1: Mansaka Fundamentals',
    description: 'Master basic greetings, expressions, and introductions in Mansaka.',
    category: 'Fundamentals',
    isUnlocked: true,
  ),
  const LearningUnitModel(
    id: 'unit_2',
    unitNumber: 2,
    title: 'Unit 2: Everyday Vocabulary',
    description: 'Learn numbers, colors, and family member names.',
    category: 'Vocabulary',
    isUnlocked: true,
  ),
  const LearningUnitModel(
    id: 'unit_3',
    unitNumber: 3,
    title: 'Unit 3: Daily Conversations',
    description: 'Practice asking questions and describing everyday activities.',
    category: 'Conversation',
    isUnlocked: false,
  ),
  const LearningUnitModel(
    id: 'unit_4',
    unitNumber: 4,
    title: 'Unit 4: Practical Communication',
    description: 'Build complete sentences and develop listening comprehension.',
    category: 'Communication',
    isUnlocked: false,
  ),
];

final List<LessonModel> mockLessons = [
  // Unit 1 Lessons
  const LessonModel(
    id: 'lesson_1_1',
    unitId: 'unit_1',
    title: 'Greetings',
    description: 'Learn common time-of-day greetings in Mansaka.',
    lessonOrder: 1,
    xpReward: 30,
    status: LessonStatus.completed,
    starsEarned: 3,
  ),
  const LessonModel(
    id: 'lesson_1_2',
    unitId: 'unit_1',
    title: 'Basic Expressions',
    description: 'Express gratitude, courtesy, and daily phrases.',
    lessonOrder: 2,
    xpReward: 30,
    status: LessonStatus.inProgress,
    starsEarned: 0,
  ),
  const LessonModel(
    id: 'lesson_1_3',
    unitId: 'unit_1',
    title: 'Introducing Yourself',
    description: 'State your name and ask others about themselves.',
    lessonOrder: 3,
    xpReward: 35,
    status: LessonStatus.available,
    starsEarned: 0,
  ),

  // Unit 2 Lessons
  const LessonModel(
    id: 'lesson_2_1',
    unitId: 'unit_2',
    title: 'Numbers (Mga Numero)',
    description: 'Count from one to ten in Mansaka.',
    lessonOrder: 1,
    xpReward: 30,
    status: LessonStatus.available,
    starsEarned: 0,
  ),
  const LessonModel(
    id: 'lesson_2_2',
    unitId: 'unit_2',
    title: 'Colors (Mga Kolor)',
    description: 'Identify common colors around you.',
    lessonOrder: 2,
    xpReward: 30,
    status: LessonStatus.locked,
    starsEarned: 0,
  ),
  const LessonModel(
    id: 'lesson_2_3',
    unitId: 'unit_2',
    title: 'Family Members',
    description: 'Learn terms for mother, father, sibling, and elders.',
    lessonOrder: 3,
    xpReward: 35,
    status: LessonStatus.locked,
    starsEarned: 0,
  ),

  // Unit 3 Lessons
  const LessonModel(
    id: 'lesson_3_1',
    unitId: 'unit_3',
    title: 'Asking Questions',
    description: 'Who, what, where, when, and why in Mansaka.',
    lessonOrder: 1,
    xpReward: 40,
    status: LessonStatus.locked,
    starsEarned: 0,
  ),
  const LessonModel(
    id: 'lesson_3_2',
    unitId: 'unit_3',
    title: 'Daily Activities',
    description: 'Talk about eating, walking, studying, and working.',
    lessonOrder: 2,
    xpReward: 40,
    status: LessonStatus.locked,
    starsEarned: 0,
  ),

  // Unit 4 Lessons
  const LessonModel(
    id: 'lesson_4_1',
    unitId: 'unit_4',
    title: 'Sentence Construction',
    description: 'Combine vocabulary into complete Mansaka sentences.',
    lessonOrder: 1,
    xpReward: 50,
    status: LessonStatus.locked,
    starsEarned: 0,
  ),
];

final List<ActivityModel> mockLesson1Activities = [
  const ActivityModel(
    id: 'act_1_1',
    lessonId: 'lesson_1_1',
    type: ActivityType.multipleChoice,
    questionText: 'What is the Mansaka translation for "Good morning"?',
    targetEnglish: 'Good morning',
    options: [
      'Madyaw na masurom',
      'Madyaw na gabila',
      'Madyaw na gabi',
      'Madyaw na aras dose'
    ],
    correctOptionIndex: 0,
    xpReward: 10,
  ),
  const ActivityModel(
    id: 'act_1_2',
    lessonId: 'lesson_1_1',
    type: ActivityType.wordMatching,
    questionText: 'Match the Mansaka greetings with their English meanings:',
    matchingPairs: [
      MatchingPair(mansaka: 'Madyaw na masurom', english: 'Good morning'),
      MatchingPair(mansaka: 'Madyaw na gabila', english: 'Good afternoon'),
      MatchingPair(mansaka: 'Madyaw na gabi', english: 'Good evening'),
      MatchingPair(mansaka: 'Madyaw na aras dose', english: 'Good noon'),
    ],
    xpReward: 10,
  ),
  const ActivityModel(
    id: 'act_1_3',
    lessonId: 'lesson_1_1',
    type: ActivityType.listeningExercise,
    questionText: 'Listen to the audio and select the phrase you hear:',
    targetMansaka: 'Madyaw na gabila',
    options: [
      'Madyaw na masurom',
      'Madyaw na gabila',
      'Madyaw na gabi',
      'Kadyaw sang karaw'
    ],
    correctOptionIndex: 1,
    xpReward: 15,
  ),
  const ActivityModel(
    id: 'act_1_4',
    lessonId: 'lesson_1_1',
    type: ActivityType.wordArrangement,
    questionText: 'Arrange the words to form "Good evening":',
    wordsToArrange: ['gabi', 'na', 'Madyaw'],
    correctArrangement: ['Madyaw', 'na', 'gabi'],
    xpReward: 10,
  ),
  const ActivityModel(
    id: 'act_1_5',
    lessonId: 'lesson_1_1',
    type: ActivityType.pronunciationPractice,
    questionText: 'Practice saying "Madyaw na masurom" clearly:',
    targetMansaka: 'Madyaw na masurom',
    targetEnglish: 'Good morning',
    xpReward: 15,
  ),
];
