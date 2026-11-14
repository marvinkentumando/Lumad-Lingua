import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_radius.dart';
import '../../config/theme/app_spacing.dart';

class BrandCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Border? border;
  final double? borderRadius;

  const BrandCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.backgroundColor,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = borderRadius ?? AppRadius.card;

    final bg = backgroundColor ?? (isDark ? AppColors.gold500 : AppColors.forest500);
    final lipColor = isDark ? AppColors.gold700 : AppColors.forest700;
    final cardBorder = border ?? Border.all(color: lipColor, width: 1.0);

    final container = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(r),
        border: cardBorder,
        boxShadow: [
          BoxShadow(
            color: lipColor,
            offset: const Offset(0, 3),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Material(
          color: Colors.transparent,
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white),
              child: Padding(
                padding: padding,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r),
        child: container,
      );
    }

    return container;
  }
}
