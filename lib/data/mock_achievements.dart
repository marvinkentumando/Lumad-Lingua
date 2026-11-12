import '../models/achievement_model.dart';

final List<AchievementModel> mockAchievementsList = [
  AchievementModel(
    id: 'ach_first_lesson',
    title: 'First Step',
    description: 'Complete your first Mansaka lesson.',
    iconAsset: 'assets/icons/star.png',
    isUnlocked: true,
    unlockedAt: DateTime.now().subtract(const Duration(days: 2)),
    progressRatio: 1.0,
  ),
  AchievementModel(
    id: 'ach_streak_3',
    title: 'Consistency Champion',
    description: 'Maintain a 3-day learning streak.',
    iconAsset: 'assets/icons/fire.png',
    isUnlocked: true,
    unlockedAt: DateTime.now().subtract(const Duration(hours: 12)),
    progressRatio: 1.0,
  ),
  AchievementModel(
    id: 'ach_xp_500',
    title: 'XP Explorer',
    description: 'Reach 500 total XP points.',
    iconAsset: 'assets/icons/trophy.png',
    isUnlocked: false,
    progressRatio: 0.5, // 250 / 500
  ),
  AchievementModel(
    id: 'ach_unit_1',
    title: 'Fundamentals Master',
    description: 'Complete all lessons in Unit 1.',
    iconAsset: 'assets/icons/medal.png',
    isUnlocked: false,
    progressRatio: 0.33,
  ),
  AchievementModel(
    id: 'ach_pronunciation',
    title: 'Vocal Heritage',
    description: 'Record and practice 5 Mansaka pronunciations.',
    iconAsset: 'assets/icons/mic.png',
    isUnlocked: false,
    progressRatio: 0.2,
  ),
];
