import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/classroom_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';
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
        title: const Text('Leave Classroom'),
        content: Text('Are you sure you want to leave "${classroomData['name'] ?? 'Classroom'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave', style: TextStyle(color: AppColors.semanticRed)),
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
        title: Text(className),
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
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor(context),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold500.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                            border: Border.all(color: AppColors.gold500),
                          ),
                          child: Text(
                            'Code: $joinCode',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.school, size: 16, color: AppColors.forestGreen),
                        const SizedBox(width: 8),
                        Text(
                          school,
                          style: TextStyle(fontSize: 14, color: AppColors.subtitleColor(context)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: AppColors.forestGreen),
                        const SizedBox(width: 8),
                        Text(
                          'Educator: $educator',
                          style: TextStyle(fontSize: 13, color: AppColors.subtitleColor(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Class Roster / Leaderboard Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Class Roster & Leaderboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Chip(
                    label: Text('${studentIds.length} Enrolled'),
                    backgroundColor: AppColors.forestGreen.withValues(alpha: 0.2),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              studentIds.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'No students enrolled yet.',
                          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
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
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text('Loading student roster...');
                        }

                        final students = snapshot.data!.docs.map((doc) => doc.data()).toList();
                        // Sort by totalXp descending
                        students.sort((a, b) => (b['totalXp'] ?? 0).compareTo(a['totalXp'] ?? 0));

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: students.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final name = student['name'] ?? 'Learner';
                            final xp = student['totalXp'] ?? 0;
                            final streak = student['streakDays'] ?? 0;
                            final rank = index + 1;

                            return AppCard(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: rank == 1
                                        ? AppColors.gold500
                                        : (rank == 2 ? Colors.grey[400] : (rank == 3 ? Colors.brown[300] : AppColors.forestGreen)),
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
                                          name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
}
