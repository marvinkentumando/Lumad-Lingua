import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../utils/level_helper.dart';
import '../../providers/classroom_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/gamification/xp_badge.dart';
import '../../widgets/gamification/streak_indicator.dart';

class ClassroomDashboardScreen extends ConsumerWidget {
  final String classId;
  final Map<String, dynamic> classroomData;

  const ClassroomDashboardScreen({
    super.key,
    required this.classId,
    required this.classroomData,
  });

  Future<void> _leaveClass(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Classroom', style: AppTypography.h3),
        content: Text('Are you sure you want to leave "${classroomData['name'] ?? 'Classroom'}"?', style: AppTypography.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave', style: TextStyle(color: AppColors.semanticRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final service = ref.read(classroomServiceProvider);
        await service.leaveClassroom(classId);
        if (context.mounted) {
          context.pop(); // return to profile
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully left the classroom.')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error leaving classroom: $e')),
          );
        }
      }
    }
  }

  void _showStudentDetailsDialog(BuildContext context, Map<String, dynamic> student, int rank) {
    HapticFeedback.lightImpact();
    final name = student['name'] ?? 'Learner';
    final xp = student['totalXp'] ?? 0;
    final streak = student['streakDays'] ?? 0;
    final level = LevelHelper.calculateLevel(xp);

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
              radius: 20,
              backgroundColor: AppColors.gold500,
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'L',
                style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 16),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTypography.h3.copyWith(color: Colors.white)),
                  Text('Classroom Rank #$rank', style: AppTypography.caption.copyWith(color: AppColors.gold400, fontWeight: FontWeight.bold)),
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
                      XPBadge(xp: xp),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Streak', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                      StreakIndicator(streakDays: streak),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final className = classroomData['name'] ?? 'Classroom Dashboard';
    final school = classroomData['schoolOrCenter'] ?? 'School / Center';
    final joinCode = classroomData['joinCode'] ?? 'CODE';
    final studentIds = List<String>.from(classroomData['studentIds'] ?? []);
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(className, style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white70),
            onSelected: (value) {
              if (value == 'leave') {
                _leaveClass(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'leave',
                child: Row(
                  children: [
                    Icon(Icons.exit_to_app, color: AppColors.semanticRed, size: 20),
                    SizedBox(width: 8),
                    Text('Leave Classroom', style: TextStyle(color: AppColors.semanticRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3D Tactile Classroom Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E5A36), AppColors.forest500, Color(0xFF142917)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF0A140B),
                      offset: Offset(0, 6),
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
                            className,
                            style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 22),
                          ),
                        ),
                        // 3D Tactile Copy Join Code Pill Button
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: joinCode));
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied class join code "$joinCode" to clipboard! 📋')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gold500,
                              borderRadius: BorderRadius.circular(AppRadius.chip),
                              border: Border.all(color: AppColors.gold700, width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFB88500),
                                  offset: Offset(0, 3),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Code: $joinCode',
                                  style: AppTypography.labelBold.copyWith(color: AppColors.forest900),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.copy_rounded, size: 14, color: AppColors.forest900),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.school, size: 16, color: AppColors.gold500),
                        const SizedBox(width: 8),
                        Text(
                          school,
                          style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Learning Statistics Section (Lessons Done & Mastery Rate)
              Text('My Classroom Progress', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              progressAsync.when(
                data: (progress) => Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.gold500, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              '${progress.totalLessonsCompleted}',
                              style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 28),
                            ),
                            Text('Lessons Done', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Icon(Icons.star_outline, color: AppColors.gold500, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              '${(progress.overallMasteryPercentage * 100).toInt()}%',
                              style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 28),
                            ),
                            Text('Mastery Rate', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold500)),
                error: (e, _) => Text('Error loading stats: $e', style: const TextStyle(color: AppColors.semanticRed)),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Class Roster & Leaderboard Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Class Leaderboard', style: AppTypography.h3),
                  Chip(
                    label: Text('${studentIds.length} Enrolled', style: AppTypography.labelBold.copyWith(color: AppColors.gold800)),
                    backgroundColor: AppColors.gold100,
                    side: const BorderSide(color: AppColors.gold300),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              studentIds.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'No students enrolled yet.',
                          style: AppTypography.body.copyWith(color: AppColors.creamBorder, fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .where(FieldPath.documentId, whereIn: studentIds.length <= 10 ? studentIds : studentIds.sublist(0, 10))
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.gold500));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text('Loading student roster...', style: AppTypography.body);
                        }

                        final students = snapshot.data!.docs.map((doc) => doc.data()).toList();
                        
                        final totalClassXp = students.fold<int>(0, (acc, s) => acc + ((s['totalXp'] ?? 0) as num).toInt());
                        final avgStreak = students.isEmpty ? 0.0 : students.fold<int>(0, (acc, s) => acc + ((s['streakDays'] ?? 0) as num).toInt()) / students.length;
                        final targetXp = (students.length * 500).clamp(5000, 50000);
                        final milestoneProgress = (totalClassXp / targetXp).clamp(0.0, 1.0);

                        students.sort((a, b) => (b['totalXp'] ?? 0).compareTo(a['totalXp'] ?? 0));

                        final top1 = students.isNotEmpty ? students[0] : null;
                        final top2 = students.length > 1 ? students[1] : null;
                        final top3 = students.length > 2 ? students[2] : null;
                        final rest = students.length > 3 ? students.sublist(3) : <Map<String, dynamic>>[];

                        return Column(
                          children: [
                            // Advanced Class Analytics Card
                            BrandCard(
                              backgroundColor: AppColors.forest800,
                              border: Border.all(color: AppColors.gold500, width: 1.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.analytics, color: AppColors.gold500, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Class Community Analytics', style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 18)),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.forest900,
                                            borderRadius: BorderRadius.circular(AppRadius.card),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Total Class XP', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                                              const SizedBox(height: 4),
                                              Text('$totalClassXp XP', style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 18)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.forest900,
                                            borderRadius: BorderRadius.circular(AppRadius.card),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Avg Streak', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                                              const SizedBox(height: 4),
                                              Text('${avgStreak.toStringAsFixed(1)} Days', style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 18)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Milestone Goal ($targetXp XP)', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                                          Text('${(milestoneProgress * 100).toInt()}%', style: AppTypography.labelBold.copyWith(color: AppColors.gold400)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: milestoneProgress,
                                          minHeight: 10,
                                          backgroundColor: AppColors.forest900,
                                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Class Top 3 Podium Card
                            BrandCard(
                              backgroundColor: AppColors.gold500,
                              border: Border.all(color: AppColors.gold700, width: 1.5),
                              child: DefaultTextStyle(
                                style: const TextStyle(color: AppColors.forest900),
                                child: Column(
                                  children: [
                                    Text(
                                      'CLASS CHAMPIONS',
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
                                        if (top2 != null) _buildPodiumUser(context, top2, 2, AppColors.forest700),
                                        if (top1 != null) _buildPodiumUser(context, top1, 1, AppColors.forest900),
                                        if (top3 != null) _buildPodiumUser(context, top3, 3, AppColors.forest700),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Remaining Roster (#4 and beyond)
                            if (rest.isNotEmpty)
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: rest.length,
                                separatorBuilder: (_, index) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final student = rest[index];
                                  final name = student['name'] ?? 'Learner';
                                  final xp = student['totalXp'] ?? 0;
                                  final streak = student['streakDays'] ?? 0;
                                  final rank = index + 4;

                                  return AppCard(
                                    onTap: () => _showStudentDetailsDialog(context, student, rank),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: const BoxDecoration(
                                            color: AppColors.forest700,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '#$rank',
                                              style: AppTypography.mono.copyWith(
                                                color: Colors.white,
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
                                                name,
                                                style: AppTypography.lessonTitle.copyWith(color: Colors.white, fontSize: 16),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  StreakIndicator(streakDays: streak),
                                                  const SizedBox(width: 8),
                                                  XPBadge(xp: xp),
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
                        );
                      },
                    ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumUser(BuildContext context, Map<String, dynamic> student, int rank, Color badgeColor) {
    final name = student['name'] ?? 'Learner';
    final xp = student['totalXp'] ?? 0;
    final medalEmoji = rank == 1 ? '🥇' : (rank == 2 ? '🥈' : '🥉');

    return GestureDetector(
      onTap: () => _showStudentDetailsDialog(context, student, rank),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(medalEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          CircleAvatar(
            radius: rank == 1 ? 28 : 22,
            backgroundColor: badgeColor,
            child: Text(
              name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'L',
              style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 82,
            child: Text(
              name,
              style: AppTypography.lessonTitle.copyWith(color: AppColors.forest900, fontSize: 13),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$xp XP',
            style: AppTypography.xpValue.copyWith(color: AppColors.forest900),
          ),
        ],
      ),
    );
  }
}
