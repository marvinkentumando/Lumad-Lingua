import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../utils/level_helper.dart';
import '../../utils/audio_helper.dart';
import '../common/brand_button.dart';

void showLevelUpDialog(BuildContext context, {required int newLevel}) {
  final levelTitle = LevelHelper.getLevelTitle(newLevel);
  final confettiController = ConfettiController(duration: const Duration(seconds: 3))..play();
  AudioHelper.playSfx(AudioHelper.sfxSuccess);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Stack(
      alignment: Alignment.center,
      children: [
        AlertDialog(
          backgroundColor: AppColors.cardColor(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.modal)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold500, width: 2.5),
                ),
                child: const Icon(Icons.emoji_events, size: 56, color: AppColors.gold500),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.08, 1.08), duration: 800.ms),
              const SizedBox(height: 12),
              Text(
                'LEVEL UP! 🎉',
                style: AppTypography.h1ExtraBold.copyWith(color: AppColors.gold400, fontSize: 26, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You are now a',
                style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Level $newLevel: $levelTitle',
                style: AppTypography.h2.copyWith(color: AppColors.textColor(context), fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.gold500),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.diamond, color: AppColors.gold500, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '+50 Bonus Crystals Awarded!',
                      style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            BrandButton(
              text: 'Claim & Continue 🚀',
              type: BrandButtonType.gold,
              onPressed: () {
                confettiController.dispose();
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
        ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            AppColors.gold500,
            AppColors.forestGreen,
            Colors.amber,
            Colors.orange,
            Colors.greenAccent,
          ],
        ),
      ],
    ),
  );
}
