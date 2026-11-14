import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_button.dart';

class LessonResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const LessonResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final earnedXp = resultData['earnedXp'] as int? ?? 30;
    final stars = resultData['stars'] as int? ?? 3;
    final score = resultData['score'] as int? ?? 5;
    final total = resultData['total'] as int? ?? 5;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                size: 88,
                color: AppColors.warmYellow,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Madyaw! Great Job!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You completed the lesson with $score / $total correct answers.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.subtitleColor(context),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    size: 44,
                    color: AppColors.warmYellow,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightGreenBackground,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.brightGreen),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: AppColors.forestGreen, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '+$earnedXp Total XP Earned',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                text: 'Back to Learning Path',
                onPressed: () => context.go('/learn'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
