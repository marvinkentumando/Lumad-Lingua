import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../utils/audio_helper.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/gamification/day_7_mystery_chest_dialog.dart';

class StreakDashboardScreen extends ConsumerStatefulWidget {
  const StreakDashboardScreen({super.key});

  @override
  ConsumerState<StreakDashboardScreen> createState() => _StreakDashboardScreenState();
}

class _StreakDashboardScreenState extends ConsumerState<StreakDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late ConfettiController _flameConfettiController;

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
    _flameConfettiController = ConfettiController(duration: const Duration(milliseconds: 1200));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _flameConfettiController.dispose();
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

                      // Right Side: Pulsing Flame Icon Medallion with Tap-to-Crackle Effect
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ConfettiWidget(
                            confettiController: _flameConfettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            shouldLoop: false,
                            colors: const [AppColors.gold500, AppColors.terracotta, Colors.orange, Colors.amber, Colors.redAccent],
                            createParticlePath: (size) {
                              final path = Path();
                              path.addOval(Rect.fromCircle(center: Offset.zero, radius: 6));
                              return path;
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              _flameConfettiController.play();
                              try {
                                AudioHelper.playAudio('https://cdn.pixabay.com/download/audio/2022/03/15/audio_c352a926dc.mp3?filename=campfire-crackle-10884.mp3');
                              } catch (_) {}
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('🔥 Crackle! Streak fire burning bright ($streak days)!'),
                                  duration: const Duration(seconds: 1, milliseconds: 500),
                                  backgroundColor: AppColors.terracotta,
                                ),
                              );
                            },
                            child: AnimatedBuilder(
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
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Streak Rescue Mission Card (Shown when streak == 0)
                if (streak == 0) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFC62828), Color(0xFFB71C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: const Color(0xFFE57373), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF7F0000),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.forest900,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.redAccent, width: 2),
                          ),
                          child: const Text('🚨', style: TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Streak Rescue Mission!', style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(
                                '24-hour grace window! Complete Revival Quiz to resurrect your streak.',
                                style: AppTypography.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        BrandButton(
                          text: 'Resurrect ⚡',
                          type: BrandButtonType.gold,
                          onPressed: () => _showRevivalQuizDialog(context, ref),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Day 7 Streak Mystery Chest Card
                Builder(
                  builder: (context) {
                    final isChestClaimed = inventory.contains('day_7_chest_claimed');
                    final canClaimChest = streak >= 7 && !isChestClaimed;

                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
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
                            offset: Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.forest900,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold400, width: 2),
                            ),
                            child: const Text('🎁', style: TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Day 7 Streak Mystery Chest', style: AppTypography.h3.copyWith(color: AppColors.forest900, fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(
                                  isChestClaimed
                                      ? 'Claimed! Rewards unlocked.'
                                      : (canClaimChest ? 'Unlocked! Ready to open.' : 'Reach Day 7 streak to open ($streak/7)'),
                                  style: AppTypography.caption.copyWith(color: AppColors.forest800, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          BrandButton(
                            text: isChestClaimed ? 'Claimed 🎁' : (canClaimChest ? 'Open 🎁' : '$streak/7'),
                            type: isChestClaimed
                                ? BrandButtonType.secondary
                                : (canClaimChest ? BrandButtonType.primary : BrandButtonType.secondary),
                            onPressed: isChestClaimed || !canClaimChest ? null : () => showDay7MysteryChestDialog(context, ref),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Milestone Badge Showcase
                Text('Streak Milestone Badges', style: AppTypography.h3.copyWith(color: Colors.white)),
                const SizedBox(height: AppSpacing.xs),
                Text('Tap badges to inspect & celebrate milestones!', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 105,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildMilestoneCard(
                        context,
                        title: '3-Day Spark',
                        target: 3,
                        current: streak,
                        icon: '🔥',
                        desc: 'Maintain a 3-day consecutive learning streak to ignite your Lumad fire.',
                      ),
                      const SizedBox(width: 12),
                      _buildMilestoneCard(
                        context,
                        title: '7-Day Flame',
                        target: 7,
                        current: streak,
                        icon: '🌟',
                        desc: 'A full week of dedication! Unlocks the Day 7 Mystery Chest and glowing flame aura.',
                      ),
                      const SizedBox(width: 12),
                      _buildMilestoneCard(
                        context,
                        title: '14-Day Blaze',
                        target: 14,
                        current: streak,
                        icon: '⚡',
                        desc: 'Two weeks strong! Prove your unwavering commitment to learning.',
                      ),
                      const SizedBox(width: 12),
                      _buildMilestoneCard(
                        context,
                        title: '30-Day Torch',
                        target: 30,
                        current: streak,
                        icon: '🌋',
                        desc: 'The ultimate ancestral torch! 30 days of unyielding linguistic mastery.',
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
                GestureDetector(
                  onTap: () => _showStreakFreezeManagementModal(context, ref, user?.streakFreezes ?? streakFreezesCount),
                  child: Container(
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
                                  Text('Active Freezes: ${user?.streakFreezes ?? streakFreezesCount} Available (Tap to Manage)', style: AppTypography.caption.copyWith(color: const Color(0xFFE1F5FE))),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: BrandButton(
                                text: 'Inspect & Equip 🧊',
                                type: BrandButtonType.primary,
                                onPressed: () => _showStreakFreezeManagementModal(context, ref, user?.streakFreezes ?? streakFreezesCount),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: BrandButton(
                                text: 'Shop 🛒',
                                type: BrandButtonType.gold,
                                onPressed: () => context.push('/shop'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStreakFreezeManagementModal(BuildContext context, WidgetRef ref, int freezesCount) {
    HapticFeedback.mediumImpact();
    bool isEquipped = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF01579B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🧊', style: TextStyle(fontSize: 28)),
                          const SizedBox(width: 8),
                          Text('Streak Freeze Inventory', style: AppTypography.h2.copyWith(color: Colors.white)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stocked Protections: $freezesCount Available. Equipping shields automatically saves your streak if you miss a day of practice.',
                    style: AppTypography.body.copyWith(color: const Color(0xFFE1F5FE)),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0288D1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Shield Defense Status', style: AppTypography.labelBold.copyWith(color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(isEquipped ? 'Active & Armed 🛡️' : 'Disarmed ⚠️', style: AppTypography.caption.copyWith(color: Colors.white70)),
                          ],
                        ),
                        Switch(
                          value: isEquipped,
                          activeThumbColor: AppColors.gold500,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            setStateModal(() => isEquipped = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: BrandButton(
                          text: 'Test Simulation 🧪',
                          type: BrandButtonType.secondary,
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            HapticFeedback.heavyImpact();
                            _flameConfettiController.play();
                            showDialog(
                              context: context,
                              builder: (c) => AlertDialog(
                                backgroundColor: AppColors.forest800,
                                title: const Text('🛡️ Shield Test Successful!', style: TextStyle(color: Colors.white)),
                                content: const Text('Simulation: You missed yesterday! Your active Streak Freeze shield absorbed the impact and protected your streak.', style: TextStyle(color: AppColors.creamBorder)),
                                actions: [
                                  BrandButton(text: 'Awesome!', type: BrandButtonType.gold, onPressed: () => Navigator.of(c).pop()),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: BrandButton(
                          text: 'Gift to Friend 🎁',
                          type: BrandButtonType.gold,
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            _showGiftFreezeDialog(context, ref, freezesCount);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGiftFreezeDialog(BuildContext context, WidgetRef ref, int freezesCount) {
    if (freezesCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ No Streak Freezes available to gift! Buy some in the shop.')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final friends = ['Apu Datu (Clan Leader)', 'Inday Lumad (Peer)', 'Datu Mamphay (Apprentice)'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.forest800,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
          title: Text('🎁 Gift Streak Freeze', style: AppTypography.h3.copyWith(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a friend from the Leaderboard to gift 1 Streak Freeze:', style: AppTypography.body.copyWith(color: AppColors.creamBorder)),
              const SizedBox(height: AppSpacing.md),
              ...friends.map((friend) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _flameConfettiController.play();
                    Navigator.of(dialogContext).pop();

                    final authNotifier = ref.read(authStateProvider.notifier);
                    final currentUser = ref.read(authStateProvider).value;
                    if (currentUser != null) {
                      authNotifier.updateUser(currentUser.copyWith(streakFreezes: currentUser.streakFreezes - 1));
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🎁 Successfully gifted 1 Streak Freeze to $friend!'),
                        backgroundColor: AppColors.semanticGreen,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.forest700,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold500, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(friend, style: AppTypography.labelBold.copyWith(color: Colors.white)),
                        const Text('Send 🧊', style: TextStyle(color: AppColors.gold400)),
                      ],
                    ),
                  ),
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: AppColors.creamBorder)),
            ),
          ],
        );
      },
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

  void _showMilestoneDetails(BuildContext context, String title, int targetDays, int currentStreak, String icon, String description) {
    HapticFeedback.mediumImpact();
    _flameConfettiController.play();
    
    final isUnlocked = currentStreak >= targetDays;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.forest800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.modal)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isUnlocked ? AppColors.gold500 : AppColors.forest700,
                  shape: BoxShape.circle,
                  border: Border.all(color: isUnlocked ? AppColors.gold400 : AppColors.forest500, width: 2),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                style: AppTypography.h2.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnlocked ? AppColors.semanticGreen.withValues(alpha: 0.2) : AppColors.forest700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isUnlocked ? 'UNLOCKED 🎉' : 'LOCKED ($currentStreak/$targetDays Days)',
                  style: AppTypography.labelBold.copyWith(
                    color: isUnlocked ? AppColors.semanticGreen : AppColors.creamBorder,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                description,
                style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              BrandButton(
                text: isUnlocked ? 'Celebrate! 🌟' : 'Keep Practicing 🔥',
                type: isUnlocked ? BrandButtonType.gold : BrandButtonType.primary,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context, {
    required String title,
    required int target,
    required int current,
    required String icon,
    required String desc,
  }) {
    final isUnlocked = current >= target;

    return GestureDetector(
      onTap: () => _showMilestoneDetails(context, title, target, current, icon, desc),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isUnlocked ? AppColors.forest700 : AppColors.forest900.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: isUnlocked ? AppColors.gold500 : AppColors.forest700,
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? const [
                  BoxShadow(
                    color: Color(0xFF142917),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: TextStyle(fontSize: isUnlocked ? 32 : 28)),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.labelBold.copyWith(
                color: isUnlocked ? Colors.white : AppColors.creamBorder,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              isUnlocked ? 'Unlocked ✨' : '$current/$target Days',
              style: AppTypography.caption.copyWith(
                color: isUnlocked ? AppColors.gold400 : AppColors.creamBorder,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showRevivalQuizDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.mediumImpact();
    int selectedOption = -1;
    bool answeredCorrectly = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              backgroundColor: AppColors.forest800,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
              title: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Streak Revival Boss Quiz',
                      style: AppTypography.h3.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Answer correctly to resurrect your streak and reclaim your progress!',
                    style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.forest900,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold500, width: 1),
                    ),
                    child: Text(
                      'Q: What is the traditional Lumad Higaonon/Manobo greeting for "Good day"?',
                      style: AppTypography.labelBold.copyWith(color: AppColors.gold400),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...['Madyaw na allaw', 'Salamat gid', 'Magandang umaga'].asMap().entries.map((entry) {
                    final index = entry.key;
                    final text = entry.value;
                    final isSelected = selectedOption == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setStateModal(() {
                            selectedOption = index;
                            answeredCorrectly = index == 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (answeredCorrectly ? AppColors.semanticGreen.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3))
                                : AppColors.forest700,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? (answeredCorrectly ? AppColors.semanticGreen : Colors.red)
                                  : AppColors.forest500,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? (answeredCorrectly ? Icons.check_circle : Icons.cancel)
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? (answeredCorrectly ? AppColors.semanticGreen : Colors.red)
                                    : AppColors.creamBorder,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(text, style: AppTypography.body.copyWith(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel', style: TextStyle(color: AppColors.creamBorder)),
                ),
                BrandButton(
                  text: 'Submit Answer',
                  type: BrandButtonType.gold,
                  onPressed: selectedOption == -1
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          if (answeredCorrectly) {
                            HapticFeedback.heavyImpact();
                            _flameConfettiController.play();
                            
                            final authNotifier = ref.read(authStateProvider.notifier);
                            final currentUser = ref.read(authStateProvider).value;
                            if (currentUser != null) {
                              authNotifier.updateUser(currentUser.copyWith(streakDays: 5));
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🎉 Streak Resurrected to 5 Days! Fire is burning again! 🔥'),
                                backgroundColor: AppColors.semanticGreen,
                              ),
                            );
                          } else {
                            HapticFeedback.vibrate();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Incorrect! Try again next time or complete a lesson to start a new streak.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
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
