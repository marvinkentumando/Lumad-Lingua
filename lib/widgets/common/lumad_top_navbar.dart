import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import 'lumad_logo_emblem.dart';
import '../gamification/xp_badge.dart';
import '../gamification/streak_indicator.dart';

ImageProvider? getAvatarImage(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('assets/')) return AssetImage(url);
  return NetworkImage(url);
}

class LumadTopNavbar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final bool showGreeting;

  const LumadTopNavbar({
    super.key,
    this.title,
    this.showGreeting = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;

    return AppBar(
      backgroundColor: AppColors.forest700,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: AppSpacing.md,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const LumadLogoEmblem(size: 36, borderRadius: 10),
          Row(
            children: [
              StreakIndicator(
                streakDays: user?.streakDays ?? 3,
                onTap: () => context.push('/streaks-xp'),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.push('/shop'),
                child: XPBadge(xp: user?.totalXp ?? 250),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.gold500,
                  backgroundImage: getAvatarImage(user?.avatarUrl),
                  child: (user == null || user.avatarUrl == null || user.avatarUrl!.isEmpty)
                      ? Text(
                          (user != null && user.name.isNotEmpty)
                              ? user.name.substring(0, 1).toUpperCase()
                              : 'L',
                          style: AppTypography.labelBold.copyWith(
                            color: AppColors.forest900,
                            fontSize: 13,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
