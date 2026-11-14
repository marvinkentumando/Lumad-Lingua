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
    final isGuest = user == null;
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
              if (isGuest) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenBackground,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.brightGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle, color: AppColors.forestGreen, size: 36),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Exploring as Guest',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Sign in to sync your XP, streak & progress',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
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
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    Text(
                      user?.email ?? 'learner@lumadlingua.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.subtitleColor(context),
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
              const SizedBox(height: AppSpacing.md),

              // Settings Shortcut
              AppCard(
                onTap: () => context.push('/settings'),
                child: Row(
                  children: const [
                    Icon(Icons.settings_outlined, color: AppColors.forestGreen, size: 32),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Settings',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Preferences, audio & notifications',
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

              // Auth Button
              AppButton(
                text: isGuest ? 'Sign In / Register' : 'Sign Out',
                variant: isGuest ? AppButtonVariant.primary : AppButtonVariant.outline,
                onPressed: () async {
                  if (isGuest) {
                    context.push('/login');
                  } else {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/home');
                    }
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
