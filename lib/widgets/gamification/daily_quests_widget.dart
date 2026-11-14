import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../common/app_card.dart';
import '../common/brand_button.dart';

class DailyQuestItem {
  final String title;
  final String description;
  final int xpReward;
  final int crystalReward;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final String route;

  const DailyQuestItem({
    required this.title,
    required this.description,
    required this.xpReward,
    required this.crystalReward,
    required this.progress,
    required this.isCompleted,
    required this.route,
  });
}

class DailyQuestsWidget extends StatefulWidget {
  const DailyQuestsWidget({super.key});

  @override
  State<DailyQuestsWidget> createState() => _DailyQuestsWidgetState();
}

class _DailyQuestsWidgetState extends State<DailyQuestsWidget> {
  final List<DailyQuestItem> _quests = [
    const DailyQuestItem(
      title: 'Complete a Mansaka Lesson',
      description: 'Finish any active lesson in your learning path',
      xpReward: 50,
      crystalReward: 10,
      progress: 0.5,
      isCompleted: false,
      route: '/learn',
    ),
    const DailyQuestItem(
      title: 'Pronunciation Practice',
      description: 'Record and test audio pronunciation',
      xpReward: 30,
      crystalReward: 5,
      progress: 1.0,
      isCompleted: true,
      route: '/pronunciation',
    ),
    const DailyQuestItem(
      title: 'Lingua Duels PvP',
      description: 'Compete in a rapid-fire vocabulary duel',
      xpReward: 100,
      crystalReward: 20,
      progress: 0.0,
      isCompleted: false,
      route: '/arena',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.task_alt, color: AppColors.gold500, size: 24),
                  const SizedBox(width: 8),
                  Text('Daily Quests & Challenges', style: AppTypography.h3.copyWith(color: Colors.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold100,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text('Resets in 6h', style: AppTypography.labelBold.copyWith(color: AppColors.gold800, fontSize: 10)),
              ),
            ],
          ),
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
                  color: AppColors.creamSurface,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.creamBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(quest.title, style: AppTypography.labelBold.copyWith(color: AppColors.creamText, fontSize: 14)),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.bolt, size: 14, color: AppColors.gold800),
                            Text('+${quest.xpReward} XP', style: AppTypography.xpValue.copyWith(fontSize: 12)),
                            const SizedBox(width: 6),
                            const Icon(Icons.diamond, size: 14, color: AppColors.gold800),
                            Text('+${quest.crystalReward}', style: AppTypography.xpValue.copyWith(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(quest.description, style: AppTypography.caption.copyWith(color: AppColors.creamText2)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: quest.progress,
                              backgroundColor: AppColors.creamBorder,
                              color: quest.isCompleted ? AppColors.semanticGreen : AppColors.gold500,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 80,
                          height: 32,
                          child: BrandButton(
                            text: quest.isCompleted ? 'Claim' : 'Go',
                            type: quest.isCompleted ? BrandButtonType.success : BrandButtonType.gold,
                            onPressed: () {
                              if (quest.isCompleted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Claimed +${quest.xpReward} XP and +${quest.crystalReward} Crystals!')),
                                );
                                setState(() {
                                  // mark claimed
                                });
                              } else {
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
    );
  }
}
