import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/gamification/achievement_badge.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements & Badges'),
      ),
      body: achievementsAsync.when(
        data: (achievements) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: achievements.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return AchievementBadgeWidget(achievement: achievement);
          },
        ),
        loading: () => const LoadingWidget(message: 'Loading achievements...'),
        error: (err, stack) => AppErrorWidget(
          message: 'Failed to load achievements: $err',
          onRetry: () => ref.invalidate(achievementsProvider),
        ),
      ),
    );
  }
}
