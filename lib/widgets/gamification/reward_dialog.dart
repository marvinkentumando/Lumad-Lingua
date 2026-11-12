import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../common/app_button.dart';

class RewardDialog extends StatelessWidget {
  final int earnedXp;
  final int stars;
  final VoidCallback onContinue;

  const RewardDialog({
    super.key,
    required this.earnedXp,
    required this.stars,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stars_rounded,
              size: 72,
              color: AppColors.warmYellow,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Lesson Completed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkCharcoal,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    size: 36,
                    color: AppColors.warmYellow,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.lightGreenBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, color: AppColors.forestGreen),
                  const SizedBox(width: 8),
                  Text(
                    '+$earnedXp XP Earned',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Continue',
              onPressed: () {
                Navigator.of(context).pop();
                onContinue();
              },
            ),
          ],
        ),
      ),
    );
  }
}
