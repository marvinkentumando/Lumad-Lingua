import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_radius.dart';
import '../../config/theme/app_spacing.dart';
import '../../providers/theme_provider.dart';

class BrandCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCustomActive = ref.watch(customThemeAccentProvider);
    final r = borderRadius ?? AppRadius.card;

    final bg = backgroundColor ?? (isDark ? AppColors.gold500 : AppColors.forest500);
    final isGoldCard = bg == AppColors.gold500 || bg.toARGB32() == AppColors.gold500.toARGB32() || (backgroundColor != null && backgroundColor == AppColors.gold500);

    final lipColor = isGoldCard
        ? const Color(0xFFC78C00)
        : (isCustomActive ? const Color(0xFF1E0308) : const Color(0xFF0A140B));
    final cardBorder = border ??
        Border.all(
          color: isGoldCard ? AppColors.gold700 : (isCustomActive ? const Color(0xFF5C0E1E) : AppColors.forest700),
          width: isGoldCard ? 1.5 : 1.0,
        );

    final container = Container(
      decoration: BoxDecoration(
        color: isGoldCard ? null : backgroundColor,
        gradient: isGoldCard
            ? const LinearGradient(
                colors: [Color(0xFFFFD54F), AppColors.gold500, Color(0xFFFFA000)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : (backgroundColor != null
                ? null
                : LinearGradient(
                    colors: isCustomActive
                        ? [const Color(0xFF7A1429), const Color(0xFFA91D3A), const Color(0xFF380912)]
                        : [const Color(0xFF2E5A36), AppColors.forest500, Color(0xFF142917)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
        borderRadius: BorderRadius.circular(r),
        border: cardBorder,
        boxShadow: [
          BoxShadow(
            color: lipColor,
            offset: const Offset(0, 4),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: padding,
            child: child,
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
