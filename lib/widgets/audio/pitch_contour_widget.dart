import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PitchContourWidget extends StatelessWidget {
  final List<double>? learnerPitchPoints;
  final List<double>? referencePitchPoints;
  final double score;
  final String? phraseTitle;

  const PitchContourWidget({
    super.key,
    this.learnerPitchPoints,
    this.referencePitchPoints,
    this.score = 85.0,
    this.phraseTitle,
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
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.6), width: 1.5),
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
              Row(
                children: [
                  const Icon(Icons.graphic_eq, color: AppColors.gold400, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Real-Time Pitch Contour Overlay',
                    style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: (score >= 75.0 ? AppColors.semanticGreen : AppColors.terracotta).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  border: Border.all(
                    color: score >= 75.0 ? AppColors.semanticGreen : AppColors.terracotta,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      score >= 75.0 ? Icons.check_circle : Icons.warning_amber_rounded,
                      color: score >= 75.0 ? AppColors.semanticGreen : AppColors.terracotta,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${score.toStringAsFixed(0)}% Intonation Match',
                      style: AppTypography.labelBold.copyWith(
                        color: score >= 75.0 ? AppColors.semanticGreen : AppColors.terracotta,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (phraseTitle != null && phraseTitle!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Target: "$phraseTitle"',
              style: AppTypography.caption.copyWith(color: AppColors.creamBorder, fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),

          // Custom Painter for Real-time Pitch Overlay
          SizedBox(
            height: 110,
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(width: 14, height: 3, color: AppColors.gold500),
                  const SizedBox(width: 4),
                  Text('Native Elder Pitch', style: AppTypography.caption.copyWith(color: AppColors.gold400, fontSize: 10)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 3,
                    color: score >= 75.0 ? AppColors.semanticGreen : AppColors.terracotta,
                  ),
                  const SizedBox(width: 4),
                  Text('Your Voice Pitch', style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 10)),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(color: AppColors.semanticGreen, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text('Matched Syllable', style: AppTypography.caption.copyWith(color: AppColors.creamBorder, fontSize: 10)),
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
    final double leftPadding = 24.0;
    final double drawWidth = size.width - leftPadding;

    // 1. Draw Pitch Frequency Guidelines (High, Mid, Low)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final labels = ['High', 'Mid', 'Low'];
    for (int i = 0; i < 3; i++) {
      final y = 15.0 + (size.height - 30.0) / 2 * i;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);

      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.white38, fontSize: 8),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 5));
    }

    // 2. Build Paths for Elder Native Reference Curve (Gold)
    final refPath = Path();
    final refFillPath = Path();
    final double stepX = drawWidth / (refPoints.length - 1);

    refFillPath.moveTo(leftPadding, size.height);

    for (int i = 0; i < refPoints.length; i++) {
      final x = leftPadding + (i * stepX);
      final y = size.height - 10.0 - (refPoints[i] / 100.0 * (size.height - 20.0)).clamp(5.0, size.height - 15.0);

      if (i == 0) {
        refPath.moveTo(x, y);
        refFillPath.lineTo(x, y);
      } else {
        refPath.lineTo(x, y);
        refFillPath.lineTo(x, y);
      }
    }
    refFillPath.lineTo(leftPadding + drawWidth, size.height);
    refFillPath.close();

    // Fill area under reference curve
    final refFillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.gold500.withValues(alpha: 0.18), AppColors.gold500.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(leftPadding, 0, drawWidth, size.height));
    canvas.drawPath(refFillPath, refFillPaint);

    // Reference Stroke Line
    final refPaint = Paint()
      ..color = AppColors.gold500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(refPath, refPaint);

    // 3. Build Paths for Learner Voice Contour Curve
    final learnerPath = Path();
    final learnerFillPath = Path();
    final double learnerStepX = drawWidth / (learnerPoints.length - 1);

    learnerFillPath.moveTo(leftPadding, size.height);

    final Color learnerColor = score >= 75.0 ? AppColors.semanticGreen : AppColors.terracotta;

    for (int i = 0; i < learnerPoints.length; i++) {
      final x = leftPadding + (i * learnerStepX);
      final y = size.height - 10.0 - (learnerPoints[i] / 100.0 * (size.height - 20.0)).clamp(5.0, size.height - 15.0);

      if (i == 0) {
        learnerPath.moveTo(x, y);
        learnerFillPath.lineTo(x, y);
      } else {
        learnerPath.lineTo(x, y);
        learnerFillPath.lineTo(x, y);
      }
    }
    learnerFillPath.lineTo(leftPadding + drawWidth, size.height);
    learnerFillPath.close();

    // Fill area under learner curve
    final learnerFillPaint = Paint()
      ..shader = LinearGradient(
        colors: [learnerColor.withValues(alpha: 0.22), learnerColor.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(leftPadding, 0, drawWidth, size.height));
    canvas.drawPath(learnerFillPath, learnerFillPaint);

    // Learner Stroke Line
    final learnerPaint = Paint()
      ..color = learnerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(learnerPath, learnerPaint);

    // 4. Draw Syllable Alignment Dots (Green for Match, Terracotta for Divergence)
    final int evalCount = refPoints.length < learnerPoints.length ? refPoints.length : learnerPoints.length;
    for (int i = 0; i < evalCount; i++) {
      final x = leftPadding + (i * stepX);
      final refY = size.height - 10.0 - (refPoints[i] / 100.0 * (size.height - 20.0)).clamp(5.0, size.height - 15.0);
      final learnerY = size.height - 10.0 - (learnerPoints[i] / 100.0 * (size.height - 20.0)).clamp(5.0, size.height - 15.0);

      final double diffPercent = (refPoints[i] - learnerPoints[i]).abs();
      final bool isMatched = diffPercent <= 14.0;

      final dotPaint = Paint()
        ..color = isMatched ? AppColors.semanticGreen : AppColors.terracotta
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, learnerY), isMatched ? 3.5 : 4.0, dotPaint);

      if (!isMatched) {
        // Draw subtle connecting warning line showing intonation gap
        final warningLinePaint = Paint()
          ..color = AppColors.terracotta.withValues(alpha: 0.5)
          ..strokeWidth = 1.0;
        canvas.drawLine(Offset(x, refY), Offset(x, learnerY), warningLinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PitchContourPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.refPoints != refPoints ||
        oldDelegate.learnerPoints != learnerPoints;
  }
}
