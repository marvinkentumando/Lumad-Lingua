import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../utils/constants.dart';
import '../../utils/audio_helper.dart';

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

  Future<void> _playAudio() async {
    final resolvedUrl = AudioHelper.resolveSupabaseAudioUrl(widget.audioUrl);

    if (resolvedUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reference audio is currently unavailable for this item.'),
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }

    try {
      if (!_isLoaded) {
        await _player.setUrl(resolvedUrl);
        _isLoaded = true;
      }
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              size: 40,
              color: AppColors.blue,
            ),
            onPressed: _playAudio,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  widget.audioUrl != null ? 'Tap to listen' : 'Audio unavailable (Linguistic review pending)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
