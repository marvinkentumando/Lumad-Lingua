import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../utils/constants.dart';
import '../../models/daily_quest_model.dart';
import '../../models/route_args.dart';
import '../../providers/daily_quests_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/gamification/level_up_dialog.dart';

class LessonResultScreen extends ConsumerStatefulWidget {
  final LessonResultArgs args;

  LessonResultScreen({
    super.key,
    LessonResultArgs? args,
    Map<String, dynamic>? resultData,
  }) : args = args ?? LessonResultArgs.fromMap(resultData);

  @override
  ConsumerState<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends ConsumerState<LessonResultScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyQuestsProvider.notifier).incrementProgress(QuestType.lesson);

      final authNotifier = ref.read(authStateProvider.notifier);
      final newLevel = authNotifier.pendingLevelUp;
      if (newLevel != null && mounted) {
        authNotifier.clearPendingLevelUp();
        showLevelUpDialog(context, newLevel: newLevel);
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earnedXp = widget.args.earnedXp;
    final stars = widget.args.stars;
    final crystalsEarned = stars * 10;

    return Scaffold(
      body: LumadBackground(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Trophy Celebration
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.gold500.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold500, width: 2.5),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 72,
                        color: AppColors.gold500,
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.08, 1.08), duration: 1000.ms)
                     .shimmer(duration: 1800.ms, color: Colors.white),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Madyaw! Great Job!',
                      style: AppTypography.h1ExtraBold.copyWith(color: AppColors.textColor(context)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You successfully completed the lesson and preserved Mansaka heritage!',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.subtitleColor(context)),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Star Rating Animation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          size: 42,
                          color: AppColors.gold500,
                        ).animate().scale(delay: Duration(milliseconds: index * 200), duration: 400.ms, curve: Curves.elasticOut),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 3D Lifted Stat Counter Cards
                    BrandCard(
                      backgroundColor: AppColors.gold500,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.bolt, color: AppColors.forest900, size: 28),
                              const SizedBox(height: 4),
                              Text('+$earnedXp', style: AppTypography.displayNumber.copyWith(color: AppColors.forest900, fontSize: 22)),
                              Text('XP Earned', style: AppTypography.caption.copyWith(color: AppColors.forest800, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(height: 40, width: 1, color: AppColors.forest900.withValues(alpha: 0.2)),
                          Column(
                            children: [
                              const Icon(Icons.diamond, color: AppColors.forest900, size: 28),
                              const SizedBox(height: 4),
                              Text('+$crystalsEarned', style: AppTypography.displayNumber.copyWith(color: AppColors.forest900, fontSize: 22)),
                              Text('Crystals', style: AppTypography.caption.copyWith(color: AppColors.forest800, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Clear Call-to-Action Flow
                    BrandButton(
                      text: 'Continue Learning',
                      icon: Icons.arrow_forward_rounded,
                      type: BrandButtonType.gold,
                      onPressed: () => context.go('/learn'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    BrandButton(
                      text: 'Review Drills',
                      icon: Icons.replay_rounded,
                      type: BrandButtonType.secondary,
                      onPressed: () {
                        final lessonId = widget.args.lessonId;
                        if (lessonId != null && lessonId.isNotEmpty) {
                          context.go('/lesson/$lessonId/drills');
                        } else {
                          context.go('/learn');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.gold500,
                AppColors.forestGreen,
                Colors.amber,
                Colors.orange,
                Colors.greenAccent,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
