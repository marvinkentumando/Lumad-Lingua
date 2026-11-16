import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../common/brand_card.dart';
import 'xp_badge.dart';

class XpLevelCard extends StatelessWidget {
  final int totalXp;

  const XpLevelCard({super.key, required this.totalXp});

  @override
  Widget build(BuildContext context) {
    final levelProgress = LevelHelper.getLevelProgress(totalXp);
    final level = levelProgress['level'] ?? 3;
    final xpInCurrentLevel = levelProgress['currentLevelXp'] ?? 50;
    final xpNeededForNextLevel = levelProgress['xpNeededForNextLevel'] ?? 150;
    final progress = (xpInCurrentLevel / (xpNeededForNextLevel > 0 ? xpNeededForNextLevel : 1)).clamp(0.0, 1.0);

    return BrandCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Level $level Learner',
                  style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 20),
                ),
              ),
              XPBadge(xp: totalXp),
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
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.forest700,
              color: AppColors.gold500,
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Earn ${xpNeededForNextLevel - xpInCurrentLevel} more XP to reach Level ${level + 1}!',
            style: AppTypography.caption.copyWith(color: AppColors.gold300, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
