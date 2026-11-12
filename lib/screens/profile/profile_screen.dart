import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/gamification/xp_badge.dart';
import '../../widgets/gamification/streak_indicator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header Card
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.forestGreen,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'L',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      user?.name ?? 'Lumad Learner',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    Text(
                      user?.email ?? 'learner@lumadlingua.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkCharcoal.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreakIndicator(streakDays: user?.streakDays ?? 3),
                        const SizedBox(width: 12),
                        XPBadge(xp: user?.totalXp ?? 250),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Statistics Section
              const Text(
                'Learning Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              progressAsync.when(
                data: (progress) => Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.forestGreen, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              '${progress.totalLessonsCompleted}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Lessons Done', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Icon(Icons.star_outline, color: AppColors.warmYellow, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              '${(progress.overallMasteryPercentage * 100).toInt()}%',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Mastery Rate', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading stats: $e'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Achievements Shortcut
              AppCard(
                onTap: () => context.push('/achievements'),
                child: Row(
                  children: const [
                    Icon(Icons.emoji_events, color: AppColors.warmYellow, size: 32),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievements & Badges',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'View your earned badges and rewards',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.forestGreen),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Logout Button
              AppButton(
                text: 'Sign Out',
                variant: AppButtonVariant.outline,
                onPressed: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
