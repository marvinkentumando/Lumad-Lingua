import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/gamification/achievement_badge.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/brand_filter_chip.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Unlocked', 'Locked'];

  @override
  Widget build(BuildContext context) {
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: achievementsAsync.when(
          data: (achievements) {
            final unlockedCount = achievements.where((a) => a.isUnlocked).length;
            final progressRatio = achievements.isNotEmpty ? unlockedCount / achievements.length : 0.0;

            final filtered = _selectedCategory == 'All'
                ? achievements
                : (_selectedCategory == 'Unlocked'
                    ? achievements.where((a) => a.isUnlocked).toList()
                    : achievements.where((a) => !a.isUnlocked).toList());

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full-width Header occupying both columns
                        const ScreenHeader(
                          title: 'Trophy Room',
                          subtitle: 'Milestones in preserving Mansaka culture',
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Completion Summary Banner (With Gold Gradient & 3D Shadow Lip)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD54F), AppColors.gold500, Color(0xFFFFA000)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: AppColors.gold700, width: 2.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFFC78C00),
                                offset: Offset(0, 5),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: DefaultTextStyle(
                            style: const TextStyle(color: AppColors.forest900),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.forest900,
                                    borderRadius: BorderRadius.circular(AppRadius.chip),
                                  ),
                                  child: const Icon(Icons.emoji_events, color: AppColors.gold500, size: 28),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$unlockedCount of ${achievements.length} Badges Unlocked',
                                        style: AppTypography.h3.copyWith(color: AppColors.forest900, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${(progressRatio * 100).toInt()}% Trophy Completion Rate',
                                        style: AppTypography.caption.copyWith(color: AppColors.forest800, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progressRatio,
                                          backgroundColor: AppColors.forest900.withValues(alpha: 0.15),
                                          color: AppColors.forest900,
                                          minHeight: 6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Category Filter Pills (BrandFilterChip)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((cat) {
                              final isSelected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: BrandFilterChip(
                                  label: cat,
                                  isSelected: isSelected,
                                  onSelected: (_) {
                                    setState(() => _selectedCategory = cat);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final achievement = filtered[index];
                        return AchievementBadgeWidget(achievement: achievement);
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            );
          },
          loading: () => const LoadingWidget(message: 'Loading achievements...'),
          error: (err, stack) => AppErrorWidget(
            message: 'Failed to load achievements: $err',
            onRetry: () => ref.invalidate(achievementsProvider),
          ),
        ),
      ),
    );
  }
}
