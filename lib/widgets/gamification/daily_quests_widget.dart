import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../common/brand_button.dart';

class DailyQuestItem {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int crystalReward;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final bool isClaimed;
  final String route;

  const DailyQuestItem({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.crystalReward,
    required this.progress,
    required this.isCompleted,
    required this.isClaimed,
    required this.route,
  });

  DailyQuestItem copyWith({bool? isClaimed}) {
    return DailyQuestItem(
      id: id,
      title: title,
      description: description,
      xpReward: xpReward,
      crystalReward: crystalReward,
      progress: progress,
      isCompleted: isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
      route: route,
    );
  }
}

class DailyQuestsWidget extends ConsumerStatefulWidget {
  const DailyQuestsWidget({super.key});

  @override
  ConsumerState<DailyQuestsWidget> createState() => _DailyQuestsWidgetState();
}

class _DailyQuestsWidgetState extends ConsumerState<DailyQuestsWidget> {
  final List<DailyQuestItem> _quests = [
    const DailyQuestItem(
      id: 'q1',
      title: 'Complete a Mansaka Lesson',
      description: 'Finish any active lesson in your learning path',
      xpReward: 50,
      crystalReward: 10,
      progress: 0.5,
      isCompleted: false,
      isClaimed: false,
      route: '/learn',
    ),
    const DailyQuestItem(
      id: 'q2',
      title: 'Pronunciation Practice',
      description: 'Record and test audio pronunciation',
      xpReward: 30,
      crystalReward: 5,
      progress: 1.0,
      isCompleted: true,
      isClaimed: false,
      route: '/pronunciation',
    ),
    const DailyQuestItem(
      id: 'q3',
      title: 'Lingua Duels PvP',
      description: 'Compete in a rapid-fire vocabulary duel',
      xpReward: 100,
      crystalReward: 20,
      progress: 0.0,
      isCompleted: false,
      isClaimed: false,
      route: '/arena',
    ),
  ];

  Future<void> _claimQuest(int index) async {
    final quest = _quests[index];
    if (quest.isClaimed || !quest.isCompleted) return;

    HapticFeedback.heavyImpact();
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final authNotifier = ref.read(authStateProvider.notifier);
      authNotifier.addXp(quest.xpReward);
      authNotifier.updateCrystals(user.crystals + quest.crystalReward);
    }

    setState(() {
      _quests[index] = quest.copyWith(isClaimed: true);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully claimed +${quest.xpReward} XP and +${quest.crystalReward} Crystals! 🎉')),
      );
    }
  }

  void _showQuestsModal(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
      ),
      builder: (sheetContext) {
        final isDark = Theme.of(sheetContext).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) => Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.md,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Daily Quests', style: AppTypography.h2.copyWith(color: AppColors.textColor(sheetContext))),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.subtitleColor(sheetContext)),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Complete challenges daily to maintain your streak and earn bonus rewards.', style: AppTypography.body.copyWith(color: AppColors.subtitleColor(sheetContext))),
                const SizedBox(height: AppSpacing.md),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _quests.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final quest = _quests[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.forest800 : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: isDark ? AppColors.forest700 : AppColors.creamBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(quest.title, style: AppTypography.labelBold.copyWith(color: isDark ? Colors.white : AppColors.creamText, fontSize: 14)),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.bolt, size: 14, color: AppColors.gold500),
                                  Text('+${quest.xpReward} XP', style: AppTypography.xpValue.copyWith(fontSize: 12, color: AppColors.gold400)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.diamond, size: 14, color: AppColors.gold500),
                                  Text('+${quest.crystalReward}', style: AppTypography.xpValue.copyWith(fontSize: 12, color: AppColors.gold400)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(quest.description, style: AppTypography.caption.copyWith(color: isDark ? Colors.white70 : AppColors.creamText2)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: quest.isClaimed ? 1.0 : quest.progress,
                                    backgroundColor: isDark ? AppColors.forest700 : AppColors.creamBorder,
                                    color: quest.isClaimed ? (isDark ? Colors.grey : AppColors.creamText3) : (quest.isCompleted ? AppColors.semanticGreen : AppColors.gold500),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 90,
                                height: 34,
                                child: BrandButton(
                                  text: quest.isClaimed ? 'Claimed' : (quest.isCompleted ? 'Claim' : 'Go'),
                                  type: quest.isClaimed
                                      ? BrandButtonType.small
                                      : (quest.isCompleted ? BrandButtonType.success : BrandButtonType.gold),
                                  onPressed: quest.isClaimed
                                      ? null
                                      : () {
                                          HapticFeedback.lightImpact();
                                          if (quest.isCompleted) {
                                            _claimQuest(index);
                                            setSheetState(() {});
                                            setState(() {});
                                          } else {
                                            Navigator.of(sheetContext).pop();
                                            context.push(quest.route);
                                          }
                                        },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _quests.where((q) => q.isCompleted || q.isClaimed).length;
    final progress = completedCount / _quests.length;
    final isCustomActive = ref.watch(customThemeAccentProvider);

    return GestureDetector(
      onTap: () => _showQuestsModal(context),
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gold500,
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: const Icon(Icons.task_alt, color: AppColors.forest900, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Daily Quests', style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 18)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold500.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                          border: Border.all(color: AppColors.gold500),
                        ),
                        child: Text('🔥 1.5x Bonus', style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 9)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('$completedCount of ${_quests.length} Completed • Tap to View', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isCustomActive ? const Color(0xFF5C0E1E) : AppColors.forest700,
                      color: AppColors.gold500,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppColors.gold500),
          ],
        ),
      ),
    );
  }
}
