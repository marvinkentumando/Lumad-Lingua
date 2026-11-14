import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';

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

  Future<void> _buyItem(ShopItem item, int currentCrystals, List<String> inventory) async {
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

    final authNotifier = ref.read(authStateProvider.notifier);
    final user = ref.read(authStateProvider).value;

    if (user == null) return;

    final updatedCrystals = currentCrystals - item.cost;
    final updatedInventory = List<String>.from(inventory);
    if (!item.isConsumable && !updatedInventory.contains(item.id)) {
      updatedInventory.add(item.id);
    }

    final updatedUser = user.copyWith(
      crystals: updatedCrystals,
      inventory: updatedInventory,
    );

    await authNotifier.updateUser(updatedUser);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Purchase Successful!'),
          content: Text('You have successfully acquired "${item.title}".'),
          actions: [
            BrandButton(
              text: 'Awesome',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crystal Shop'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(color: AppColors.gold500),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.diamond, color: AppColors.gold500, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$crystals',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _items.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final item = _items[index];
            final isOwned = !item.isConsumable && inventory.contains(item.id);
            final canAfford = crystals >= item.cost;

            return AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.gold500.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: AppColors.gold500, size: 32),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.forestGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadius.chip),
                              ),
                              child: Text(
                                item.category.toUpperCase(),
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                              ),
                            ),
                            if (isOwned) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.semanticGreen.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(AppRadius.chip),
                                ),
                                child: const Text(
                                  'OWNED',
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.semanticGreen),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textColor(context)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(fontSize: 12, color: AppColors.subtitleColor(context)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.diamond, color: AppColors.gold500, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${item.cost} Crystals',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold500, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    width: 90,
                    child: BrandButton(
                      text: isOwned ? 'Active' : 'Buy',
                      type: isOwned
                          ? BrandButtonType.secondary
                          : (canAfford ? BrandButtonType.primary : BrandButtonType.secondary),
                      onPressed: isOwned ? null : () => _buyItem(item, crystals, inventory),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
