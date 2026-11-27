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
import '../../providers/theme_provider.dart';
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
          skipLoadingOnRefresh: true,
          data: (units) => units.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.school_outlined, size: 64, color: AppColors.gold500),
                        const SizedBox(height: AppSpacing.md),
                        Text('No units available', style: AppTypography.h3.copyWith(color: AppColors.textColor(context))),
                        const SizedBox(height: 4),
                        Text('Curriculum units will appear here once added in Firebase.', style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    const ScreenHeader(
                      title: 'Learn Mansaka',
                      centerTitle: true,
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

class _UnitPathSection extends ConsumerStatefulWidget {
  final LearningUnitModel unit;

  const _UnitPathSection({required this.unit});

  @override
  ConsumerState<_UnitPathSection> createState() => _UnitPathSectionState();
}

class _UnitPathSectionState extends ConsumerState<_UnitPathSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.unit.unitNumber == 1;
  }

  void _showUnitRewardDialog(BuildContext context, WidgetRef ref, List<LessonModel> lessons) {
    final allCompleted = lessons.isNotEmpty && lessons.every((l) => l.status == LessonStatus.completed);
    final user = ref.read(authStateProvider).value;
    final chestKey = 'unit_${widget.unit.id}_chest_claimed';
    final isClaimed = user?.inventory.contains(chestKey) ?? false;

    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.gold500, size: 28),
            const SizedBox(width: 8),
            Text('Unit ${widget.unit.unitNumber} Reward Chest', style: AppTypography.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isClaimed
                  ? 'You have already claimed the reward chest for "${widget.unit.title}". Great job!'
                  : (allCompleted
                      ? 'Congratulations! You have completed all lessons in "${widget.unit.title}". Claim your Ancestral Treasure Chest containing +100 Bonus XP and +50 Crystals!'
                      : 'Complete all lessons in "${widget.unit.title}" to unlock and claim the Ancestral Treasure Chest!'),
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
            text: isClaimed ? 'Already Claimed' : (allCompleted ? 'Claim Reward' : 'Complete All Lessons First'),
            type: isClaimed ? BrandButtonType.secondary : (allCompleted ? BrandButtonType.gold : BrandButtonType.primary),
            onPressed: isClaimed
                ? null
                : () {
                    if (allCompleted && user != null) {
                      final notifier = ref.read(authStateProvider.notifier);
                      notifier.addXp(100);
                      notifier.updateCrystals(user.crystals + 50);
                      final newInventory = List<String>.from(user.inventory);
                      if (!newInventory.contains(chestKey)) {
                        newInventory.add(chestKey);
                        notifier.updateUser(user.copyWith(inventory: newInventory));
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Claimed Unit Reward Chest! +100 XP & +50 Crystals 🎉')),
                      );
                    }
                    Navigator.of(dialogContext).pop();
                  },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lessonsAsync = ref.watch(unitLessonsProvider(widget.unit.id));
    final isCustomActive = ref.watch(customThemeAccentProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        lessonsAsync.when(
          skipLoadingOnRefresh: true,
          data: (lessons) {
            final completedCount = lessons.where((l) => l.status == LessonStatus.completed).length;
            final progressRatio = lessons.isNotEmpty ? (completedCount / lessons.length) : 0.0;
            final allCompleted = lessons.isNotEmpty && lessons.every((l) => l.status == LessonStatus.completed);

            return Column(
              children: [
                // Unit Checkpoint Banner with Dynamic Theme Accent Support & Expand/Collapse Toggle
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _isExpanded = !_isExpanded);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCustomActive
                            ? [const Color(0xFF7A1429), const Color(0xFFA91D3A), const Color(0xFF380912)]
                            : [const Color(0xFF2E5A36), AppColors.forest500, Color(0xFF142917)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(
                        color: isCustomActive ? const Color(0xFF5C0E1E) : AppColors.forest700,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCustomActive ? const Color(0xFF1E0308) : const Color(0xFF0A140B),
                          offset: const Offset(0, 5),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.unit.title.toUpperCase(),
                                style: AppTypography.h2ExtraBold.copyWith(color: AppColors.gold400, fontSize: 19, fontWeight: FontWeight.w700),
                              ),
                            ),
                            Icon(
                              _isExpanded ? Icons.expand_less : Icons.expand_more,
                              color: AppColors.gold400,
                              size: 24,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.unit.description,
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
                            backgroundColor: isCustomActive ? const Color(0xFF5C0E1E) : AppColors.forest700,
                            color: AppColors.gold500,
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Winding Serpentine Path of Lessons (Collapsible)
                if (_isExpanded) ...[
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
                            final offsets = [0.0, -40.0, 40.0, 0.0, -40.0, 40.0];
                            final horizontalOffset = offsets[index % offsets.length];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                              child: Transform.translate(
                                offset: Offset(horizontalOffset, 0),
                                child: _LessonNode(
                                  lesson: lesson,
                                  index: index + 1,
                                  isCustomActive: isCustomActive,
                                  onTap: widget.unit.isUnlocked && lesson.status != LessonStatus.locked
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
                                  onTap: () => _showUnitRewardDialog(context, ref, lessons),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: allCompleted ? AppColors.gold500 : AppColors.creamBorder,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: allCompleted ? AppColors.gold700 : AppColors.creamShadow,
                                        width: 3.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: allCompleted ? AppColors.gold700 : AppColors.creamShadow,
                                          offset: const Offset(0, 4),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.card_giftcard,
                                      color: allCompleted ? AppColors.forest900 : AppColors.creamText3,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Unit ${widget.unit.unitNumber} Chest',
                                  style: AppTypography.labelBold.copyWith(color: AppColors.gold800, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            );
          },
          loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: AppColors.gold500))),
          error: (err, stack) => const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

class _LessonNode extends StatelessWidget {
  final LessonModel lesson;
  final int index;
  final bool isCustomActive;
  final VoidCallback? onTap;

  const _LessonNode({
    required this.lesson,
    required this.index,
    required this.isCustomActive,
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
      nodeColor = isCustomActive ? const Color(0xFFA91D3A) : AppColors.forest500;
      borderColor = isCustomActive ? const Color(0xFF5C0E1E) : AppColors.forest700;
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
              // Main Circular Node with Stage Progress Ring
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isCompleted && !isLocked && lesson.stageProgressRatio > 0)
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: lesson.stageProgressRatio,
                          strokeWidth: 4.5,
                          backgroundColor: AppColors.creamBorder.withValues(alpha: 0.5),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold500),
                        ),
                      ),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: nodeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: borderColor, width: 3.0),
                        boxShadow: [
                          BoxShadow(
                            color: borderColor,
                            offset: const Offset(0, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isLocked ? Icons.lock : iconData,
                          color: isLocked ? AppColors.creamText3 : (isCompleted ? Colors.white : AppColors.forest900),
                          size: 26,
                        ),
                      ),
                    ),
                  ],
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
