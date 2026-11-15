import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/achievement_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../common/brand_card.dart';

class AchievementBadgeWidget extends ConsumerWidget {
  final AchievementModel achievement;

  const AchievementBadgeWidget({super.key, required this.achievement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final totalXp = user?.totalXp ?? 250;

    final isUnlocked = achievement.isUnlocked || totalXp >= achievement.xpRequirement;
    final xpNeeded = achievement.xpRequirement - totalXp;
    final progress = achievement.progressRatio > 0
        ? achievement.progressRatio
        : (totalXp / achievement.xpRequirement).clamp(0.0, 1.0);

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.65,
      child: BrandCard(
        backgroundColor: isUnlocked ? AppColors.gold500 : AppColors.forest100,
        border: Border.all(
          color: isUnlocked ? AppColors.gold700 : AppColors.creamBorder,
          width: isUnlocked ? 1.5 : 1.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Emoji Medallion Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isUnlocked ? AppColors.forest900.withValues(alpha: 0.1) : AppColors.forest300.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? AppColors.forest900 : AppColors.creamBorder,
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    achievement.resolvedEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  if (!isUnlocked)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.forest700,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, color: Colors.white, size: 10),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              achievement.title,
              style: AppTypography.lessonTitle.copyWith(
                color: isUnlocked ? AppColors.forest900 : AppColors.creamText2,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Text(
                achievement.description,
                style: AppTypography.caption.copyWith(
                  color: isUnlocked ? AppColors.forest800 : AppColors.creamText2,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.forest900,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text('UNLOCKED', style: AppTypography.labelBold.copyWith(color: AppColors.gold500, fontSize: 9)),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$xpNeeded XP needed', style: AppTypography.xpValue.copyWith(fontSize: 10, color: AppColors.gold800)),
                  Text('${(progress * 100).toInt()}%', style: AppTypography.caption.copyWith(fontSize: 10)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.creamBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold500),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
