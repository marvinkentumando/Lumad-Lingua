import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
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

    final xp = user?.totalXp ?? 250;
    final crystals = user?.crystals ?? 150;

    // Progressive level calculation using LevelHelper
    final levelProgress = LevelHelper.getLevelProgress(xp);
    final level = levelProgress['level'] ?? 3;
    final xpInCurrentLevel = levelProgress['currentLevelXp'] ?? 50;
    final xpNeededForNextLevel = levelProgress['xpNeededForNextLevel'] ?? 150;
    final progress = (xpInCurrentLevel / (xpNeededForNextLevel > 0 ? xpNeededForNextLevel : 1)).clamp(0.0, 1.0);

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
                  title: 'XP & Level Dashboard',
                  subtitle: 'Track your total experience points and level progression',
                ),
                const SizedBox(height: AppSpacing.xs),

                // XP & Level Hero Card
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Level $level Learner',
                              style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 22),
                            ),
                          ),
                          XPBadge(xp: xp),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Level Progress (Progressive Curve)', style: AppTypography.body.copyWith(color: AppColors.creamBorder)),
                          Text('$xpInCurrentLevel / $xpNeededForNextLevel XP', style: AppTypography.xpValue.copyWith(color: AppColors.gold400)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.forest700,
                          color: AppColors.gold500,
                          minHeight: 14,
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

                // Crystal Currency Banner
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
