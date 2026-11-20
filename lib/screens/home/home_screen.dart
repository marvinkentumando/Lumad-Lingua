import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/app_localizations.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/gamification/daily_quests_widget.dart';
import '../../widgets/gamification/lottie_streak_flame_widget.dart';
import '../../widgets/dictionary/word_of_the_day_card.dart';
import '../../providers/lesson_provider.dart';
import '../../models/lesson_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final isCustomActive = ref.watch(customThemeAccentProvider);
    final langCode = ref.watch(localizationProvider);

    final cardGradient = LinearGradient(
      colors: isCustomActive
          ? [const Color(0xFF7A1429), const Color(0xFFA91D3A), const Color(0xFF380912)]
          : [const Color(0xFF2E5A36), AppColors.forest500, Color(0xFF142917)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final cardBorder = Border.all(
      color: isCustomActive ? const Color(0xFF5C0E1E) : AppColors.forest700,
      width: 1.0,
    );
    final cardShadow = BoxShadow(
      color: isCustomActive ? const Color(0xFF1E0308) : const Color(0xFF0A140B),
      offset: const Offset(0, 5),
      blurRadius: 0,
    );

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Madyaw na allaw Greeting Banner Card with Dynamic Theme Accent Support
                SizedBox(
                  width: double.infinity,
                  height: 165,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: cardGradient,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: cardBorder,
                      boxShadow: [cardShadow],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 18,
                            bottom: 0,
                            top: 0,
                            child: SizedBox(
                              width: 170,
                              child: Image.asset(
                                'assets/images/lumad_waves.gif',
                                fit: BoxFit.contain,
                                alignment: Alignment.centerRight,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Icon(
                                    Icons.waving_hand,
                                    color: AppColors.gold500,
                                    size: 64,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, 145, AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  RegionalStrings.get(langCode, 'greeting'),
                                  style: AppTypography.bodyLarge.copyWith(color: AppColors.gold400),
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${user?.firstName ?? 'Learner'}!',
                                  style: AppTypography.h1ExtraBold.copyWith(color: Colors.white, fontSize: 24),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      'Level ${user?.level ?? 1} Learner',
                                      style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () => context.push('/streak'),
                                      child: LottieStreakFlameWidget(
                                        streakDays: user?.streakDays ?? 0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Word of the Day
                const WordOfTheDayCard(),
                const SizedBox(height: AppSpacing.lg),

                // Enhanced Continue Learning Section Card with Dynamic Theme Accent Support
                Text('Continue Learning', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                _ContinueLearningCard(
                  cardGradient: cardGradient,
                  cardBorder: cardBorder,
                  cardShadow: cardShadow,
                  isCustomActive: isCustomActive,
                ),
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

                // Lingua Duels Arena Card (With Dual-Tone Gold Gradient & 3D Shadow Lip)
                GestureDetector(
                  onTap: () => context.push('/arena'),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), AppColors.gold500, Color(0xFFFFA000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.gold700, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFC78C00),
                          offset: Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
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
                ),
                const SizedBox(height: AppSpacing.lg),

                // Daily Quests & Challenges
                const DailyQuestsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueLearningCard extends ConsumerWidget {
  final Gradient cardGradient;
  final Border cardBorder;
  final BoxShadow cardShadow;
  final bool isCustomActive;

  const _ContinueLearningCard({
    required this.cardGradient,
    required this.cardBorder,
    required this.cardShadow,
    required this.isCustomActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsProvider);

    return unitsAsync.when(
      data: (units) {
        if (units.isEmpty) {
          return const SizedBox.shrink();
        }
        final activeUnit = units.first;
        final lessonsAsync = ref.watch(unitLessonsProvider(activeUnit.id));

        return lessonsAsync.when(
          data: (lessons) {
            if (lessons.isEmpty) {
              return const SizedBox.shrink();
            }
            final activeLesson = lessons.firstWhere(
              (l) => l.status == LessonStatus.inProgress || l.status == LessonStatus.available,
              orElse: () => lessons.first,
            );
            final completedCount = lessons.where((l) => l.status == LessonStatus.completed).length;
            final progressRatio = lessons.isNotEmpty ? completedCount / lessons.length : 0.0;

            return Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: cardGradient,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: cardBorder,
                boxShadow: [cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          activeUnit.title.toUpperCase(),
                          style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold500,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          'Lesson ${activeLesson.lessonOrder} of ${lessons.length}',
                          style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    activeLesson.title,
                    style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      backgroundColor: isCustomActive ? const Color(0xFF5C0E1E) : AppColors.forest700,
                      color: AppColors.gold500,
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BrandButton(
                    text: 'Continue Lesson',
                    icon: Icons.play_arrow_rounded,
                    type: BrandButtonType.gold,
                    onPressed: () {
                      context.push('/lesson/${activeLesson.id}');
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: cardGradient,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: const Center(child: CircularProgressIndicator(color: AppColors.gold500)),
          ),
          error: (err, stack) => const SizedBox.shrink(),
        );
      },
      loading: () => Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: cardGradient,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Center(child: CircularProgressIndicator(color: AppColors.gold500)),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
