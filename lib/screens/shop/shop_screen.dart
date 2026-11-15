import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_filter_chip.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/lumad_background.dart';

class ShopItem {
  final String id;
  final String title;
  final String description;
  final int cost;
  final IconData icon;
  final String category;
  final bool isConsumable;

  const ShopItem({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    required this.category,
    this.isConsumable = true,
  });
}

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Power-ups', 'Learning Pass', 'Customization'];

  final List<ShopItem> _items = const [
    ShopItem(
      id: 'streak_freeze',
      title: 'Streak Freeze',
      description: 'Protects your streak if you miss practicing for a day.',
      cost: 50,
      icon: Icons.ac_unit,
      category: 'Power-ups',
      isConsumable: true,
    ),
    ShopItem(
      id: 'xp_booster',
      title: 'XP Double Booster (24h)',
      description: 'Earn 2x XP on all completed lessons for 24 hours.',
      cost: 100,
      icon: Icons.bolt,
      category: 'Power-ups',
      isConsumable: true,
    ),
    ShopItem(
      id: 'ai_pronunciation_pass',
      title: 'Audio Pronunciation AI Pass',
      description: 'Unlocks detailed waveform and AI analysis on pronunciation attempts.',
      cost: 75,
      icon: Icons.graphic_eq,
      category: 'Learning Pass',
      isConsumable: false,
    ),
    ShopItem(
      id: 'offline_dictionary_pass',
      title: 'Dictionary Offline Access Pass',
      description: 'Download full Mansaka-English dictionary and reference audio for offline study.',
      cost: 120,
      icon: Icons.download_for_offline,
      category: 'Learning Pass',
      isConsumable: false,
    ),
    ShopItem(
      id: 'custom_theme_pass',
      title: 'Custom Theme & Color Accents',
      description: 'Unlock alternate seasonal UI palettes (Gold Harvest & River Blue).',
      cost: 150,
      icon: Icons.palette,
      category: 'Customization',
      isConsumable: false,
    ),
    ShopItem(
      id: 'time_extension_pass',
      title: 'Timed Quiz Time Extension (+30s)',
      description: 'Grants 30 extra seconds during timed matching and listening drills.',
      cost: 40,
      icon: Icons.timer,
      category: 'Power-ups',
      isConsumable: true,
    ),
    ShopItem(
      id: 'hint_pass_bundle',
      title: 'Hint Pass Bundle (5 Hints)',
      description: 'Reveals helpful word roots or hints during challenging grammar drills.',
      cost: 60,
      icon: Icons.lightbulb,
      category: 'Power-ups',
      isConsumable: true,
    ),
    ShopItem(
      id: 'leaderboard_badge_customizer',
      title: 'Leaderboard Custom Badge',
      description: 'Display a custom title and decorative flair on your educator class roster.',
      cost: 80,
      icon: Icons.stars,
      category: 'Customization',
      isConsumable: false,
    ),
    ShopItem(
      id: 'avatar_frame',
      title: 'Tribal Avatar Frame',
      description: 'Unlock a sacred Mansaka regalia frame for your profile avatar.',
      cost: 200,
      icon: Icons.filter_vintage,
      category: 'Customization',
      isConsumable: false,
    ),
    ShopItem(
      id: 'heart_refill',
      title: 'Heart / Life Refill',
      description: 'Instantly refill your lesson hearts and continue practicing.',
      cost: 30,
      icon: Icons.favorite,
      category: 'Power-ups',
      isConsumable: true,
    ),
  ];

  void _confirmPurchase(ShopItem item, int currentCrystals, List<String> inventory) {
    final isAlreadyOwned = !item.isConsumable && inventory.contains(item.id);
    if (isAlreadyOwned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You already own "${item.title}"!')),
      );
      return;
    }

    if (currentCrystals < item.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough crystals! Complete more lessons to earn crystals.')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.diamond, color: AppColors.gold500, size: 28),
            const SizedBox(width: 8),
            Text('Confirm Purchase', style: AppTypography.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Do you want to purchase "${item.title}" for ${item.cost} crystals?', style: AppTypography.body),
            const SizedBox(height: 8),
            Text('Remaining balance after purchase: ${currentCrystals - item.cost} Crystals', style: AppTypography.caption.copyWith(color: AppColors.forest700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          BrandButton(
            text: 'Confirm Purchase',
            type: BrandButtonType.gold,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _buyItem(item, currentCrystals, inventory);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _buyItem(ShopItem item, int currentCrystals, List<String> inventory) async {
    final authNotifier = ref.read(authStateProvider.notifier);
    final user = ref.read(authStateProvider).value;

    if (user == null) return;

    final updatedCrystals = currentCrystals - item.cost;
    final updatedInventory = List<String>.from(inventory);
    if (!updatedInventory.contains(item.id)) {
      updatedInventory.add(item.id);
    }

    final updatedUser = user.copyWith(
      crystals: updatedCrystals,
      inventory: updatedInventory,
    );

    await authNotifier.updateUser(updatedUser);

    if (mounted) {
      HapticFeedback.heavyImpact();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Purchase Successful! 🎉', style: AppTypography.h3),
          content: Text('You have successfully acquired "${item.title}". It is now active in your profile inventory!', style: AppTypography.body),
          actions: [
            BrandButton(
              text: 'Awesome',
              type: BrandButtonType.gold,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final crystals = user?.crystals ?? 150;
    final inventory = user?.inventory ?? [];

    final filteredItems = _selectedCategory == 'All'
        ? _items
        : _items.where((item) => item.category.toLowerCase().contains(_selectedCategory.toLowerCase())).toList();

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScreenHeader(
                        title: 'Crystal Shop',
                        subtitle: 'Spend crystals on power-ups, passes & customization',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Crystal Balance Banner
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD54F), AppColors.gold500, Color(0xFFFFA000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                          border: Border.all(color: AppColors.gold700, width: 2.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFFC78C00),
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.diamond, color: AppColors.forest900, size: 28),
                            const SizedBox(width: 8),
                            Text('$crystals Crystals Available', style: AppTypography.h3.copyWith(color: AppColors.forest900)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Category Filter Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: BrandFilterChip(
                                label: cat,
                                isSelected: isSelected,
                                onSelected: (_) {
                                  setState(() => _selectedCategory = cat);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      final isOwned = !item.isConsumable && inventory.contains(item.id);
                      final canAfford = crystals >= item.cost;

                      return BrandCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold100,
                                    borderRadius: BorderRadius.circular(AppRadius.chip),
                                  ),
                                  child: Text(
                                    item.category.toUpperCase(),
                                    style: AppTypography.labelBold.copyWith(color: AppColors.gold800, fontSize: 9),
                                  ),
                                ),
                                if (isOwned)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.semanticGreen,
                                      borderRadius: BorderRadius.circular(AppRadius.chip),
                                    ),
                                    child: Text('OWNED', style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 9)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.gold500.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(item.icon, color: AppColors.gold500, size: 32),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              style: AppTypography.lessonTitle.copyWith(color: Colors.white, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Expanded(
                              child: Text(
                                item.description,
                                style: AppTypography.caption.copyWith(color: AppColors.creamBorder, fontSize: 11),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.diamond, color: AppColors.gold500, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${item.cost}',
                                  style: AppTypography.xpValue.copyWith(color: AppColors.gold400),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: BrandButton(
                                text: isOwned ? 'Active' : 'Buy',
                                type: isOwned
                                    ? BrandButtonType.secondary
                                    : (canAfford ? BrandButtonType.gold : BrandButtonType.secondary),
                                onPressed: isOwned ? null : () => _confirmPurchase(item, crystals, inventory),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: filteredItems.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
