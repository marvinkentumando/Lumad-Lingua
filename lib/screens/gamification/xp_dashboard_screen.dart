import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../utils/level_helper.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/gamification/xp_badge.dart';

class XpDashboardScreen extends ConsumerWidget {
  const XpDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    final xp = user?.totalXp ?? 0;
    final crystals = user?.crystals ?? 0;

    // Progressive level calculation using LevelHelper
    final levelProgress = LevelHelper.getLevelProgress(xp);
    final level = levelProgress['level'] ?? 1;
    final xpInCurrentLevel = levelProgress['currentLevelXp'] ?? 0;
    final xpNeededForNextLevel = levelProgress['xpNeededForNextLevel'] ?? 100;
    final progress = (xpInCurrentLevel / (xpNeededForNextLevel > 0 ? xpNeededForNextLevel : 1)).clamp(0.0, 1.0);

    // Student-centered rank titles
    String studentRank = 'Beginning Learner 📚';
    if (level >= 11) {
      studentRank = 'Mansaka Scholar 🎓';
    } else if (level >= 8) {
      studentRank = 'Fluent Achiever 🏆';
    } else if (level >= 5) {
      studentRank = 'Confident Communicator 🌟';
    } else if (level >= 3) {
      studentRank = 'Growing Speaker 💬';
    }

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(
                  title: 'XP & Level',
                  centerTitle: true,
                ),
                const SizedBox(height: AppSpacing.xs),

                // XP & Level Hero Card with Animated Progress Fill
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Level $level Learner',
                                  style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 22),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  studentRank,
                                  style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          XPBadge(xp: xp),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Level Progress', style: AppTypography.body.copyWith(color: AppColors.creamBorder)),
                          Text('$xpInCurrentLevel / $xpNeededForNextLevel XP', style: AppTypography.xpValue.copyWith(color: AppColors.gold400)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: progress),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          builder: (context, animatedProgress, child) {
                            return LinearProgressIndicator(
                              value: animatedProgress,
                              backgroundColor: AppColors.forest700,
                              color: AppColors.gold500,
                              minHeight: 14,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Earn ${xpNeededForNextLevel - xpInCurrentLevel} more XP to reach Level ${level + 1}!',
                        style: AppTypography.caption.copyWith(color: AppColors.gold300, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Crystal Currency & Shop Banner
                BrandCard(
                  backgroundColor: AppColors.gold500,
                  border: Border.all(color: AppColors.gold700, width: 1.5),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: AppColors.forest900),
                    child: Row(
                      children: [
                        const Icon(Icons.diamond, color: AppColors.forest900, size: 40),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$crystals Crystals Available',
                                style: AppTypography.h3.copyWith(color: AppColors.forest900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Use crystals in the shop to buy streak freezes, boosters, and avatars.',
                                style: AppTypography.body.copyWith(color: AppColors.forest800),
                              ),
                            ],
                          ),
                        ),
                        BrandButton(
                          text: 'Shop',
                          type: BrandButtonType.primary,
                          onPressed: () => context.push('/shop'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Active XP Boosters Banner
                BrandCard(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold500),
                        ),
                        child: const Icon(Icons.bolt, color: AppColors.gold500, size: 28),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('2x XP Boosters', style: AppTypography.h3.copyWith(color: Colors.white)),
                            Text('Double your earned XP during practice lessons', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                          ],
                        ),
                      ),
                      BrandButton(
                        text: 'Get Boost',
                        type: BrandButtonType.gold,
                        onPressed: () => context.push('/shop'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Level Milestone Unlocks Roadmap
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Level Unlocks Roadmap', style: AppTypography.h3.copyWith(color: Colors.white)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Progress through levels to unlock exclusive features and badges.', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                      const SizedBox(height: AppSpacing.md),
                      _buildLevelMilestoneItem(context, 3, 'Growing Speaker Title', '💬 Unlocks community badge', level),
                      const Divider(color: AppColors.forest700, height: 20),
                      _buildLevelMilestoneItem(context, 5, 'Lingua Duels Arena', '⚡ Unlocks PvP Trivia Battles', level),
                      const Divider(color: AppColors.forest700, height: 20),
                      _buildLevelMilestoneItem(context, 8, 'Fluent Achiever Title', '🏆 Unlocks golden profile emblem', level),
                      const Divider(color: AppColors.forest700, height: 20),
                      _buildLevelMilestoneItem(context, 11, 'Mansaka Scholar Regalia', '🎓 Unlocks ancestral scholar crown', level),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Recent XP Activity History
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent XP Activity', style: AppTypography.h3.copyWith(color: Colors.white)),
                      const SizedBox(height: AppSpacing.md),
                      _buildXpActivityRow(context, '+30 XP', 'Lesson Completed', 'Lesson 2: Basic Expressions'),
                      const Divider(color: AppColors.forest700, height: 20),
                      _buildXpActivityRow(context, '+100 XP', 'Unit Chest Claimed', 'Unit 1 Reward Chest'),
                      const Divider(color: AppColors.forest700, height: 20),
                      _buildXpActivityRow(context, '+50 XP', 'Daily Quest Completed', 'Complete 1 Pronunciation Trial'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelMilestoneItem(BuildContext context, int targetLevel, String title, String subtitle, int currentLevel) {
    final isUnlocked = currentLevel >= targetLevel;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isUnlocked ? AppColors.gold500 : AppColors.forest700,
            shape: BoxShape.circle,
            border: Border.all(color: isUnlocked ? AppColors.gold700 : AppColors.forest500, width: 2),
          ),
          child: Center(
            child: Icon(
              isUnlocked ? Icons.check_rounded : Icons.lock_rounded,
              color: isUnlocked ? AppColors.forest900 : AppColors.creamText3,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Level $targetLevel: $title', style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 13)),
                  if (isUnlocked)
                    Text('UNLOCKED', style: AppTypography.labelBold.copyWith(color: AppColors.semanticGreen, fontSize: 10))
                  else
                    Text('LOCKED', style: AppTypography.labelBold.copyWith(color: AppColors.creamText3, fontSize: 10)),
                ],
              ),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.creamBorder, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildXpActivityRow(BuildContext context, String xpText, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold500.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: AppColors.gold500),
          ),
          child: Text(
            xpText,
            style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 12),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.creamBorder, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
