import 'package:flutter/material.dart';
import '../../models/learning_unit_model.dart';
import '../../utils/constants.dart';
import '../common/app_card.dart';

class UnitCard extends StatelessWidget {
  final LearningUnitModel unit;
  final VoidCallback? onTap;

  const UnitCard({
    super.key,
    required this.unit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: unit.isUnlocked ? onTap : null,
      backgroundColor: unit.isUnlocked ? AppColors.cardColor(context) : AppColors.softGray,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: unit.isUnlocked
                  ? AppColors.forestGreen
                  : AppColors.lockedGray,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${unit.unitNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: unit.isUnlocked
                        ? AppColors.textColor(context)
                        : AppColors.lockedGray,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unit.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: unit.isUnlocked
                        ? AppColors.subtitleColor(context)
                        : AppColors.lockedGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            unit.isUnlocked ? Icons.chevron_right : Icons.lock,
            color: unit.isUnlocked
                ? AppColors.forestGreen
                : AppColors.lockedGray,
          ),
        ],
      ),
    );
  }
}
