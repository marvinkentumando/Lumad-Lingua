import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/constants.dart';
import '../../models/user_model.dart';
import '../../data/mock_users.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/gamification/xp_badge.dart';
import '../../widgets/gamification/streak_indicator.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Leaderboard'),
      ),
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
            return const Center(child: Text('No learners found on the leaderboard yet.'));
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
                        AppCard(
                          backgroundColor: AppColors.gold500.withValues(alpha: 0.15),
                          border: Border.all(color: AppColors.gold500, width: 1.5),
                          child: Column(
                            children: [
                              const Text(
                                'GLOBAL TOP LEARNERS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: AppColors.gold500,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Rank 2 (Silver)
                                  if (top2 != null) _buildPodiumUser(context, top2, 2, Colors.grey[400]!, 70),

                                  // Rank 1 (Gold)
                                  if (top1 != null) _buildPodiumUser(context, top1, 1, AppColors.gold500, 90),

                                  // Rank 3 (Bronze)
                                  if (top3 != null) _buildPodiumUser(context, top3, 3, Colors.brown[300]!, 65),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Leaderboard Roster Header
                        const Text(
                          'Rankings',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
                              backgroundColor: isMe ? AppColors.forestGreen.withValues(alpha: 0.15) : AppColors.cardColor(context),
                              border: isMe ? Border.all(color: AppColors.forestGreen, width: 1.5) : null,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.forestGreen,
                                    child: Text(
                                      '#$rank',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name + (isMe ? ' (You)' : ''),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.textColor(context),
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
                      color: AppColors.forest500,
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
                            style: const TextStyle(color: AppColors.forest900, fontWeight: FontWeight.bold, fontSize: 13),
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
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                '${currentUser.totalXp} Total XP • ${currentUser.streakDays} Day Streak',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildPodiumUser(BuildContext context, UserModel user, int rank, Color badgeColor, double height) {
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
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            user.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.textColor(context),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${user.totalXp} XP',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.gold500),
        ),
      ],
    );
  }
}
