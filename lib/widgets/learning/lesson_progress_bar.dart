import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class LessonProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const LessonProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps > 0 ? (currentStep / totalSteps).clamp(0.0, 1.0) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: 10,
        backgroundColor: AppColors.softGray,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brightGreen),
      ),
    );
  }
}
