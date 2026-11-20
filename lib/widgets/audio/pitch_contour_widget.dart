import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PitchContourWidget extends StatelessWidget {
  final List<double>? learnerPitchPoints;
  final List<double>? referencePitchPoints;
  final double score;

  const PitchContourWidget({
    super.key,
    this.learnerPitchPoints,
    this.referencePitchPoints,
    this.score = 85.0,
  });

  @override
  Widget build(BuildContext context) {
    final defaultRef = const [30.0, 45.0, 60.0, 75.0, 65.0, 50.0, 40.0, 55.0, 70.0, 80.0, 60.0, 35.0];
    final defaultLearner = const [28.0, 42.0, 58.0, 72.0, 62.0, 48.0, 42.0, 52.0, 68.0, 78.0, 58.0, 32.0];

    final refPoints = (referencePitchPoints != null && referencePitchPoints!.isNotEmpty)
        ? referencePitchPoints!
        : defaultRef;
    final learnerPoints = (learnerPitchPoints != null && learnerPitchPoints!.isNotEmpty)
        ? learnerPitchPoints!
        : defaultLearner;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.forest900,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pitch Contour Overlay (Pitch Alignment)',
                style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold500.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(color: AppColors.gold500),
                ),
                child: Text(
                  '${score.toStringAsFixed(0)}% Match',
                  style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Custom Painter for Pitch Contour Lines
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _PitchContourPainter(
                refPoints: refPoints,
                learnerPoints: learnerPoints,
                score: score,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Legend Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(width: 12, height: 3, color: AppColors.gold500),
                  const SizedBox(width: 4),
                  Text('Elder Reference', style: AppTypography.caption.copyWith(color: AppColors.gold400, fontSize: 10)),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 3,
                    color: score >= 75.0 ? AppColors.semanticGreen : AppColors.terracotta,
                  ),
                  const SizedBox(width: 4),
                  Text('Your Voice Pitch', style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PitchContourPainter extends CustomPainter {
  final List<double> refPoints;
  final List<double> learnerPoints;
  final double score;

  _PitchContourPainter({
    required this.refPoints,
    required this.learnerPoints,
    required this.score,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw subtle grid lines
    final gridPaint = Paint()
      ..color = Colors.white10
      ..strokeWidth = 1.0;

    for (int i = 1; i <= 3; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw Elder Reference Pitch Line (Gold)
    final refPath = Path();
    final double stepX = size.width / (refPoints.length - 1);

    for (int i = 0; i < refPoints.length; i++) {
      final x = i * stepX;
      final y = size.height - (refPoints[i] / 100.0 * size.height).clamp(10.0, size.height - 10.0);
      if (i == 0) {
        refPath.moveTo(x, y);
      } else {
        refPath.lineTo(x, y);
      }
    }

    final refPaint = Paint()
      ..color = AppColors.gold500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(refPath, refPaint);

    // Draw Learner Pitch Line (Green / Terracotta)
    final learnerPath = Path();
    final double learnerStepX = size.width / (learnerPoints.length - 1);

    for (int i = 0; i < learnerPoints.length; i++) {
      final x = i * learnerStepX;
      final y = size.height - (learnerPoints[i] / 100.0 * size.height).clamp(10.0, size.height - 10.0);
      if (i == 0) {
        learnerPath.moveTo(x, y);
      } else {
        learnerPath.lineTo(x, y);
      }
    }

    final learnerPaint = Paint()
      ..color = score >= 75.0 ? AppColors.semanticGreen : AppColors.terracotta
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(learnerPath, learnerPaint);
  }

  @override
  bool shouldRepaint(covariant _PitchContourPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.refPoints != refPoints ||
        oldDelegate.learnerPoints != learnerPoints;
  }
}
