import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';

class StreakDashboardScreen extends ConsumerStatefulWidget {
  const StreakDashboardScreen({super.key});

  @override
  ConsumerState<StreakDashboardScreen> createState() => _StreakDashboardScreenState();
}

class _StreakDashboardScreenState extends ConsumerState<StreakDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final streak = user?.streakDays ?? 0;
    final longestStreak = user?.streakDays ?? 0;
    final inventory = user?.inventory ?? [];
    final streakFreezesCount = inventory.where((i) => i.contains('freeze')).length;

    // Flame Tier determination
    String flameTier = 'New Spark 🌱';
    if (streak >= 30) {
      flameTier = '30-Day Ancestral Torch 🌋';
    } else if (streak >= 14) {
      flameTier = '14-Day Blaze ⚡';
    } else if (streak >= 7) {
      flameTier = '7-Day Flame 🌟';
    } else if (streak >= 3) {
      flameTier = '3-Day Spark 🔥';
    }

    // Calendar month generation
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstDayOfWeek = DateTime(now.year, now.month, 1).weekday; // 1 = Mon, 7 = Sun

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(title: 'Streak Dashboard'),
                const SizedBox(height: AppSpacing.xs),

                // Gold Gradient Hero Card with Left Text & Right Fire Icon
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD54F), AppColors.gold500, Color(0xFFFFA000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: AppColors.gold700, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFC78C00),
                        offset: Offset(0, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Side: Tier Badge, Counter, Slogan & Personal Best Pill
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.forest900.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.forest900.withValues(alpha: 0.3), width: 1.5),
                              ),
                              child: Text(
                                flameTier,
                                style: AppTypography.labelBold.copyWith(
                                  color: AppColors.forest900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '$streak ${streak == 1 ? 'Day' : 'Days'}',
                              style: AppTypography.displayNumber.copyWith(
                                color: AppColors.forest900,
                                fontSize: 40,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              streak > 0
                                  ? "You're on a roll! Keep practicing daily!"
                                  : "Start your streak today by completing a lesson!",
                              style: AppTypography.body.copyWith(
                                color: AppColors.forest800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Personal Best: $longestStreak ${longestStreak == 1 ? 'Day' : 'Days'} Consecutive',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.forest900,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Right Side: Pulsing Flame Icon Medallion
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: streak > 0 ? _pulseAnimation.value : 1.0,
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: AppColors.forest900.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.forest900.withValues(alpha: 0.3), width: 2),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.local_fire_department_rounded,
                                  color: AppColors.forest900,
                                  size: 52,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Weekly Check-in Bar (7 Tactile 3D Day Badges)
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('This Week\'s Activity', style: AppTypography.h3.copyWith(color: Colors.white)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].asMap().entries.map((entry) {
                          final index = entry.key;
                          final dayName = entry.value;
                          final dayLetter = dayName[0];
                          final isActive = index < (streak % 7 == 0 && streak > 0 ? 7 : streak % 7);

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isActive
                                        ? '🔥 $dayName completed! Daily streak saved.'
                                        : '⚡ $dayName pending practice.',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: isActive ? AppColors.semanticGreen : AppColors.forest700,
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.gold500 : AppColors.forest700,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isActive ? AppColors.gold700 : AppColors.forest500,
                                      width: 2,
                                    ),
                                    boxShadow: isActive
                                        ? const [
                                            BoxShadow(
                                              color: Color(0xFFB88500),
                                              offset: Offset(0, 3),
                                              blurRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      isActive ? Icons.check_rounded : Icons.remove_rounded,
                                      color: isActive ? AppColors.forest900 : AppColors.creamText3,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dayLetter,
                                  style: AppTypography.labelBold.copyWith(
                                    color: isActive ? AppColors.gold400 : AppColors.creamBorder,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Interactive Monthly Calendar View Card
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getMonthName(now.month)} ${now.year} Calendar',
                        style: AppTypography.h3.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Weekday headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                            .map((d) => Text(d, style: AppTypography.labelBold.copyWith(color: AppColors.creamBorder, fontSize: 11)))
                            .toList(),
                      ),
                      const SizedBox(height: 10),
                      // Calendar Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: daysInMonth + firstDayOfWeek - 1,
                        itemBuilder: (context, index) {
                          if (index < firstDayOfWeek - 1) {
                            return const SizedBox.shrink();
                          }
                          final dayNum = index - (firstDayOfWeek - 2);
                          final isPastOrToday = dayNum <= now.day;
                          final isActive = isPastOrToday && (dayNum > (now.day - streak));

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _showDayInspectorDialog(context, dayNum, isActive, isPastOrToday);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.gold500
                                    : (isPastOrToday ? AppColors.forest700 : AppColors.forest900),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isActive ? AppColors.gold700 : AppColors.forest500,
                                  width: 2,
                                ),
                                boxShadow: isActive
                                    ? const [
                                        BoxShadow(
                                          color: Color(0xFFB88500),
                                          offset: Offset(0, 3),
                                          blurRadius: 0,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '$dayNum',
                                  style: AppTypography.caption.copyWith(
                                    color: isActive ? AppColors.forest900 : (isPastOrToday ? Colors.white : AppColors.creamText3),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Milestone Roadmap Timeline Card
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Streak Milestones Roadmap', style: AppTypography.h3.copyWith(color: Colors.white)),
                      const SizedBox(height: AppSpacing.sm),
                      Text('Unlock ancestral badges and bonus crystals as your streak grows.', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                      const SizedBox(height: AppSpacing.md),
                      _buildMilestoneRow(context, '7-Day Streak', 7, streak, '+50 Crystals'),
                      const Divider(color: AppColors.forest700, height: 24),
                      _buildMilestoneRow(context, '14-Day Streak', 14, streak, '+100 Crystals'),
                      const Divider(color: AppColors.forest700, height: 24),
                      _buildMilestoneRow(context, '30-Day Streak', 30, streak, '+250 Crystals + Regalia'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Streak Freeze & Protection Card (Playful 3D Ice Shield)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0288D1),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: const Color(0xFF01579B), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF003865),
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF01579B), width: 2),
                            ),
                            child: const Icon(Icons.ac_unit_rounded, color: Color(0xFF0288D1), size: 28),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Streak Freeze Protection', style: AppTypography.h3.copyWith(color: Colors.white)),
                                Text('Active Freezes: $streakFreezesCount Available', style: AppTypography.caption.copyWith(color: const Color(0xFFE1F5FE))),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      BrandButton(
                        text: 'Get Streak Freeze in Shop',
                        type: BrandButtonType.gold,
                        onPressed: () => context.push('/shop'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneRow(BuildContext context, String title, int targetDays, int currentStreak, String reward) {
    final isAchieved = currentStreak >= targetDays;
    final progress = (currentStreak / targetDays).clamp(0.0, 1.0);

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isAchieved ? AppColors.gold500 : AppColors.forest700,
            shape: BoxShape.circle,
            border: Border.all(color: isAchieved ? AppColors.gold700 : AppColors.forest500, width: 2),
            boxShadow: isAchieved
                ? const [
                    BoxShadow(
                      color: Color(0xFFB88500),
                      offset: Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              isAchieved ? Icons.check_rounded : Icons.lock_rounded,
              color: isAchieved ? AppColors.forest900 : AppColors.creamText3,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 14)),
                  Text(reward, style: AppTypography.xpValue.copyWith(color: AppColors.gold400, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.forest700,
                  color: AppColors.gold500,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDayInspectorDialog(BuildContext context, int dayNum, bool isActive, bool isPastOrToday) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.forest800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.modal)),
        title: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.gold500, size: 24),
            const SizedBox(width: 8),
            Text('Day $dayNum Status', style: AppTypography.h3.copyWith(color: Colors.white)),
          ],
        ),
        content: Text(
          isActive
              ? '✅ Completed practice on Day $dayNum! Streak flame is burning strong.'
              : (isPastOrToday
                  ? '⚠️ No practice recorded on Day $dayNum (Streak Freeze used or missed).'
                  : '🔒 Upcoming study day. Keep your future momentum going!'),
          style: AppTypography.body.copyWith(color: AppColors.creamBorder),
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

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}
