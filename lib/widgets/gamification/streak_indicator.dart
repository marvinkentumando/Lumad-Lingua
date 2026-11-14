import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class StreakIndicator extends StatelessWidget {
  final int streakDays;
  final VoidCallback? onTap;

  const StreakIndicator({super.key, required this.streakDays, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.coralRed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.coralRed.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: AppColors.coralRed, size: 18),
            const SizedBox(width: 4),
            Text(
              '$streakDays Days',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.coralRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
