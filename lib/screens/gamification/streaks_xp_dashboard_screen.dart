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
        title: const Text('Streaks & XP Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () => context.push('/shop'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold500.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(color: AppColors.gold500),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond, color: AppColors.gold500, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$crystals',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 48),
                        const SizedBox(width: 8),
                        Text(
                          '$streak Days',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Current Learning Streak',
                      style: TextStyle(fontSize: 14, color: AppColors.subtitleColor(context)),
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
                                color: isActive ? AppColors.forestGreen : AppColors.progressTrack,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  isActive ? Icons.check : Icons.remove,
                                  color: isActive ? Colors.white : Colors.grey,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor(context),
                          ),
                        ),
                        XPBadge(xp: xp),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Level Progress', style: TextStyle(fontSize: 13, color: AppColors.subtitleColor(context))),
                        Text('$xpInCurrentLevel / $xpNeededForNextLevel XP', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.progressTrack,
                      color: AppColors.gold500,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Earn ${xpNeededForNextLevel - xpInCurrentLevel} more XP to reach Level ${level + 1}!',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.subtitleColor(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Crystal Currency Banner
              AppCard(
                backgroundColor: AppColors.gold500.withValues(alpha: 0.1),
                border: Border.all(color: AppColors.gold500, width: 1.5),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, color: AppColors.gold500, size: 40),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$crystals Crystals Available',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textColor(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Use crystals in the shop to buy streak freezes, boosters, and avatars.',
                            style: TextStyle(fontSize: 12, color: AppColors.subtitleColor(context)),
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
            ],
          ),
        ),
      ),
    );
  }
}
