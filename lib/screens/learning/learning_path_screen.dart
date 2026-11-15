import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/constants.dart';
import '../../models/learning_unit_model.dart';
import '../../models/lesson_model.dart';
import '../../providers/lesson_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/lumad_background.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: unitsAsync.when(
          data: (units) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const ScreenHeader(
                title: 'Learn Mansaka',
                subtitle: 'Master indigenous vocabulary along the winding path',
              ),
              const SizedBox(height: AppSpacing.md),
              ...units.map((unit) => _UnitPathSection(unit: unit)),
            ],
          ),
          loading: () => const LoadingWidget(message: 'Loading learning path...'),
          error: (err, stack) => AppErrorWidget(
            message: 'Failed to load curriculum: $err',
            onRetry: () => ref.invalidate(unitsProvider),
          ),
        ),
      ),
    );
  }
}

class _UnitPathSection extends ConsumerWidget {
  final LearningUnitModel unit;

  const _UnitPathSection({required this.unit});

  void _showUnitRewardDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.gold500, size: 28),
            const SizedBox(width: 8),
            Text('Unit ${unit.unitNumber} Reward Chest', style: AppTypography.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit.isUnlocked
                  ? 'Complete all lessons in "${unit.title}" to unlock the Ancestral Treasure Chest containing +100 Bonus XP and +50 Crystals!'
                  : 'Unlock this unit to earn ancestral rewards!',
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold100,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.gold500),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.gold800, size: 20),
                      const SizedBox(width: 4),
                      Text('+100 XP', style: AppTypography.xpValue),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.diamond, color: AppColors.gold800, size: 20),
                      const SizedBox(width: 4),
                      Text('+50 Crystals', style: AppTypography.xpValue),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          BrandButton(
            text: unit.isUnlocked ? 'Claim Reward' : 'Got It',
            type: unit.isUnlocked ? BrandButtonType.gold : BrandButtonType.primary,
            onPressed: () {
              if (unit.isUnlocked) {
                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  final notifier = ref.read(authStateProvider.notifier);
                  notifier.addXp(100);
                  notifier.updateCrystals(user.crystals + 50);
                }
              }
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(unitLessonsProvider(unit.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lessonsAsync.when(
          data: (lessons) {
            final completedCount = lessons.where((l) => l.status == LessonStatus.completed).length;
            final progressRatio = lessons.isNotEmpty ? (completedCount / lessons.length) : 0.0;

            return Column(
              children: [
                // Unit Checkpoint Banner with Bold Heavy Fredoka Title
                Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E5A36), AppColors.forest500, Color(0xFF142917)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.forest700, width: 1.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF0A140B),
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unit.title.toUpperCase(),
                        style: AppTypography.h2ExtraBold.copyWith(color: AppColors.gold400, fontSize: 19, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        unit.description,
                        style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Unit Mastery', style: AppTypography.labelBold.copyWith(color: AppColors.creamBorder, fontSize: 12)),
                          Text('$completedCount / ${lessons.length} Completed', style: AppTypography.mono.copyWith(color: AppColors.gold400, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          backgroundColor: AppColors.forest700,
                          color: AppColors.gold500,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                // Winding Serpentine Path of Lessons
                if (lessons.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No lessons in this unit yet.', style: AppTypography.body),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Column(
                      children: [
                        ...List.generate(lessons.length, (index) {
                          final lesson = lessons[index];
                          // Centered serpentine offset pattern: [0.0, -40.0, 40.0, 0.0, -40.0, 40.0]
                          final offsets = [0.0, -40.0, 40.0, 0.0, -40.0, 40.0];
                          final horizontalOffset = offsets[index % offsets.length];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                            child: Transform.translate(
                              offset: Offset(horizontalOffset, 0),
                              child: _LessonNode(
                                lesson: lesson,
                                index: index + 1,
                                onTap: unit.isUnlocked && lesson.status != LessonStatus.locked
                                    ? () {
                                        HapticFeedback.mediumImpact();
                                        context.push('/lesson/${lesson.id}');
                                      }
                                    : null,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: AppSpacing.md),

                        // Unit Reward Chest Node at the end of lessons
                        Transform.translate(
                          offset: const Offset(0, 0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _showUnitRewardDialog(context, ref),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: unit.isUnlocked ? AppColors.gold500 : AppColors.creamBorder,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: unit.isUnlocked ? AppColors.gold700 : AppColors.creamShadow,
                                      width: 3.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: unit.isUnlocked ? AppColors.gold700 : AppColors.creamShadow,
                                        offset: const Offset(0, 4),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.card_giftcard,
                                    color: unit.isUnlocked ? AppColors.forest900 : AppColors.creamText3,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unit ${unit.unitNumber} Chest',
                                style: AppTypography.labelBold.copyWith(color: AppColors.gold800, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: AppColors.gold500))),
          error: (err, stack) => const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _LessonNode extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final VoidCallback? onTap;

  const _LessonNode({
    required this.lesson,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = lesson.status == LessonStatus.locked;
    final isCompleted = lesson.status == LessonStatus.completed;
    final isInProgress = lesson.status == LessonStatus.inProgress;

    Color nodeColor = AppColors.creamBorder;
    Color borderColor = AppColors.creamShadow;
    IconData iconData = Icons.lock;

    if (isCompleted) {
      nodeColor = AppColors.forest500;
      borderColor = AppColors.forest700;
      iconData = Icons.check;
    } else if (isInProgress || !isLocked) {
      nodeColor = AppColors.gold500;
      borderColor = AppColors.gold700;
      iconData = Icons.play_arrow_rounded;
    }

    final isActive = isInProgress || (!isLocked && !isCompleted);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Floating Active Node Tooltip Badge
        if (isActive) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold500,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(color: AppColors.gold700, width: 1.5),
            ),
            child: Text(
              'START',
              style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 10),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
           .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 800.ms),
          const SizedBox(height: 4),
        ],
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing glow for active lesson
              if (isActive)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.gold500.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.18, 1.18), duration: 1200.ms),
              // Main Circular Node
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: nodeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: borderColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isLocked ? Icons.lock : iconData,
                    color: isLocked ? AppColors.creamText3 : (isCompleted ? Colors.white : AppColors.forest900),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.creamSurface,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: AppColors.creamBorder),
          ),
          child: Text(
            lesson.title,
            style: AppTypography.labelBold.copyWith(color: AppColors.creamText, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (isCompleted) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              3,
              (starIndex) => Icon(
                starIndex < lesson.starsEarned ? Icons.star : Icons.star_border,
                size: 14,
                color: AppColors.gold500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
