import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';

class LessonResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const LessonResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final earnedXp = resultData['earnedXp'] as int? ?? 30;
    final stars = resultData['stars'] as int? ?? 3;
    final crystalsEarned = stars * 10;

    return Scaffold(
      body: LumadBackground(
        child: SafeArea(
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
                  onPressed: () => context.go('/learn'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
