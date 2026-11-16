import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class AudioWaveformWidget extends StatelessWidget {
  final bool isRecording;
  final List<double>? amplitudes;

  const AudioWaveformWidget({super.key, required this.isRecording, this.amplitudes});

  @override
  Widget build(BuildContext context) {
    final heights = (amplitudes != null && amplitudes!.isNotEmpty)
        ? amplitudes!
        : (isRecording
            ? [18.0, 36.0, 54.0, 72.0, 40.0, 24.0, 60.0, 80.0, 48.0, 30.0, 66.0, 85.0, 50.0, 28.0, 45.0, 75.0, 35.0, 60.0, 82.0, 44.0, 22.0, 50.0, 70.0, 38.0]
            : [10.0, 18.0, 28.0, 20.0, 14.0, 22.0, 32.0, 24.0, 16.0, 26.0, 34.0, 18.0, 12.0, 22.0, 30.0, 16.0, 20.0, 28.0, 14.0, 22.0, 26.0, 18.0, 12.0, 16.0]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.creamSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.creamBorder, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: heights.asMap().entries.map((entry) {
            final h = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 8.0, end: h),
              duration: const Duration(milliseconds: 100),
              builder: (context, val, child) {
                return Container(
                  width: 3.5,
                  height: val,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isRecording ? AppColors.semanticRed : AppColors.gold500,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
