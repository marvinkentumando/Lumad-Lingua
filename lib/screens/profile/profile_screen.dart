import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
import '../../widgets/common/guest_lock_dialog.dart';

ImageProvider? getAvatarImage(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('assets/')) return AssetImage(url);
  if (url.startsWith('/') || url.contains(':')) return FileImage(File(url));
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

  void _showEditProfileOptionsModal(BuildContext context, String currentName, String? currentAvatarUrl) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
      ),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Profile Options', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.gold500),
              title: Text('Edit Display Name', style: AppTypography.bodyLarge),
              subtitle: Text(currentName, style: AppTypography.caption),
              onTap: () {
                Navigator.pop(modalContext);
                _showEditProfileDialog(currentName);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.gold500),
              title: Text('Change Profile Picture', style: AppTypography.bodyLarge),
              subtitle: Text('Upload or select avatar image', style: AppTypography.caption),
              onTap: () {
                Navigator.pop(modalContext);
                _showEditAvatarDialog(currentAvatarUrl);
              },
            ),
          ],
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
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setDialogState(() {
                          avatarController.text = image.path;
                        });
                      }
                    },
                    icon: const Icon(Icons.photo_library, color: AppColors.gold500),
                    label: const Text('Upload Image from Gallery'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.gold500),
                    ),
                  ),
                ),
                if (avatarController.text.isNotEmpty && !characterAssets.contains(avatarController.text) && !avatarController.text.startsWith('assets/')) ...[
                  const SizedBox(height: 8),
                  Text('Selected file: ${avatarController.text.split('/').last}', style: AppTypography.caption.copyWith(color: AppColors.gold400)),
                ],
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

              // Flush User Header (Larger Avatar Circle, Equipped Banner & Frame, Clean Stats Readout)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  children: [
                    if (user?.equippedBanner != null) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD54F), AppColors.gold500, Color(0xFFFFA000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.gold700, width: 2.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.stars, color: AppColors.forest900, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'EQUIPPED PROFILE BANNER',
                              style: AppTypography.labelBold.copyWith(color: AppColors.forest900, letterSpacing: 1.1),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Center(
                      child: Container(
                        padding: (user?.equippedFrame != null) ? const EdgeInsets.all(4) : EdgeInsets.zero,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (user?.equippedFrame != null) ? AppColors.gold500 : AppColors.gold500,
                            width: (user?.equippedFrame != null) ? 5.0 : 3.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (user?.equippedFrame != null) ? AppColors.gold700 : const Color(0xFFB88500),
                              offset: const Offset(0, 4),
                              blurRadius: (user?.equippedFrame != null) ? 8 : 0,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 72,
                          backgroundColor: AppColors.forest500,
                          backgroundImage: getAvatarImage(user?.avatarUrl),
                          child: (user == null || user.avatarUrl == null || user.avatarUrl!.isEmpty)
                              ? Text(
                                  user != null ? user.name.substring(0, 1).toUpperCase() : 'L',
                                  style: AppTypography.displayBold.copyWith(color: Colors.white, fontSize: 52),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      user?.name ?? 'Lumad Learner',
                      style: AppTypography.h2.copyWith(color: AppColors.creamText),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'learner@lumadlingua.com',
                      style: AppTypography.mono.copyWith(color: AppColors.creamText2),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Statistical Readout Row (Streak, Total XP, & Streak Freezes)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/streak'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_fire_department, color: AppColors.terracotta, size: 20),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user?.streakDays ?? 0} ${(user?.streakDays ?? 0) == 1 ? 'Day' : 'Days'}',
                                        style: AppTypography.mono.copyWith(color: isDark ? Colors.white : AppColors.forest900, fontWeight: FontWeight.bold, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text('Streak', style: AppTypography.caption.copyWith(color: isDark ? AppColors.creamBorder : AppColors.forest700, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: isDark ? AppColors.creamBorder.withValues(alpha: 0.4) : AppColors.forest700.withValues(alpha: 0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/xp'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bolt, color: AppColors.gold500, size: 20),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user?.totalXp ?? 250} XP',
                                        style: AppTypography.mono.copyWith(color: isDark ? Colors.white : AppColors.forest900, fontWeight: FontWeight.bold, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text('Total XP', style: AppTypography.caption.copyWith(color: isDark ? AppColors.creamBorder : AppColors.forest700, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: isDark ? AppColors.creamBorder.withValues(alpha: 0.4) : AppColors.forest700.withValues(alpha: 0.3),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/shop'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.diamond, color: AppColors.gold500, size: 20),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${user?.crystals ?? 150}',
                                        style: AppTypography.mono.copyWith(color: isDark ? Colors.white : AppColors.forest900, fontWeight: FontWeight.bold, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text('Crystals', style: AppTypography.caption.copyWith(color: isDark ? AppColors.creamBorder : AppColors.forest700, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
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

              // Dedicated Edit Profile & Avatar Card
              AppCard(
                onTap: isGuest
                    ? () => showGuestLockDialog(
                          context,
                          title: 'Profile Customization Locked 🔒',
                          message: 'Guests cannot customize profile display names or upload avatar photos.',
                        )
                    : () => _showEditProfileOptionsModal(context, user.name, user.avatarUrl),
                child: Row(
                  children: [
                    const Icon(Icons.manage_accounts_rounded, color: AppColors.gold500, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Profile & Avatar', style: AppTypography.h3.copyWith(color: Colors.white)),
                          Text('Update your display name and profile picture', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.gold500),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
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
                      onTap: () {
                        context.push('/classroom/dashboard', extra: {
                          'classId': doc.id,
                          'classroomData': data,
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.school, size: 32, color: AppColors.gold500),
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
                          const Icon(Icons.chevron_right, color: AppColors.gold500),
                        ],
                      ),
                    );
                  }

                  // Not Enrolled: Join Classroom Button Card
                  return BrandCard(
                    onTap: isGuest
                        ? () => showGuestLockDialog(
                              context,
                              title: 'Educator Classroom Locked 🔒',
                              message: 'Guests cannot join teacher classrooms or submit assignments to rosters.',
                            )
                        : () => _showJoinClassroomModal(context),
                    child: Row(
                      children: [
                        const Icon(Icons.school, size: 32, color: AppColors.gold500),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Join a Classroom', style: AppTypography.h3.copyWith(color: Colors.white)),
                              Text('Connect with your educator & classmates', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.gold500),
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
                onTap: () => context.push('/shop'),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, size: 32, color: AppColors.gold500),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Crystal Shop', style: AppTypography.h3.copyWith(color: Colors.white)),
                          Text('Spend crystals on power-ups & avatar frames', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
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
              const SizedBox(height: AppSpacing.md),

              // Auth Button
              BrandButton(
                text: isGuest ? 'Sign In / Register' : 'Sign Out',
                type: isGuest ? BrandButtonType.primary : BrandButtonType.secondary,
                onPressed: () async {
                  if (isGuest) {
                    context.push('/login');
                  } else {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Sign Out', style: AppTypography.h3),
                        content: Text('Are you sure you want to sign out?', style: AppTypography.body),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Sign Out', style: TextStyle(color: AppColors.semanticRed, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Successfully signed out. 👋')),
                        );
                        context.go('/login');
                      }
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
