import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'brand_card.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      onTap: onTap,
      padding: padding,
      backgroundColor: backgroundColor,
      border: border,
      child: child,
    );
  }
}
