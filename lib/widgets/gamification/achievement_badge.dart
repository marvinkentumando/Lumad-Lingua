import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/achievement_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

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
      opacity: isUnlocked ? 1.0 : 0.45,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.cardColor(context) : AppColors.softGray,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isUnlocked ? AppColors.gold500 : AppColors.border,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Emoji Medallion Container
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isUnlocked ? AppColors.gold500.withValues(alpha: 0.2) : AppColors.lockedGray.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? AppColors.gold500 : AppColors.disabled,
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    achievement.resolvedEmoji,
                    style: const TextStyle(fontSize: 30),
                  ),
                  if (!isUnlocked)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.creamText,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock, color: Colors.white, size: 12),
                      ),
                    ),
                ],
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
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor(context),
                          ),
                        ),
                      ),
                      if (isUnlocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.semanticGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: const Text(
                            'Unlocked',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.semanticGreen),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subtitleColor(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!isUnlocked) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$xpNeeded XP needed',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold500),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(fontSize: 11, color: AppColors.subtitleColor(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.progressTrack,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold500),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
