import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../common/brand_card.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: AppColors.terracotta, size: 42),
              const SizedBox(width: 8),
              Text(
                '$streakDays Days',
                style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 32),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Current Learning Streak',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final isActive = index < (streakDays % 7);
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.gold500 : AppColors.forest700,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive ? AppColors.gold700 : AppColors.forest300,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isActive ? Icons.check : Icons.remove,
                        color: isActive ? AppColors.forest900 : AppColors.creamText3,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(day, style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 11)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
