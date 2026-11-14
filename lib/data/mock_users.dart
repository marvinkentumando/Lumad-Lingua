import '../models/user_model.dart';

final mockCurrentUser = UserModel(
  id: 'user_1',
  name: 'Lumad Learner',
  email: 'learner@lumadlingua.com',
  totalXp: 250,
  level: 3,
  streakDays: 3,
  crystals: 150,
  currentUnitId: 'unit_1',
  currentLessonId: 'lesson_1_2',
);

final List<UserModel> mockGlobalLeaderboard = [
  const UserModel(
    id: 'user_top_1',
    name: 'Dayang Mansaka',
    email: 'dayang@lumad.ph',
    totalXp: 1250,
    level: 13,
    streakDays: 24,
    crystals: 340,
  ),
  const UserModel(
    id: 'user_top_2',
    name: 'Datu Datuin',
    email: 'datu@lumad.ph',
    totalXp: 980,
    level: 10,
    streakDays: 18,
    crystals: 220,
  ),
  const UserModel(
    id: 'user_top_3',
    name: 'Diwa Lumad',
    email: 'diwa@lumad.ph',
    totalXp: 720,
    level: 8,
    streakDays: 12,
    crystals: 180,
  ),
  mockCurrentUser,
  const UserModel(
    id: 'user_top_5',
    name: 'Bayanihan Learner',
    email: 'bayan@lumad.ph',
    totalXp: 180,
    level: 2,
    streakDays: 2,
    crystals: 100,
  ),
];
