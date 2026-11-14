import 'package:flutter/material.dart';
import '../../models/lesson_model.dart';
import '../../utils/constants.dart';
import '../common/brand_card.dart';

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

    Color iconBgColor = AppColors.forest500;
    IconData iconData = Icons.play_arrow;

    if (isLocked) {
      iconBgColor = AppColors.creamText3;
      iconData = Icons.lock;
    } else if (isCompleted) {
      iconBgColor = AppColors.semanticGreen;
      iconData = Icons.check;
    }

    return BrandCard(
      onTap: isLocked ? null : onTap,
      backgroundColor: isLocked ? AppColors.forest100 : AppColors.creamSurface,
      border: Border.all(
        color: isLocked ? AppColors.forest300 : AppColors.creamBorder,
        width: 1.0,
      ),
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
                  style: AppTypography.lessonTitle.copyWith(
                    color: isLocked ? AppColors.creamText3 : AppColors.creamText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.description,
                  style: AppTypography.body.copyWith(
                    color: isLocked ? AppColors.creamText3 : AppColors.creamText2,
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
                        color: AppColors.gold500,
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
              color: AppColors.gold100,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(color: AppColors.gold300),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.gold800),
                const SizedBox(width: 4),
                Text(
                  '+${lesson.xpReward} XP',
                  style: AppTypography.xpValue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
