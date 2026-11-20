import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/shop_item_model.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_filter_chip.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/guest_lock_dialog.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Streak Protection 🧊',
    'Avatar Frames 🖼️',
    'Profile Banners 🎨',
    'Themes 🎨',
    'Power-ups',
  ];

  final List<ShopItemModel> _items = const [
    ShopItemModel(
      id: 'streak_freeze',
      name: 'Streak Freeze 🧊',
      description: 'Protects your daily streak if you miss a day of practice due to travel or work.',
      priceCrystals: 150,
      type: ShopItemType.streakFreeze,
      badgeText: 'STREAK PROTECT',
    ),
    ShopItemModel(
      id: 'frame_golden_weave',
      name: 'Golden Ancestral Weave Frame',
      description: 'Sacred dual-tone golden regalia frame wrapping your profile avatar.',
      priceCrystals: 200,
      type: ShopItemType.avatarFrame,
      badgeText: 'AVATAR FRAME',
    ),
    ShopItemModel(
      id: 'frame_datu_crest',
      name: 'Datu Tribal Crest Border',
      description: 'High-status Datu honor crest border with ancestral geometric patterns.',
      priceCrystals: 250,
      type: ShopItemType.avatarFrame,
      badgeText: 'AVATAR FRAME',
    ),
    ShopItemModel(
      id: 'frame_dagmay_woven',
      name: 'Dagmay Woven Regalia',
      description: 'Intricate Mandaya & Mansaka woven pattern border for learners.',
      priceCrystals: 180,
      type: ShopItemType.avatarFrame,
      badgeText: 'AVATAR FRAME',
    ),
    ShopItemModel(
      id: 'frame_agong_bronze',
      name: 'Agong Bronze Ceremonial Gong Frame',
      description: 'Resonant bronze ceremonial gong border honoring ancestral Lumad music.',
      priceCrystals: 220,
      type: ShopItemType.avatarFrame,
      badgeText: 'AVATAR FRAME',
    ),
    ShopItemModel(
      id: 'frame_bangkaw_spear',
      name: 'Bangkaw Spear & Shield Frame',
      description: 'Warrior Bangkaw spear and shield regalia border representing bravery.',
      priceCrystals: 240,
      type: ShopItemType.avatarFrame,
      badgeText: 'AVATAR FRAME',
    ),
    ShopItemModel(
      id: 'frame_kagikit_boat',
      name: 'Kagikit Royal Ancestral Boat Frame',
      description: 'Majestic Kagikit royal raft frame celebrating river navigation heritage.',
      priceCrystals: 260,
      type: ShopItemType.avatarFrame,
      badgeText: 'AVATAR FRAME',
    ),
    ShopItemModel(
      id: 'banner_ancestral_gold',
      name: 'Ancestral Gold Harvest Banner',
      description: 'Radiant gold harvest pattern header banner on your profile.',
      priceCrystals: 220,
      type: ShopItemType.profileBanner,
      badgeText: 'PROFILE BANNER',
    ),
    ShopItemModel(
      id: 'banner_crimson_festival',
      name: 'Crimson Festival Sun Banner',
      description: 'Royal crimson & gold festival banner with tribal sun motif.',
      priceCrystals: 220,
      type: ShopItemType.profileBanner,
      badgeText: 'PROFILE BANNER',
    ),
    ShopItemModel(
      id: 'banner_forest_weave',
      name: 'Mindanao Forest Weave Banner',
      description: 'Deep forest green geometric tapestry banner for nature lovers.',
      priceCrystals: 200,
      type: ShopItemType.profileBanner,
      badgeText: 'PROFILE BANNER',
    ),
    ShopItemModel(
      id: 'custom_theme_pass',
      name: 'Royal Crimson & Gold Theme Pass',
      description: 'Unlock alternate seasonal UI palettes across app cards and banners.',
      priceCrystals: 150,
      type: ShopItemType.themePass,
      badgeText: 'THEME PASS',
    ),
    ShopItemModel(
      id: 'xp_booster',
      name: 'XP Double Booster (24h)',
      description: 'Earn 2x XP on all completed lessons for 24 hours.',
      priceCrystals: 100,
      type: ShopItemType.themePass,
      badgeText: 'POWER-UP',
    ),
  ];

  IconData _getIconForItem(ShopItemModel item) {
    switch (item.type) {
      case ShopItemType.streakFreeze:
        return Icons.ac_unit;
      case ShopItemType.avatarFrame:
        return Icons.filter_vintage;
      case ShopItemType.profileBanner:
        return Icons.wallpaper;
      case ShopItemType.themePass:
        return Icons.palette;
    }
  }

  void _confirmPurchase(ShopItemModel item, int currentCrystals) {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      showGuestLockDialog(
        context,
        title: 'Shop Purchases Locked 🔒',
        message: 'Guests cannot purchase items or save inventory items across sessions.',
      );
      return;
    }

    if (currentCrystals < item.priceCrystals) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough crystals! Complete more lessons to earn crystals.')),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cardColor(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.modal)),
        title: Row(
          children: [
            const Icon(Icons.diamond, color: AppColors.gold500, size: 28),
            const SizedBox(width: 8),
            Text('Confirm Purchase', style: AppTypography.h3.copyWith(color: AppColors.textColor(context))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Purchase "${item.name}" for ${item.priceCrystals} crystals?', style: AppTypography.body.copyWith(color: AppColors.textColor(context))),
            const SizedBox(height: 8),
            Text('Remaining balance: ${currentCrystals - item.priceCrystals} Crystals', style: AppTypography.caption.copyWith(color: AppColors.subtitleColor(context))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context))),
          ),
          BrandButton(
            text: 'Confirm Purchase',
            type: BrandButtonType.gold,
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final authNotifier = ref.read(authStateProvider.notifier);
              final success = await authNotifier.buyShopItem(item);

              if (mounted) {
                if (success) {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully acquired "${item.name}"! 🎉')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Purchase failed. Check crystal balance.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final crystals = user?.crystals ?? 150;
    final inventory = user?.inventory ?? [];
    final streakFreezes = user?.streakFreezes ?? 0;
    final equippedFrame = user?.equippedFrame;
    final equippedBanner = user?.equippedBanner;

    final filteredItems = _items.where((item) {
      if (_selectedCategory == 'All') return true;
      if (_selectedCategory.contains('Streak') && item.type == ShopItemType.streakFreeze) return true;
      if (_selectedCategory.contains('Frames') && item.type == ShopItemType.avatarFrame) return true;
      if (_selectedCategory.contains('Banners') && item.type == ShopItemType.profileBanner) return true;
      if (_selectedCategory.contains('Themes') && item.type == ShopItemType.themePass) return true;
      if (_selectedCategory.contains('Power-ups') && item.type == ShopItemType.themePass) return true;
      return false;
    }).toList();

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
                        subtitle: 'Spend crystals on streak freezes, frames, banners & themes',
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.diamond, color: AppColors.forest900, size: 28),
                                const SizedBox(width: 8),
                                Text('$crystals Crystals Available', style: AppTypography.h3.copyWith(color: AppColors.forest900)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.forest900,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('🧊 $streakFreezes Freezes', style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 11)),
                            ),
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
                    childAspectRatio: 0.68,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisSpacing: AppSpacing.md,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      final isOwned = inventory.contains(item.id);
                      final isEquipped = (item.type == ShopItemType.avatarFrame && equippedFrame == item.id) ||
                          (item.type == ShopItemType.profileBanner && equippedBanner == item.id);
                      final canAfford = crystals >= item.priceCrystals;

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
                                    item.badgeText ?? 'ITEM',
                                    style: AppTypography.labelBold.copyWith(color: AppColors.gold800, fontSize: 8),
                                  ),
                                ),
                                if (isEquipped)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.semanticGreen,
                                      borderRadius: BorderRadius.circular(AppRadius.chip),
                                    ),
                                    child: Text('EQUIPPED', style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 8)),
                                  )
                                else if (isOwned)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.forest700,
                                      borderRadius: BorderRadius.circular(AppRadius.chip),
                                    ),
                                    child: Text('OWNED', style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 8)),
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
                                child: Icon(_getIconForItem(item), color: AppColors.gold500, size: 32),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.name,
                              style: AppTypography.lessonTitle.copyWith(color: Colors.white, fontSize: 13),
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
                                  '${item.priceCrystals}',
                                  style: AppTypography.xpValue.copyWith(color: AppColors.gold400),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: Builder(
                                builder: (context) {
                                  if (isEquipped) {
                                    return BrandButton(
                                      text: 'Equipped',
                                      type: BrandButtonType.secondary,
                                      onPressed: null,
                                    );
                                  } else if (isOwned) {
                                    return BrandButton(
                                      text: 'Equip',
                                      type: BrandButtonType.gold,
                                      onPressed: () async {
                                        final user = ref.read(authStateProvider).value;
                                        if (user == null) {
                                          showGuestLockDialog(
                                            context,
                                            title: 'Equipping Cosmetics Locked 🔒',
                                            message: 'Guests cannot equip avatar frames or banners across sessions.',
                                          );
                                          return;
                                        }

                                        final authNotifier = ref.read(authStateProvider.notifier);
                                        final messenger = ScaffoldMessenger.of(context);
                                        final itemName = item.name;

                                        if (item.type == ShopItemType.avatarFrame) {
                                          await authNotifier.equipFrame(item.id);
                                        } else if (item.type == ShopItemType.profileBanner) {
                                          await authNotifier.equipBanner(item.id);
                                        }

                                        messenger.showSnackBar(
                                          SnackBar(content: Text('Equipped "$itemName"! ✨')),
                                        );
                                      },
                                    );
                                  } else {
                                    return BrandButton(
                                      text: 'Buy',
                                      type: canAfford ? BrandButtonType.gold : BrandButtonType.secondary,
                                      onPressed: () => _confirmPurchase(item, crystals),
                                    );
                                  }
                                },
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
