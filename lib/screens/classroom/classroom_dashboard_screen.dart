import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/classroom_provider.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final className = classroomData['name'] ?? 'Classroom Dashboard';
    final school = classroomData['schoolOrCenter'] ?? 'School / Center';
    final educator = classroomData['educatorEmail'] ?? 'Educator';
    final joinCode = classroomData['joinCode'] ?? 'CODE';
    final studentIds = List<String>.from(classroomData['studentIds'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text(className, style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Classroom Header Card
              AppCard(
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold500,
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                            border: Border.all(color: AppColors.gold700),
                          ),
                          child: Text(
                            'Code: $joinCode',
                            style: AppTypography.labelBold.copyWith(color: AppColors.forest900),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: AppColors.gold500),
                        const SizedBox(width: 8),
                        Text(
                          'Educator: $educator',
                          style: AppTypography.mono.copyWith(color: AppColors.creamBorder, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
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
                        students.sort((a, b) => (b['totalXp'] ?? 0).compareTo(a['totalXp'] ?? 0));

                        final top1 = students.isNotEmpty ? students[0] : null;
                        final top2 = students.length > 1 ? students[1] : null;
                        final top3 = students.length > 2 ? students[2] : null;
                        final rest = students.length > 3 ? students.sublist(3) : <Map<String, dynamic>>[];

                        return Column(
                          children: [
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
                                        if (top2 != null) _buildPodiumUser(top2, 2, AppColors.forest700),
                                        if (top1 != null) _buildPodiumUser(top1, 1, AppColors.forest900),
                                        if (top3 != null) _buildPodiumUser(top3, 3, AppColors.forest700),
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
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
              const SizedBox(height: AppSpacing.xxl),

              // Classroom Actions
              BrandButton(
                text: 'Leave Classroom',
                type: BrandButtonType.danger,
                onPressed: () => _leaveClass(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumUser(Map<String, dynamic> student, int rank, Color badgeColor) {
    final name = student['name'] ?? 'Learner';
    final xp = student['totalXp'] ?? 0;
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
            name.substring(0, 1).toUpperCase(),
            style: AppTypography.displayNumber.copyWith(color: Colors.white, fontSize: 18),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
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
    );
  }
}
