import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_logo_emblem.dart';
import '../../widgets/gamification/xp_badge.dart';
import '../../widgets/gamification/streak_indicator.dart';
import '../../widgets/gamification/daily_quests_widget.dart';
import '../../widgets/dictionary/word_of_the_day_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const LumadLogoEmblem(size: 44, borderRadius: 12),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Madyaw na masurom!',
                            style: AppTypography.caption.copyWith(color: AppColors.creamText2),
                          ),
                          Text(
                            user?.name ?? 'Lumad Learner',
                            style: AppTypography.h3.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      StreakIndicator(streakDays: user?.streakDays ?? 3),
                      const SizedBox(width: 8),
                      XPBadge(xp: user?.totalXp ?? 250),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Level Banner
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.forest500, AppColors.forest300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.gold500, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.forest700,
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: const Icon(Icons.school, color: AppColors.gold500, size: 32),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level ${user?.level ?? 3} Learner',
                            style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 20),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Keep practicing daily to unlock new Mansaka units!',
                            style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Continue Learning Section
              Text('Continue Learning', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'UNIT 1: MANSAKA FUNDAMENTALS',
                          style: AppTypography.labelBold.copyWith(color: AppColors.gold500, fontSize: 11),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold100,
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: Text(
                            'Lesson 2 of 3',
                            style: AppTypography.labelBold.copyWith(color: AppColors.gold800, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Lesson 2: Basic Expressions',
                      style: AppTypography.lessonTitle.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Express gratitude, courtesy, and daily phrases.',
                      style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    BrandButton(
                      text: 'Continue Lesson',
                      icon: Icons.play_arrow,
                      type: BrandButtonType.primary,
                      onPressed: () {
                        context.push('/lesson/lesson_1_2');
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Daily Quests & Challenges
              const DailyQuestsWidget(),
              const SizedBox(height: AppSpacing.lg),

              // Quick Practice & Tools
              Text('Quick Practice & Tools', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      onTap: () => context.push('/pronunciation'),
                      child: Column(
                        children: [
                          const Icon(Icons.mic, size: 36, color: AppColors.gold500),
                          const SizedBox(height: 8),
                          Text(
                            'Pronunciation',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Audio Practice',
                            style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppCard(
                      onTap: () => context.push('/sentiment'),
                      child: Column(
                        children: [
                          const Icon(Icons.analytics_outlined, size: 36, color: AppColors.gold500),
                          const SizedBox(height: 8),
                          Text(
                            'Sentiment Lab',
                            textAlign: TextAlign.center,
                            style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Research Tool',
                            style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Crystal Shop Card
              AppCard(
                onTap: () => context.push('/shop'),
                backgroundColor: AppColors.gold500,
                border: Border.all(color: AppColors.gold700, width: 1.5),
                child: DefaultTextStyle(
                  style: const TextStyle(color: AppColors.forest900),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, size: 40, color: AppColors.forest900),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Crystal Shop',
                              style: AppTypography.h3.copyWith(color: AppColors.forest900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Spend crystals on streak freezes, boosters, and avatars!',
                              style: AppTypography.body.copyWith(color: AppColors.forest800),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.forest900),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Lingua Duels Arena Card
              AppCard(
                onTap: () => context.push('/arena'),
                backgroundColor: AppColors.gold500,
                border: Border.all(color: AppColors.gold700, width: 1.5),
                child: DefaultTextStyle(
                  style: const TextStyle(color: AppColors.forest900),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, size: 40, color: AppColors.forest900),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lingua Duels Arena (PvP)',
                              style: AppTypography.h3.copyWith(color: AppColors.forest900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Compete in rapid-fire trivia duels & win +150 XP +25 Crystals!',
                              style: AppTypography.body.copyWith(color: AppColors.forest800),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.forest900),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Word of the Day
              const WordOfTheDayCard(),
              const SizedBox(height: AppSpacing.lg),

              // Daily Challenge Card
              AppCard(
                backgroundColor: AppColors.gold100,
                border: Border.all(color: AppColors.gold300, width: 1.5),
                child: DefaultTextStyle(
                  style: const TextStyle(color: AppColors.forest900),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, size: 40, color: AppColors.gold800),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Challenge',
                              style: AppTypography.h3.copyWith(color: AppColors.forest900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Review 5 Mansaka greetings to earn 20 Bonus XP.',
                              style: AppTypography.body.copyWith(color: AppColors.forest800),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
