import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AnswerOptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool? isCorrect;
  final VoidCallback onTap;

  const AnswerOptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    this.isCorrect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.borderGray;
    Color bgColor = AppColors.cardColor(context);

    if (isSelected) {
      if (isCorrect == null) {
        borderColor = AppColors.forestGreen;
        bgColor = AppColors.lightGreenBackground;
      } else if (isCorrect == true) {
        borderColor = AppColors.brightGreen;
        bgColor = AppColors.brightGreen.withValues(alpha: 0.15);
      } else {
        borderColor = AppColors.coralRed;
        bgColor = AppColors.coralRed.withValues(alpha: 0.15);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(AppSpacing.borderRadiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: AppColors.textColor(context),
                    ),
                  ),
                ),
                if (isSelected && isCorrect != null)
                  Icon(
                    isCorrect! ? Icons.check_circle : Icons.cancel,
                    color: isCorrect! ? AppColors.brightGreen : AppColors.coralRed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
