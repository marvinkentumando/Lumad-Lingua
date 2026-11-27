import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../common/brand_button.dart';

void showStreakMilestoneDialog(BuildContext context, WidgetRef ref, int streakDays) {
  final confettiController = ConfettiController(duration: const Duration(seconds: 4))..play();
  final is30Day = streakDays >= 30;
  final title = is30Day ? '30-DAY ANCESTRAL TORCH 🌋' : '14-DAY BLAZE MILESTONE ⚡';
  final crystalsReward = is30Day ? 300 : 200;
  final freezeReward = is30Day ? 2 : 1;
  final badgeTitle = is30Day ? 'Ancestral Torch Elite Badge 🏆' : 'Blaze Guardian Badge 🛡️';
  final claimKey = is30Day ? 'streak_30_chest_claimed' : 'streak_14_chest_claimed';

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
                  color: AppColors.gold500.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold500, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: AppColors.gold700, blurRadius: 12, spreadRadius: 2),
                  ],
                ),
                child: Text(is30Day ? '🌋' : '⚡', style: const TextStyle(fontSize: 54)),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.1, 1.1), duration: 800.ms),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTypography.h1ExtraBold.copyWith(color: AppColors.gold400, fontSize: 20, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Amazing dedication! You have maintained a $streakDays-day streak preserving Mansaka culture.',
                style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.forest800,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.gold500, width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildRewardItem(Icons.diamond, '+$crystalsReward Crystals 💎', AppColors.gold400),
                    const Divider(color: AppColors.forest700),
                    _buildRewardItem(Icons.ac_unit, '+$freezeReward Free Streak Freezes 🧊', AppColors.gold400),
                    const Divider(color: AppColors.forest700),
                    _buildRewardItem(Icons.military_tech, badgeTitle, AppColors.gold400),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            BrandButton(
              text: 'Claim Milestone Rewards 🎁',
              type: BrandButtonType.gold,
              onPressed: () async {
                confettiController.dispose();
                Navigator.of(dialogContext).pop();

                final authNotifier = ref.read(authStateProvider.notifier);
                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  final newInventory = List<String>.from(user.inventory);
                  if (!newInventory.contains(claimKey)) {
                    newInventory.add(claimKey);
                  }

                  final updated = user.copyWith(
                    crystals: user.crystals + crystalsReward,
                    streakFreezes: user.streakFreezes + freezeReward,
                    inventory: newInventory,
                  );

                  await authNotifier.updateUser(updated);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Milestone Claimed! +$crystalsReward Crystals & +$freezeReward Freezes added! 🎉'),
                      ),
                    );
                  }
                }
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

Widget _buildRewardItem(IconData icon, String text, Color color) {
  return Row(
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text, style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 13)),
      ),
    ],
  );
}
