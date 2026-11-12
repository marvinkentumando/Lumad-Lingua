import 'package:flutter/material.dart';
import '../../models/lesson_model.dart';
import '../../utils/constants.dart';
import '../common/app_card.dart';

class LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = lesson.status == LessonStatus.locked;
    final isCompleted = lesson.status == LessonStatus.completed;

    Color iconBgColor = AppColors.forestGreen;
    IconData iconData = Icons.play_arrow;

    if (isLocked) {
      iconBgColor = AppColors.lockedGray;
      iconData = Icons.lock;
    } else if (isCompleted) {
      iconBgColor = AppColors.brightGreen;
      iconData = Icons.check;
    }

    return AppCard(
      onTap: isLocked ? null : onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? AppColors.lockedGray : AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkCharcoal.withValues(alpha: 0.7),
                  ),
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      3,
                      (index) => Icon(
                        index < lesson.starsEarned ? Icons.star : Icons.star_border,
                        size: 16,
                        color: AppColors.warmYellow,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warmYellow.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.forestGreen),
                const SizedBox(width: 4),
                Text(
                  '+${lesson.xpReward} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
