import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';

class LottieStreakFlameWidget extends StatelessWidget {
  final int streakDays;

  const LottieStreakFlameWidget({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    // Dynamic scale and glow aura based on streak length
    final double scale = streakDays >= 8 ? 1.25 : (streakDays >= 4 ? 1.1 : 0.95);
    final Color auraColor = streakDays >= 8
        ? AppColors.gold500
        : (streakDays >= 4 ? AppColors.terracotta : AppColors.gold400);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Glowing Aura Ring
        Container(
          width: 38 * scale,
          height: 38 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: auraColor.withValues(alpha: streakDays > 0 ? 0.35 : 0.1),
            boxShadow: [
              if (streakDays > 0)
                BoxShadow(
                  color: auraColor.withValues(alpha: 0.6),
                  blurRadius: 12 * scale,
                  spreadRadius: 2 * scale,
                ),
            ],
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(begin: Offset(0.9 * scale, 0.9 * scale), end: Offset(1.15 * scale, 1.15 * scale), duration: 1000.ms),

        // Fire Flame Icon / Lottie Graphic
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: streakDays > 0 ? AppColors.terracotta : Colors.grey,
              size: 26 * scale,
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .shimmer(duration: 1500.ms, color: AppColors.gold500),
            const SizedBox(width: 2),
            Text(
              '$streakDays',
              style: AppTypography.mono.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14 * scale,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
