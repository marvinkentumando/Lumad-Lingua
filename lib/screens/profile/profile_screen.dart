import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/classroom_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_logo_emblem.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/gamification/xp_badge.dart';
import '../../widgets/gamification/streak_indicator.dart';

ImageProvider? getAvatarImage(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('assets/')) return AssetImage(url);
  return NetworkImage(url);
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _joinCodeController = TextEditingController();
  bool _isJoining = false;
  String? _errorMessage;

  @override
  void dispose() {
    _joinCodeController.dispose();
    super.dispose();
  }

  void _showJoinClassroomModal(BuildContext context) {
    _joinCodeController.clear();
    setState(() {
      _errorMessage = null;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
      ),
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (bottomSheetContext, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Join Educator Classroom', style: AppTypography.h2.copyWith(color: AppColors.creamText)),
              const SizedBox(height: 4),
              Text('Enter your educator\'s class join code (e.g. MANSAKA-482A):', style: AppTypography.body.copyWith(color: AppColors.creamText2)),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _joinCodeController,
                textCapitalization: TextCapitalization.characters,
                style: AppTypography.mono.copyWith(color: AppColors.creamText, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'CLASS-CODE',
                  hintStyle: AppTypography.mono.copyWith(color: AppColors.creamText3),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: const TextStyle(color: AppColors.semanticRed, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: AppSpacing.lg),
              BrandButton(
                text: 'Submit Join Code',
                type: BrandButtonType.gold,
                isLoading: _isJoining,
                onPressed: () async {
                  final code = _joinCodeController.text.trim();
                  if (code.isEmpty) {
                    setModalState(() => _errorMessage = 'Please enter a valid join code.');
                    return;
                  }
                  setModalState(() => _isJoining = true);
                  try {
                    final service = ref.read(classroomServiceProvider);
                    final result = await service.joinClassroomByCode(code);
                    if (bottomSheetContext.mounted && context.mounted) {
                      Navigator.of(bottomSheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Successfully joined "${result['name'] ?? 'Classroom'}"! 🎉')),
                      );
                    }
                  } catch (e) {
                    setModalState(() {
                      _isJoining = false;
                      _errorMessage = e.toString().replaceFirst('Exception: ', '');
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _leaveClassroom(String classId, String className) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Classroom', style: AppTypography.h3),
        content: Text('Are you sure you want to leave "$className"? You will be able to join another classroom afterward.', style: AppTypography.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave Class', style: TextStyle(color: AppColors.semanticRed, fontWeight: FontWeight.bold)),
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

  void _showEditProfileDialog(String currentName) {
    final nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile Name', style: AppTypography.h3),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          BrandButton(
            text: 'Save',
            type: BrandButtonType.primary,
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  final updated = user.copyWith(name: newName);
                  await ref.read(authStateProvider.notifier).updateUser(updated);
                }
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showCulturalAffiliationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.eco, color: AppColors.gold500, size: 28),
            const SizedBox(width: 8),
            Text('Cultural Affiliation', style: AppTypography.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are registered as a cultural preservation learner within the Mansaka indigenous community ecosystem.',
              style: AppTypography.body,
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold100,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.gold500),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Community: Mansaka Tribe', style: AppTypography.labelBold.copyWith(color: AppColors.forest900)),
                  const SizedBox(height: 2),
                  Text('Region: Compostela Valley / Davao de Oro', style: AppTypography.caption.copyWith(color: AppColors.forest800)),
                  const SizedBox(height: 2),
                  Text('Status: Active Cultural Heritage Learner', style: AppTypography.caption.copyWith(color: AppColors.forest800)),
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

  void _showEditAvatarDialog(String? currentAvatarUrl) {
    final avatarController = TextEditingController(text: currentAvatarUrl ?? '');
    final List<String> characterAssets = [
      'assets/images/lumad_character.png',
      'assets/images/lumad_character(1).png',
      'assets/images/lumad_character(2).png',
      'assets/images/lumad_character(3).png',
      'assets/images/lumad_character(4).png',
      'assets/images/lumad_character(5).png',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('Profile Photo & Lumad Characters', style: AppTypography.h3),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select pre-made Lumad Character:', style: AppTypography.labelBold),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  width: 300,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: characterAssets.length,
                    itemBuilder: (context, index) {
                      final assetPath = characterAssets[index];
                      final isSelected = avatarController.text == assetPath;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            avatarController.text = assetPath;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected ? AppColors.gold500 : Colors.transparent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.asset(
                              assetPath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 32),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Or enter custom image URL:', style: AppTypography.caption),
                const SizedBox(height: 6),
                TextField(
                  controller: avatarController,
                  decoration: const InputDecoration(
                    labelText: 'Image / Photo URL',
                    hintText: 'https://...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            BrandButton(
              text: 'Save Photo',
              type: BrandButtonType.primary,
              onPressed: () async {
                final newUrl = avatarController.text.trim();
                final user = ref.read(authStateProvider).value;
                if (user != null) {
                  final updated = user.copyWith(avatarUrl: newUrl.isNotEmpty ? newUrl : null);
                  await ref.read(authStateProvider.notifier).updateUser(updated);
                }
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isGuest = user == null;
    final progressAsync = ref.watch(userProgressProvider);
    final achievementsAsync = ref.watch(achievementsProvider);
    final classroomsAsync = ref.watch(myClassroomsStreamProvider);
    final inventory = user?.inventory ?? [];

    return Scaffold(
      appBar: const LumadTopNavbar(),
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

              // Flush User Header (Larger Avatar Circle)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: isGuest ? null : () => _showEditAvatarDialog(user.avatarUrl),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: AppColors.forest500,
                              backgroundImage: getAvatarImage(user?.avatarUrl),
                              child: (user == null || user.avatarUrl == null || user.avatarUrl!.isEmpty)
                                  ? Text(
                                      user != null ? user.name.substring(0, 1).toUpperCase() : 'L',
                                      style: AppTypography.displayBold.copyWith(color: Colors.white, fontSize: 44),
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.gold500,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 20, color: AppColors.forest900),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user?.name ?? 'Lumad Learner',
                          style: AppTypography.h2.copyWith(color: AppColors.creamText),
                        ),
                        if (!isGuest) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.gold500, size: 20),
                            onPressed: () => _showEditProfileDialog(user.name),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'learner@lumadlingua.com',
                      style: AppTypography.mono.copyWith(color: AppColors.creamText2),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: _showCulturalAffiliationDialog,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Mansaka Tribe',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.gold500,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreakIndicator(
                          streakDays: user?.streakDays ?? 3,
                          onTap: () => context.push('/streaks-xp'),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => context.push('/shop'),
                          child: XPBadge(xp: user?.totalXp ?? 250),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Recent Achievements Showcase (Dynamic from achievementsProvider)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Achievements', style: AppTypography.h3),
                  TextButton(
                    onPressed: () => context.push('/achievements'),
                    child: Text('View All', style: AppTypography.labelBold.copyWith(color: AppColors.gold500)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              achievementsAsync.when(
                data: (achievements) {
                  final previewList = achievements.take(3).toList();
                  if (previewList.isEmpty) return const SizedBox.shrink();

                  return Row(
                    children: previewList.map((ach) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: SizedBox(
                            height: 115,
                            child: BrandCard(
                              backgroundColor: AppColors.gold500,
                              onTap: () => context.push('/achievements'),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(ach.resolvedEmoji, style: const TextStyle(fontSize: 26)),
                                  const SizedBox(height: 4),
                                  Text(
                                    ach.title,
                                    style: AppTypography.labelBold.copyWith(fontSize: 11),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    ach.isUnlocked ? 'Unlocked' : '${(ach.progressRatio * 100).toInt()}%',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator(color: AppColors.gold500))),
                error: (err, stack) => const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Active Inventory Passes Showcase
              if (inventory.isNotEmpty) ...[
                Text('Active Shop Passes & Inventory', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: inventory.map((item) {
                      return Chip(
                        avatar: const Icon(Icons.verified, color: AppColors.gold500, size: 16),
                        label: Text(item.replaceAll('_', ' ').toUpperCase(), style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 11)),
                        backgroundColor: AppColors.gold500,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Classroom Section (Single-Classroom Restricted Button Card)
              Text('My Classroom', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              classroomsAsync.when(
                data: (snapshot) {
                  final docs = snapshot.docs;
                  final isEnrolled = docs.isNotEmpty;

                  if (isEnrolled) {
                    final doc = docs.first;
                    final data = doc.data();
                    final className = data['name'] ?? 'Classroom';
                    final school = data['schoolOrCenter'] ?? 'School / Center';

                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.school, color: AppColors.gold500, size: 28),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(className, style: AppTypography.h3.copyWith(color: Colors.white)),
                                    Text('School / Center: $school', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gold500,
                                  borderRadius: BorderRadius.circular(AppRadius.chip),
                                ),
                                child: Text('ENROLLED', style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 10)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: BrandButton(
                                  text: 'View Class Dashboard',
                                  type: BrandButtonType.gold,
                                  onPressed: () {
                                    context.push('/classroom/dashboard', extra: {
                                      'classId': doc.id,
                                      'classroomData': data,
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 90,
                                child: BrandButton(
                                  text: 'Leave',
                                  type: BrandButtonType.danger,
                                  onPressed: () => _leaveClassroom(doc.id, className),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  // Not Enrolled: Compact Join Classroom Button Card
                  return AppCard(
                    onTap: isGuest ? () => context.push('/login') : () => _showJoinClassroomModal(context),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.gold500.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.school, color: AppColors.gold500, size: 28),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Join a Classroom', style: AppTypography.h3.copyWith(color: Colors.white)),
                              const SizedBox(height: 2),
                              Text('Enter your educator\'s join code to connect', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                            ],
                          ),
                        ),
                        const Icon(Icons.add_circle_outline, color: AppColors.gold500, size: 28),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold500)),
                error: (e, _) => Text('Error loading classroom: $e', style: const TextStyle(color: AppColors.semanticRed)),
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
              BrandCard(
                backgroundColor: AppColors.gold500,
                onTap: () => context.push('/achievements'),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Achievements & Badges', style: AppTypography.h3),
                          Text('View your earned badges and rewards', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Crystal Shop & Passes Shortcut
              BrandCard(
                backgroundColor: AppColors.gold500,
                onTap: () => context.push('/shop'),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Crystal Shop & Passes', style: AppTypography.h3),
                          Text('Spend crystals on power-ups & inventory passes', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
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
              const SizedBox(height: AppSpacing.md),

              // Auth Button
              BrandButton(
                text: isGuest ? 'Sign In / Register' : 'Sign Out',
                type: isGuest ? BrandButtonType.primary : BrandButtonType.secondary,
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
