import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';

class StreakDashboardScreen extends ConsumerWidget {
  const StreakDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final streak = user?.streakDays ?? 3;

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(
                  title: 'Streak Dashboard',
                  subtitle: 'Maintain your daily Mansaka practice streak',
                ),
                const SizedBox(height: AppSpacing.xs),

                // Streak Hero Card
                BrandCard(
                  backgroundColor: AppColors.gold500,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_fire_department, color: AppColors.terracotta, size: 52),
                          const SizedBox(width: 8),
                          Text(
                            '$streak Days',
                            style: AppTypography.displayNumber.copyWith(color: AppColors.forest900, fontSize: 38),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active Practice Streak',
                        style: AppTypography.h3.copyWith(color: AppColors.forest900),
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
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.forest900 : AppColors.gold100,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isActive ? AppColors.forest900 : AppColors.gold700,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isActive ? Icons.check : Icons.remove,
                                    color: isActive ? AppColors.gold500 : AppColors.gold800,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(day, style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 12)),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Streak Freeze & Protection Tip Card
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.shield, color: AppColors.gold500, size: 28),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              'Protect Your Streak',
                              style: AppTypography.h3.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Missed a day? Equip a Streak Freeze pass from the Crystal Shop to keep your momentum alive!',
                        style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BrandButton(
                        text: 'Get Streak Freeze in Shop',
                        type: BrandButtonType.gold,
                        onPressed: () => context.push('/shop'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
