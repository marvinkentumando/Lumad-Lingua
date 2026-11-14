import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/gamification/xp_badge.dart';

class StreaksXpDashboardScreen extends ConsumerWidget {
  const StreaksXpDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    final streak = user?.streakDays ?? 3;
    final xp = user?.totalXp ?? 250;
    final level = user?.level ?? 3;
    final crystals = user?.crystals ?? 150;

    // Level calculation helper: 100 XP per level
    final xpInCurrentLevel = xp % 100;
    final xpNeededForNextLevel = 100;
    final progress = xpInCurrentLevel / xpNeededForNextLevel;

    return Scaffold(
      appBar: AppBar(
        title: Text('Streaks & XP Dashboard', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () => context.push('/shop'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold500,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(color: AppColors.gold700),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond, color: AppColors.forest900, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$crystals',
                        style: AppTypography.labelBold.copyWith(color: AppColors.forest900),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Streak Hero Card
              AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department, color: AppColors.terracotta, size: 48),
                        const SizedBox(width: 8),
                        Text(
                          '$streak Days',
                          style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 36),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Learning Streak',
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Weekly check-in row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].asMap().entries.map((entry) {
                        final index = entry.key;
                        final day = entry.value;
                        final isActive = index < (streak % 7);
                        return Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
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
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(day, style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 12)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // XP & Level Progression Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level $level Learner',
                          style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 22),
                        ),
                        XPBadge(xp: xp),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Level Progress', style: AppTypography.body.copyWith(color: AppColors.creamBorder)),
                        Text('$xpInCurrentLevel / $xpNeededForNextLevel XP', style: AppTypography.xpValue.copyWith(color: AppColors.gold400)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: AppColors.forest700,
                        color: AppColors.gold500,
                        minHeight: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Earn ${xpNeededForNextLevel - xpInCurrentLevel} more XP to reach Level ${level + 1}!',
                      style: AppTypography.caption.copyWith(color: AppColors.gold300, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Crystal Currency Banner
              AppCard(
                backgroundColor: AppColors.gold500,
                border: Border.all(color: AppColors.gold700, width: 1.5),
                child: DefaultTextStyle(
                  style: const TextStyle(color: AppColors.forest900),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond, color: AppColors.forest900, size: 40),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$crystals Crystals Available',
                              style: AppTypography.h3.copyWith(color: AppColors.forest900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Use crystals in the shop to buy streak freezes, boosters, and avatars.',
                              style: AppTypography.body.copyWith(color: AppColors.forest800),
                            ),
                          ],
                        ),
                      ),
                      BrandButton(
                        text: 'Shop',
                        type: BrandButtonType.primary,
                        onPressed: () => context.push('/shop'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
