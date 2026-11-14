import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/classroom_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/gamification/xp_badge.dart';
import '../../widgets/gamification/streak_indicator.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _joinCodeController = TextEditingController();
  bool _isJoining = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinClassroom() async {
    final code = _joinCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a valid class join code.');
      return;
    }

    setState(() {
      _isJoining = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final service = ref.read(classroomServiceProvider);
      final result = await service.joinClassroomByCode(code);
      if (mounted) {
        setState(() {
          _isJoining = false;
          _successMessage = 'Successfully joined "${result['name'] ?? 'Classroom'}"!';
          _joinCodeController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isJoining = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _leaveClassroom(String classId, String className) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Classroom'),
        content: Text('Are you sure you want to leave "$className"?'),
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully left the classroom.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error leaving classroom: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isGuest = user == null;
    final progressAsync = ref.watch(userProgressProvider);
    final classroomsAsync = ref.watch(myClassroomsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner Profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isGuest) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreenBackground,
                    borderRadius: BorderRadius.circular(AppRadius.modal),
                    border: Border.all(color: AppColors.brightGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle, color: AppColors.forestGreen, size: 36),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Exploring as Guest',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              'Sign in to sync your XP, streak & progress',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              // User Header Card
              AppCard(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.forestGreen,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'L',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      user?.name ?? 'Lumad Learner',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor(context),
                      ),
                    ),
                    Text(
                      user?.email ?? 'learner@lumadlingua.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.subtitleColor(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreakIndicator(streakDays: user?.streakDays ?? 3),
                        const SizedBox(width: 12),
                        XPBadge(xp: user?.totalXp ?? 250),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Classroom Dashboard Section
              const Text(
                'My Classrooms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join a Classroom',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter your educator\'s join code (e.g. MANSAKA-482A):',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _joinCodeController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'CLASS-CODE',
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 130,
                          child: BrandButton(
                            text: 'Join Class',
                            type: BrandButtonType.primary,
                            isLoading: _isJoining,
                            onPressed: isGuest ? () => context.push('/login') : _joinClassroom,
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: const TextStyle(color: AppColors.semanticRed, fontSize: 12)),
                    ],
                    if (_successMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_successMessage!, style: const TextStyle(color: AppColors.semanticGreen, fontSize: 12)),
                    ],
                    const Divider(height: 24),
                    const Text(
                      'Enrolled Classes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    classroomsAsync.when(
                      data: (snapshot) {
                        final docs = snapshot.docs;
                        if (docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'You are not enrolled in any classrooms yet.',
                              style: TextStyle(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final doc = docs[index];
                            final data = doc.data();
                            final className = data['name'] ?? 'Classroom';
                            final school = data['schoolOrCenter'] ?? 'School / Center';
                            final educator = data['educatorEmail'] ?? 'Educator';
                            final assignedUnits = (data['assignedUnitIds'] as List<dynamic>?)?.length ?? 0;

                            return InkWell(
                              onTap: () {
                                context.push('/classroom/dashboard', extra: {
                                  'classId': doc.id,
                                  'classroomData': data,
                                });
                              },
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGreenBackground,
                                  borderRadius: BorderRadius.circular(AppRadius.card),
                                  border: Border.all(color: AppColors.border),
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
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ),
                                        BrandButton(
                                          text: 'Leave',
                                          type: BrandButtonType.danger,
                                          onPressed: () => _leaveClassroom(doc.id, className),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('School / Center: $school', style: const TextStyle(fontSize: 13)),
                                    Text('Educator: $educator', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    if (assignedUnits > 0) ...[
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text('$assignedUnits Assigned Units', style: const TextStyle(fontSize: 11)),
                                        backgroundColor: AppColors.gold500.withValues(alpha: 0.3),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error loading classrooms: $e', style: const TextStyle(color: AppColors.semanticRed)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Statistics Section
              const Text(
                'Learning Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.sm),
              progressAsync.when(
                data: (progress) => Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.forestGreen, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              '${progress.totalLessonsCompleted}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Lessons Done', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Icon(Icons.star_outline, color: AppColors.warmYellow, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              '${(progress.overallMasteryPercentage * 100).toInt()}%',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const Text('Mastery Rate', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error loading stats: $e'),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Achievements Shortcut
              AppCard(
                onTap: () => context.push('/achievements'),
                child: Row(
                  children: const [
                    Icon(Icons.emoji_events, color: AppColors.warmYellow, size: 32),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Achievements & Badges',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'View your earned badges and rewards',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.forestGreen),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Settings Shortcut
              AppCard(
                onTap: () => context.push('/settings'),
                child: Row(
                  children: const [
                    Icon(Icons.settings_outlined, color: AppColors.forestGreen, size: 32),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'App Settings',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Preferences, audio & notifications',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.forestGreen),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Auth Button
              AppButton(
                text: isGuest ? 'Sign In / Register' : 'Sign Out',
                variant: isGuest ? AppButtonVariant.primary : AppButtonVariant.outline,
                onPressed: () async {
                  if (isGuest) {
                    context.push('/login');
                  } else {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/home');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
