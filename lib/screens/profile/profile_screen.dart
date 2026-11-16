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
import '../../widgets/common/lumad_background.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isGuest = user == null;
    final achievementsAsync = ref.watch(achievementsProvider);
    final classroomsAsync = ref.watch(myClassroomsStreamProvider);

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
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

              // Flush User Header (Larger Avatar Circle & Clean Stats Readout)
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
                    const SizedBox(height: AppSpacing.md),
                    // Statistical Readout Row (Streak & Total XP)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => context.push('/streak'),
                          child: Row(
                            children: [
                              const Icon(Icons.local_fire_department, color: AppColors.terracotta, size: 22),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user?.streakDays ?? 3} Days',
                                    style: AppTypography.mono.copyWith(color: isDark ? Colors.white : AppColors.forest900, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text('Streak', style: AppTypography.caption.copyWith(color: isDark ? AppColors.creamBorder : AppColors.forest700, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 28,
                          width: 1,
                          color: isDark ? AppColors.creamBorder.withValues(alpha: 0.4) : AppColors.forest700.withValues(alpha: 0.3),
                          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/xp'),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt, color: AppColors.gold500, size: 22),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user?.totalXp ?? 250} XP',
                                    style: AppTypography.mono.copyWith(color: isDark ? Colors.white : AppColors.forest900, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text('Total XP', style: AppTypography.caption.copyWith(color: isDark ? AppColors.creamBorder : AppColors.forest700, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
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
                                    style: AppTypography.labelBold.copyWith(fontSize: 11, color: AppColors.forest900),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    ach.isUnlocked ? 'Unlocked' : '${(ach.progressRatio * 100).toInt()}%',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 10,
                                      color: AppColors.forest800,
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

              // Journey Management Section & Classroom Shortcut Button Card
              Text('Journey Management', style: AppTypography.h3),
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

                    return BrandCard(
                      backgroundColor: AppColors.gold500,
                      onTap: () {
                        context.push('/classroom/dashboard', extra: {
                          'classId': doc.id,
                          'classroomData': data,
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.school, size: 32, color: AppColors.forest900),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(className, style: AppTypography.h3.copyWith(color: AppColors.forest900)),
                                Text('School / Center: $school', style: AppTypography.caption.copyWith(color: AppColors.forest800)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.forest900),
                        ],
                      ),
                    );
                  }

                  // Not Enrolled: Join Classroom Button Card
                  return BrandCard(
                    backgroundColor: AppColors.gold500,
                    onTap: isGuest ? () => context.push('/login') : () => _showJoinClassroomModal(context),
                    child: Row(
                      children: [
                        const Icon(Icons.school, size: 32, color: AppColors.forest900),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Join a Classroom', style: AppTypography.h3.copyWith(color: AppColors.forest900)),
                              Text('Connect with your educator & classmates', style: AppTypography.caption.copyWith(color: AppColors.forest800)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.forest900),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold500)),
                error: (e, _) => Text('Error loading classroom: $e', style: const TextStyle(color: AppColors.semanticRed)),
              ),
              const SizedBox(height: AppSpacing.md),

              // Crystal Shop Shortcut
              BrandCard(
                backgroundColor: AppColors.gold500,
                onTap: () => context.push('/shop'),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, size: 32, color: AppColors.forest900),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Crystal Shop', style: AppTypography.h3.copyWith(color: AppColors.forest900)),
                          Text('Spend crystals on power-ups & avatar frames', style: AppTypography.caption.copyWith(color: AppColors.forest800)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.forest900),
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
    ),
  );
  }
}
