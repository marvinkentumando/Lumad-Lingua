enum ShopItemType {
  streakFreeze,
  avatarFrame,
  profileBanner,
  themePass,
}

class ShopItemModel {
  final String id;
  final String name;
  final String description;
  final int priceCrystals;
  final ShopItemType type;
  final String? assetPath;
  final String? badgeText;

  const ShopItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCrystals,
    required this.type,
    this.assetPath,
    this.badgeText,
  });
}
