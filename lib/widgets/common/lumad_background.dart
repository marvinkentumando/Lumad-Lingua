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
    final pattern = ref.watch(backgroundPatternProvider);

    List<Color> gradientColors;
    if (pattern == 'royal_crimson') {
      gradientColors = isDark
          ? [const Color(0xFF4A0E17), const Color(0xFF1A0205)]
          : [const Color(0xFFFFD1DC), const Color(0xFFE8929E)];
    } else if (isCustomActive) {
      gradientColors = isDark
          ? [const Color(0xFF2A080C), const Color(0xFF0F0204)]
          : [const Color(0xFFFFF0F3), const Color(0xFFF7D9DE)];
    } else {
      gradientColors = isDark
          ? [AppColors.forest900, const Color(0xFF051408)]
          : [const Color(0xFFFEF8ED), const Color(0xFFF1E2C8)];
    }

    CustomPainter? painter;
    if (pattern == 'woven_waves') {
      painter = MansakaPatternPainter(isDark: isDark);
    } else if (pattern == 'tribal_geom') {
      painter = TribalChevronPainter(isDark: isDark);
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
        child: painter != null
            ? CustomPaint(
                painter: painter,
                child: child,
              )
            : child,
      ),
    );
  }
}

class MansakaPatternPainter extends CustomPainter {
  final bool isDark;

  MansakaPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.gold500 : AppColors.forest700).withValues(alpha: isDark ? 0.05 : 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double spacing = 40.0;

    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TribalChevronPainter extends CustomPainter {
  final bool isDark;

  TribalChevronPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? AppColors.gold400 : AppColors.forest800).withValues(alpha: isDark ? 0.06 : 0.05)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const double step = 30.0;
    for (double y = 0; y < size.height + step; y += step) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += step) {
        path.relativeLineTo(step / 2, step / 2);
        path.relativeLineTo(step / 2, -step / 2);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
