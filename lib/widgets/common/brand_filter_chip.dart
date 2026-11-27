import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../utils/audio_helper.dart';
import '../../providers/theme_provider.dart';

class BrandFilterChip extends ConsumerWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const BrandFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        AudioHelper.playSfx(AudioHelper.sfxClick, enabled: ref.read(soundEffectsProvider));
        onSelected(!isSelected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold500 : AppColors.cardColor(context),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: isSelected ? AppColors.gold700 : AppColors.creamBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0xFFC78C00),
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelBold.copyWith(
            color: isSelected ? AppColors.forest900 : AppColors.textColor(context),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
