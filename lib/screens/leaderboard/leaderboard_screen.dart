import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../models/user_model.dart';
import '../../data/mock_users.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/gamification/xp_badge.dart';
import '../../widgets/gamification/streak_indicator.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                        // Top 3 Podium Card
                        BrandCard(
                          backgroundColor: AppColors.gold500,
                          border: Border.all(color: AppColors.gold700, width: 1.5),
                          child: DefaultTextStyle(
                            style: const TextStyle(color: AppColors.forest900),
                            child: Column(
                              children: [
                                Text(
                                  'GLOBAL TOP LEARNERS',
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

                            return AppCard(
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
                                        Text(
                                          user.name + (isMe ? ' (You)' : ''),
                                          style: AppTypography.lessonTitle.copyWith(
                                            color: isMe ? Colors.white : AppColors.creamText,
                                            fontSize: 16,
                                          ),
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
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Fixed Bottom Banner for Signed-In Learner
                if (currentUser != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.forest700,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
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
                            myRank > 0 ? '#$myRank' : '-',
                            style: AppTypography.mono.copyWith(color: AppColors.forest900, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${currentUser.name} (Your Rank)',
                                style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 15),
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPodiumUser(BuildContext context, UserModel user, int rank, Color badgeColor) {
    final medalEmoji = rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉');

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(medalEmoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: rank == 1 ? 28 : 22,
          backgroundColor: badgeColor,
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 18),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
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
    );
  }
}
