import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class RecordingButton extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: isRecording ? 80 : 70,
        height: isRecording ? 80 : 70,
        decoration: BoxDecoration(
          color: isRecording ? AppColors.error : AppColors.blue,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isRecording ? AppColors.error : AppColors.blue).withValues(alpha: 0.4),
              blurRadius: isRecording ? 16 : 8,
              spreadRadius: isRecording ? 4 : 2,
            ),
          ],
        ),
        child: Icon(
          isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: isRecording ? 36 : 32,
        ),
      ),
    );
  }
}
