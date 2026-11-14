import 'package:flutter/material.dart';
import '../../models/learning_unit_model.dart';
import '../../utils/constants.dart';
import '../common/brand_card.dart';

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
    return BrandCard(
      onTap: unit.isUnlocked ? onTap : null,
      backgroundColor: unit.isUnlocked ? AppColors.creamSurface : AppColors.forest100,
      border: Border.all(
        color: unit.isUnlocked ? AppColors.creamBorder : AppColors.forest300,
        width: 1.0,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: unit.isUnlocked ? AppColors.forest500 : AppColors.creamText3,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${unit.unitNumber}',
              style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit.title,
                  style: AppTypography.lessonTitle.copyWith(
                    color: unit.isUnlocked ? AppColors.creamText : AppColors.creamText3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unit.description,
                  style: AppTypography.body.copyWith(
                    color: unit.isUnlocked ? AppColors.creamText2 : AppColors.creamText3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            unit.isUnlocked ? Icons.chevron_right : Icons.lock,
            color: unit.isUnlocked ? AppColors.forest500 : AppColors.creamText3,
          ),
        ],
      ),
    );
  }
}
