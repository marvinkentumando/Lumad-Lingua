import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class RecordingButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const RecordingButton({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isRecording) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(RecordingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final scale = widget.isRecording ? _pulseAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: widget.isRecording ? 80 : 70,
              height: widget.isRecording ? 80 : 70,
              decoration: BoxDecoration(
                color: widget.isRecording ? AppColors.semanticRed : AppColors.gold500,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isRecording ? AppColors.semanticRed : AppColors.gold700,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording ? AppColors.semanticRed : AppColors.gold500).withValues(alpha: 0.5),
                    blurRadius: widget.isRecording ? 20 : 8,
                    spreadRadius: widget.isRecording ? 6 : 2,
                  ),
                ],
              ),
              child: Icon(
                widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                color: widget.isRecording ? Colors.white : AppColors.forest900,
                size: widget.isRecording ? 36 : 32,
              ),
            ),
          );
        },
      ),
    );
  }
}

