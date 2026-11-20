import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../common/brand_button.dart';

void showDay7MysteryChestDialog(BuildContext context, WidgetRef ref) {
  final confettiController = ConfettiController(duration: const Duration(seconds: 4))..play();

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
                child: const Text('🎁', style: TextStyle(fontSize: 54)),
              ).animate(onPlay: (c) => c.repeat(reverse: true))
               .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.1, 1.1), duration: 800.ms),
              const SizedBox(height: 12),
              Text(
                'DAY 7 MYSTERY CHEST! 🎉',
                style: AppTypography.h1ExtraBold.copyWith(color: AppColors.gold400, fontSize: 22, letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Congratulations on maintaining a 7-day streak! Here are your exclusive tribal rewards:',
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
                    _buildRewardItem(Icons.diamond, '+100 Bonus Crystals 💎', AppColors.gold400),
                    const Divider(color: AppColors.forest700),
                    _buildRewardItem(Icons.ac_unit, '+1 Free Streak Freeze 🧊', AppColors.gold400),
                    const Divider(color: AppColors.forest700),
                    _buildRewardItem(Icons.wallpaper, 'Ancestral Gold Harvest Banner 🎨', AppColors.gold400),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            BrandButton(
              text: 'Claim All Rewards 🎁',
              type: BrandButtonType.gold,
              onPressed: () async {
                confettiController.dispose();
                Navigator.of(dialogContext).pop();

                final authNotifier = ref.read(authStateProvider.notifier);
                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  final newInventory = List<String>.from(user.inventory);
                  if (!newInventory.contains('day_7_chest_claimed')) {
                    newInventory.add('day_7_chest_claimed');
                  }
                  if (!newInventory.contains('banner_ancestral_gold')) {
                    newInventory.add('banner_ancestral_gold');
                  }

                  final updated = user.copyWith(
                    crystals: user.crystals + 100,
                    streakFreezes: user.streakFreezes + 1,
                    inventory: newInventory,
                    equippedBanner: user.equippedBanner ?? 'banner_ancestral_gold',
                  );

                  await authNotifier.updateUser(updated);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rewards Claimed! +100 Crystals, +1 Streak Freeze & Profile Banner unlocked! 🎁'),
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
