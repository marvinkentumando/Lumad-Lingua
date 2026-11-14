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
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_logo_emblem.dart';
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
        title: Text('Leave Classroom', style: AppTypography.h3),
        content: Text('Are you sure you want to leave "$className"?', style: AppTypography.body),
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
        title: Text('Learner Profile', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isGuest) ...[
                BrandCard(
                  backgroundColor: AppColors.gold100,
                  border: Border.all(color: AppColors.gold500, width: 1.5),
                  child: Row(
                    children: [
                      const LumadLogoEmblem(size: 44, borderRadius: 12),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Exploring as Guest', style: AppTypography.labelBold.copyWith(fontSize: 15, color: AppColors.creamText)),
                            const SizedBox(height: 2),
                            Text('Sign in to sync your XP, streak & progress', style: AppTypography.caption.copyWith(color: AppColors.creamText2)),
                          ],
                        ),
                      ),
                      BrandButton(
                        text: 'Sign In',
                        type: BrandButtonType.small,
                        onPressed: () => context.push('/login'),
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
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.forest500,
                          child: Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'L',
                            style: AppTypography.displayBold.copyWith(color: Colors.white, fontSize: 32),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.gold500,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.star, size: 16, color: AppColors.forest900),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      user?.name ?? 'Lumad Learner',
                      style: AppTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'learner@lumadlingua.com',
                      style: AppTypography.mono.copyWith(color: AppColors.creamBorder),
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
              Text('My Classrooms', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Join a Classroom', style: AppTypography.labelBold.copyWith(fontSize: 15, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Enter your educator\'s join code (e.g. MANSAKA-482A):', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _joinCodeController,
                            textCapitalization: TextCapitalization.characters,
                            style: AppTypography.mono.copyWith(color: AppColors.creamText, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'CLASS-CODE',
                              hintStyle: AppTypography.mono.copyWith(color: AppColors.creamText3),
                              filled: true,
                              fillColor: AppColors.creamSurface,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                borderSide: const BorderSide(color: AppColors.creamBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                borderSide: const BorderSide(color: AppColors.creamBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                borderSide: const BorderSide(color: AppColors.forest500, width: 2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 130,
                          child: BrandButton(
                            text: 'Join Class',
                            type: BrandButtonType.gold,
                            isLoading: _isJoining,
                            onPressed: isGuest ? () => context.push('/login') : _joinClassroom,
                          ),
                        ),
                      ],
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: const TextStyle(color: AppColors.semanticRed, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                    if (_successMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_successMessage!, style: const TextStyle(color: AppColors.semanticGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                    const Divider(height: 24, color: AppColors.creamBorder),
                    Text('Enrolled Classes', style: AppTypography.labelBold.copyWith(fontSize: 15, color: Colors.white)),
                    const SizedBox(height: AppSpacing.xs),
                    classroomsAsync.when(
                      data: (snapshot) {
                        final docs = snapshot.docs;
                        if (docs.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'You are not enrolled in any classrooms yet. Enter a code above to join your teacher\'s class!',
                              style: AppTypography.body.copyWith(color: AppColors.creamBorder, fontStyle: FontStyle.italic),
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
                                          child: Text(
                                            className,
                                            style: AppTypography.h3.copyWith(color: AppColors.creamText),
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
                                    Text('School / Center: $school', style: AppTypography.body.copyWith(color: AppColors.creamText2)),
                                    Text('Educator: $educator', style: AppTypography.mono.copyWith(color: AppColors.creamText3)),
                                    if (assignedUnits > 0) ...[
                                      const SizedBox(height: 6),
                                      Chip(
                                        label: Text('$assignedUnits Assigned Units', style: AppTypography.labelBold.copyWith(color: AppColors.gold800)),
                                        backgroundColor: AppColors.gold100,
                                        side: const BorderSide(color: AppColors.gold300),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold500)),
                      error: (e, _) => Text('Error loading classrooms: $e', style: const TextStyle(color: AppColors.semanticRed)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Statistics Section
              Text('Learning Statistics', style: AppTypography.h3),
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

              // Achievements Shortcut
              AppCard(
                onTap: () => context.push('/achievements'),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.gold500, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Achievements & Badges', style: AppTypography.h3.copyWith(color: Colors.white)),
                          Text('View your earned badges and rewards', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.gold500),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Global Leaderboard Shortcut
              AppCard(
                onTap: () => context.push('/leaderboard'),
                child: Row(
                  children: [
                    const Icon(Icons.leaderboard, color: AppColors.gold500, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Global Leaderboard', style: AppTypography.h3.copyWith(color: Colors.white)),
                          Text('See top Mansaka learners worldwide', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.gold500),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Settings Shortcut
              AppCard(
                onTap: () => context.push('/settings'),
                child: Row(
                  children: [
                    const Icon(Icons.settings_outlined, color: AppColors.gold500, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('App Settings', style: AppTypography.h3.copyWith(color: Colors.white)),
                          Text('Preferences, audio & notifications', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.gold500),
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
