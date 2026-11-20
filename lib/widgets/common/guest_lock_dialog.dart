import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import 'brand_button.dart';

void showGuestLockDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.cardColor(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.modal)),
      title: Row(
        children: [
          const Icon(Icons.lock, color: AppColors.gold500, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTypography.h3.copyWith(color: AppColors.textColor(context)),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppTypography.body.copyWith(color: AppColors.textColor(context)),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in or create a free account to unlock this feature and sync your progress across devices!',
            style: AppTypography.caption.copyWith(color: AppColors.subtitleColor(context)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context))),
        ),
        BrandButton(
          text: 'Sign In / Register',
          type: BrandButtonType.gold,
          onPressed: () {
            Navigator.of(dialogContext).pop();
            context.push('/login');
          },
        ),
      ],
    ),
  );
}
