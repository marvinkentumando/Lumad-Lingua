import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../utils/level_helper.dart';
import '../../models/user_model.dart';
import '../../data/mock_users.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_filter_chip.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/gamification/xp_badge.dart';
import '../../widgets/gamification/streak_indicator.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _selectedPeriod = 'All-Time';
  final List<String> _periods = ['Weekly', 'Monthly', 'All-Time'];

  void _showLearnerDetailsDialog(BuildContext context, UserModel user, int rank) {
    HapticFeedback.lightImpact();
    final level = LevelHelper.calculateLevel(user.totalXp);
    final hasCustomBadge = user.inventory.contains('leaderboard_badge_customizer');

    String rankTitle = 'Mansaka Scholar 🎓';
    if (level < 3) {
      rankTitle = 'Beginning Learner 📚';
    } else if (level < 5) {
      rankTitle = 'Growing Speaker 💬';
    } else if (level < 8) {
      rankTitle = 'Confident Communicator 🌟';
    } else if (level < 11) {
      rankTitle = 'Fluent Achiever 🏆';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.forest800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.modal)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.gold500,
              child: Text(
                user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'L',
                style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 18),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user.name,
                          style: AppTypography.h3.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasCustomBadge) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.workspace_premium, color: AppColors.gold500, size: 16),
                      ],
                    ],
                  ),
                  Text('Global Rank #$rank', style: AppTypography.caption.copyWith(color: AppColors.gold400, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.forest900,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.forest700),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Title & Rank', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                      Text(rankTitle, style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Level', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                      Text('Level $level', style: AppTypography.labelBold.copyWith(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total XP', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                      XPBadge(xp: user.totalXp),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Streak', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                      StreakIndicator(streakDays: user.streakDays),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          BrandButton(
            text: 'Close',
            type: BrandButtonType.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: const LumadTopNavbar(title: 'Global Leaderboard'),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('totalXp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          List<UserModel> learners = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            learners = snapshot.data!.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return UserModel.fromJson(data);
            }).toList();
          } else {
            learners = List.from(mockGlobalLeaderboard);
            learners.sort((a, b) => b.totalXp.compareTo(a.totalXp));
          }

          if (learners.isEmpty) {
            return Center(child: Text('No learners found on the leaderboard yet.', style: AppTypography.bodyLarge));
          }

          final top1 = learners.isNotEmpty ? learners[0] : null;
          final top2 = learners.length > 1 ? learners[1] : null;
          final top3 = learners.length > 2 ? learners[2] : null;
          final rest = learners.length > 3 ? learners.sublist(3) : <UserModel>[];

          // Determine current user's rank
          int myRank = -1;
          if (currentUser != null) {
            myRank = learners.indexWhere((u) => u.id == currentUser.id || u.email == currentUser.email) + 1;
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time-Period Filter Pills
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _periods.map((period) {
                              final isSelected = _selectedPeriod == period;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: BrandFilterChip(
                                  label: period,
                                  isSelected: isSelected,
                                  onSelected: (_) {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedPeriod = period);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Top 3 Podium Card (3D Tactile Styling & Step Elevations)
                        BrandCard(
                          backgroundColor: AppColors.gold500,
                          border: Border.all(color: AppColors.gold700, width: 2),
                          child: DefaultTextStyle(
                            style: const TextStyle(color: AppColors.forest900),
                            child: Column(
                              children: [
                                Text(
                                  'GLOBAL TOP LEARNERS ($_selectedPeriod)',
                                  style: AppTypography.labelBold.copyWith(
                                    color: AppColors.forest900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Rank 2 (Silver)
                                    if (top2 != null) _buildPodiumUser(context, top2, 2, AppColors.forest700),

                                    // Rank 1 (Gold)
                                    if (top1 != null) _buildPodiumUser(context, top1, 1, AppColors.forest900),

                                    // Rank 3 (Bronze)
                                    if (top3 != null) _buildPodiumUser(context, top3, 3, AppColors.forest700),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Leaderboard Roster Header
                        Text('Rankings', style: AppTypography.h3),
                        const SizedBox(height: AppSpacing.sm),

                        // List for Ranks #4 and beyond
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: rest.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final user = rest[index];
                            final rank = index + 4;
                            final isMe = currentUser != null && (user.id == currentUser.id || user.email == currentUser.email);
                            final hasCustomBadge = user.inventory.contains('leaderboard_badge_customizer');

                            return AppCard(
                              onTap: () => _showLearnerDetailsDialog(context, user, rank),
                              backgroundColor: isMe ? AppColors.forest500 : AppColors.creamSurface,
                              border: isMe ? Border.all(color: AppColors.gold500, width: 2.0) : null,
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isMe ? AppColors.gold500 : AppColors.forest700,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#$rank',
                                        style: AppTypography.mono.copyWith(
                                          color: isMe ? AppColors.forest900 : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                user.name + (isMe ? ' (You)' : ''),
                                                style: AppTypography.lessonTitle.copyWith(
                                                  color: isMe ? Colors.white : AppColors.creamText,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (hasCustomBadge) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.gold500,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.workspace_premium, color: AppColors.forest900, size: 14),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            StreakIndicator(streakDays: user.streakDays),
                                            const SizedBox(width: 8),
                                            XPBadge(xp: user.totalXp),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: AppColors.creamText3),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Tactile Sticky Bottom Banner for Signed-In Learner
                if (currentUser != null)
                  GestureDetector(
                    onTap: () => _showLearnerDetailsDialog(context, currentUser, myRank > 0 ? myRank : 99),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.forest700,
                        border: Border.all(color: AppColors.gold500, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.gold500,
                            child: Text(
                              myRank > 0 ? '#$myRank' : 'Top',
                              style: AppTypography.mono.copyWith(color: AppColors.forest900, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '${currentUser.name} (Your Rank)',
                                        style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 15),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (currentUser.inventory.contains('leaderboard_badge_customizer')) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.gold500,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.workspace_premium, color: AppColors.forest900, size: 14),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  '${currentUser.totalXp} Total XP • ${currentUser.streakDays} Day Streak',
                                  style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                                ),
                              ],
                            ),
                          ),
                          XPBadge(xp: currentUser.totalXp),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodiumUser(BuildContext context, UserModel user, int rank, Color badgeColor) {
    final medalEmoji = rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉');
    final hasCustomBadge = user.inventory.contains('leaderboard_badge_customizer');

    return GestureDetector(
      onTap: () => _showLearnerDetailsDialog(context, user, rank),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Text(medalEmoji, style: const TextStyle(fontSize: 24)),
              if (hasCustomBadge)
                const Positioned(
                  right: -2,
                  top: -2,
                  child: Icon(Icons.workspace_premium, color: AppColors.forest900, size: 14),
                ),
            ],
          ),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: rank == 1 ? 28 : 22,
            backgroundColor: badgeColor,
            child: Text(
              user.name.isNotEmpty ? user.name.substring(0, 1).toUpperCase() : 'L',
              style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 82,
            child: Text(
              user.name,
              style: AppTypography.lessonTitle.copyWith(color: AppColors.forest900, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${user.totalXp} XP',
            style: AppTypography.xpValue.copyWith(color: AppColors.forest900),
          ),
        ],
      ),
    );
  }
}
