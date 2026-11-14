import 'package:flutter/material.dart';
import 'brand_button.dart';

enum AppButtonVariant { primary, secondary, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    BrandButtonType type;
    switch (variant) {
      case AppButtonVariant.primary:
        type = BrandButtonType.primary;
        break;
      case AppButtonVariant.secondary:
        type = BrandButtonType.gold;
        break;
      case AppButtonVariant.outline:
        type = BrandButtonType.secondary;
        break;
    }

    return BrandButton(
      text: text,
      onPressed: onPressed,
      type: type,
      isLoading: isLoading,
      icon: icon,
    );
  }
}
