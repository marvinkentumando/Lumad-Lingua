import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class LumadLogoEmblem extends StatelessWidget {
  final double size;
  final double borderRadius;

  const LumadLogoEmblem({
    super.key,
    this.size = 56.0,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.forest500,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.gold500, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.forest700.withValues(alpha: 0.4),
            offset: const Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.65, size * 0.65),
          painter: _LumadDiamondPainter(color: AppColors.gold500),
        ),
      ),
    );
  }
}

class _LumadDiamondPainter extends CustomPainter {
  final Color color;
  _LumadDiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paintOuter = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintInner = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.42;
    final innerRadius = size.width * 0.16;

    Path createDiamond(Offset c, double r) {
      return Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r, c.dy)
        ..close();
    }

    canvas.drawPath(createDiamond(center, outerRadius), paintOuter);
    canvas.drawPath(createDiamond(center, innerRadius), paintInner);
  }

  @override
  bool shouldRepaint(covariant _LumadDiamondPainter oldDelegate) => oldDelegate.color != color;
}
