import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/achievement_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../utils/constants.dart';
import '../common/brand_card.dart';
import '../common/brand_button.dart';

class AchievementBadgeWidget extends ConsumerWidget {
  final AchievementModel achievement;

  const AchievementBadgeWidget({super.key, required this.achievement});

  void _showBadgeDetailsDialog(BuildContext context, bool isUnlocked, double progress, int xpNeeded) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isUnlocked ? AppColors.gold500 : Colors.grey).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(achievement.resolvedEmoji, style: const TextStyle(fontSize: 32)),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.title, style: AppTypography.h3),
                  Text(
                    isUnlocked ? 'Unlocked Milestone' : 'Locked Milestone',
                    style: AppTypography.caption.copyWith(color: isUnlocked ? AppColors.semanticGreen : AppColors.terracotta, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description, style: AppTypography.bodyLarge),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardColor(context),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.creamBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('XP Requirement', style: AppTypography.labelBold),
                      Text('${achievement.xpRequirement} XP', style: AppTypography.xpValue),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (isUnlocked) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status', style: AppTypography.labelBold),
                        Text(achievement.unlockedAt != null ? 'Unlocked on ${achievement.unlockedAt!.toLocal().toString().split(' ')[0]}' : 'Successfully Unlocked', style: AppTypography.caption.copyWith(color: AppColors.semanticGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Progress', style: AppTypography.caption),
                        Text('${(progress * 100).toInt()}% ($xpNeeded XP needed)', style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.creamBorder,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold500),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          BrandButton(
            text: 'Close',
            type: BrandButtonType.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final totalXp = user?.totalXp ?? 0;
    final progressAsync = ref.watch(userProgressProvider);
    final userProgress = progressAsync.value;

    bool isUnlocked = achievement.isUnlocked;
    if (!isUnlocked) {
      switch (achievement.id) {
        case 'ach_first_lesson':
          isUnlocked = (userProgress?.totalLessonsCompleted ?? 0) > 0;
          break;
        case 'ach_streak_3':
          isUnlocked = (user?.streakDays ?? 0) >= 3;
          break;
        case 'ach_xp_500':
          isUnlocked = totalXp >= 500;
          break;
        case 'ach_unit_1':
          isUnlocked = (userProgress?.totalLessonsCompleted ?? 0) >= 3;
          break;
        case 'ach_pronunciation':
          isUnlocked = false;
          break;
        case 'ach_ancestors_voice':
          isUnlocked = false;
          break;
        case 'ach_lexicon_legend':
          isUnlocked = false;
          break;
        case 'ach_streak_7':
          isUnlocked = (user?.streakDays ?? 0) >= 7;
          break;
        case 'ach_crystal_collector':
          isUnlocked = (user?.crystals ?? 0) >= 100;
          break;
        case 'ach_classroom_scholar':
          isUnlocked = (user?.inventory.contains('classroom_joined') ?? false);
          break;
        case 'ach_duel_victor':
          isUnlocked = false;
          break;
        case 'ach_night_owl':
          isUnlocked = achievement.isUnlocked;
          break;
        default:
          isUnlocked = achievement.isUnlocked;
      }
    }

    final xpNeeded = (achievement.xpRequirement - totalXp).clamp(0, achievement.xpRequirement);
    final progress = achievement.progressRatio > 0
        ? achievement.progressRatio
        : (totalXp / (achievement.xpRequirement > 0 ? achievement.xpRequirement : 1)).clamp(0.0, 1.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lockedBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final lockedBorderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.85,
      child: BrandCard(
        onTap: () => _showBadgeDetailsDialog(context, isUnlocked, progress, xpNeeded),
        backgroundColor: isUnlocked ? AppColors.gold500 : lockedBg,
        border: Border.all(
          color: isUnlocked ? AppColors.gold700 : lockedBorderColor,
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
                color: isUnlocked ? AppColors.forest900.withValues(alpha: 0.1) : (isDark ? Colors.white12 : Colors.grey.shade300),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUnlocked ? AppColors.forest900 : lockedBorderColor,
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
