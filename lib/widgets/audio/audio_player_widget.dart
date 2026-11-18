import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../utils/constants.dart';
import '../../utils/audio_helper.dart';
import '../common/brand_card.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String? audioUrl;
  final String title;

  const AudioPlayerWidget({
    super.key,
    this.audioUrl,
    required this.title,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoaded = false;
  double _playbackSpeed = 1.0;
  static const List<double> _speeds = [1.0, 0.75, 0.5];

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _toggleSpeed() {
    final nextIndex = (_speeds.indexOf(_playbackSpeed) + 1) % _speeds.length;
    final nextSpeed = _speeds[nextIndex];
    setState(() => _playbackSpeed = nextSpeed);
    _player.setSpeed(nextSpeed);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playback speed set to ${nextSpeed}x ${nextSpeed < 1.0 ? '🐢 (Slow Motion)' : '⚡'}'),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  Future<void> _playAudio() async {
    final resolvedUrl = AudioHelper.resolveSupabaseAudioUrl(widget.audioUrl);

    if (resolvedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reference audio is currently unavailable for this item.'),
        ),
      );
      return;
    }

    try {
      if (!_isLoaded) {
        await _player.setUrl(resolvedUrl);
        _isLoaded = true;
      }
      await _player.setSpeed(_playbackSpeed);
      setState(() => _isPlaying = true);
      await _player.seek(Duration.zero);
      await _player.play();
      setState(() => _isPlaying = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isPlaying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Audio playback error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BrandCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: _playAudio,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold500,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold700, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.gold700,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 28,
                color: AppColors.forest900,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: AppTypography.lessonTitle.copyWith(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.audioUrl != null ? 'Tap play to listen to native speaker' : 'Audio reference pending linguistic review',
                  style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Speed Toggle Button Chip (1.0x -> 0.75x -> 0.5x)
          GestureDetector(
            onTap: _toggleSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _playbackSpeed < 1.0 ? AppColors.gold500 : AppColors.forest800,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(
                  color: AppColors.gold500,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_playbackSpeed < 1.0) const Icon(Icons.slow_motion_video, size: 14, color: AppColors.forest900),
                  if (_playbackSpeed < 1.0) const SizedBox(width: 4),
                  Text(
                    '${_playbackSpeed}x',
                    style: AppTypography.labelBold.copyWith(
                      color: _playbackSpeed < 1.0 ? AppColors.forest900 : AppColors.gold400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
