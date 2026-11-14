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
    Color borderColor = AppColors.creamBorder;
    Color bgColor = AppColors.creamSurface;

    if (isSelected) {
      if (isCorrect == null) {
        borderColor = AppColors.forest500;
        bgColor = AppColors.forest50;
      } else if (isCorrect == true) {
        borderColor = AppColors.semanticGreen;
        bgColor = AppColors.forest50;
      } else {
        borderColor = AppColors.semanticRed;
        bgColor = AppColors.gold100;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(AppRadius.button),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.5),
                  offset: const Offset(0, 2),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: AppColors.creamText,
                    ),
                  ),
                ),
                if (isSelected && isCorrect != null)
                  Icon(
                    isCorrect! ? Icons.check_circle : Icons.cancel,
                    color: isCorrect! ? AppColors.semanticGreen : AppColors.semanticRed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
