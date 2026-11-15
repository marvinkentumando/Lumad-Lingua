import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/constants.dart';
import '../../providers/theme_provider.dart';

class LumadBackground extends ConsumerWidget {
  final Widget child;

  const LumadBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCustomActive = ref.watch(customThemeAccentProvider);

    List<Color> gradientColors;
    if (isCustomActive) {
      gradientColors = isDark
          ? [const Color(0xFF2A080C), const Color(0xFF0F0204)]
          : [const Color(0xFFFFF0F3), const Color(0xFFF7D9DE)];
    } else {
      gradientColors = isDark
          ? [AppColors.forest900, const Color(0xFF051408)]
          : [const Color(0xFFFEF8ED), const Color(0xFFF1E2C8)];
    }

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}
