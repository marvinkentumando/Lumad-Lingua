import 'package:flutter/material.dart';
import '../../models/achievement_model.dart';
import '../../utils/constants.dart';

class AchievementBadgeWidget extends StatelessWidget {
  final AchievementModel achievement;

  const AchievementBadgeWidget({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: achievement.isUnlocked ? Colors.white : AppColors.softGray,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        border: Border.all(
          color: achievement.isUnlocked ? AppColors.warmYellow : AppColors.borderGray,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: achievement.isUnlocked ? AppColors.warmYellow : AppColors.lockedGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.isUnlocked ? Icons.emoji_events : Icons.lock,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked
                        ? AppColors.darkCharcoal
                        : AppColors.lockedGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkCharcoal.withValues(alpha: 0.7),
                  ),
                ),
                if (!achievement.isUnlocked) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: achievement.progressRatio,
                      backgroundColor: AppColors.borderGray,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.forestGreen),
                      minHeight: 6,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
