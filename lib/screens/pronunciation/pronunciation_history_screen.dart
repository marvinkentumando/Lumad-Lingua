import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../utils/constants.dart';
import '../../providers/pronunciation_provider.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/audio/audio_player_widget.dart';

class PronunciationHistoryScreen extends ConsumerWidget {
  const PronunciationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pronunciationProvider);
    final history = state.history;

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              const ScreenHeader(
                title: 'Practice History',
                subtitle: 'Re-listen to your voice attempts and compare side-by-side with native reference audio',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (history.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, size: 64, color: AppColors.creamText3),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No practice history yet. Record some phrases in the Pronunciation Lab!',
                        style: AppTypography.h3.copyWith(color: AppColors.subtitleColor(context)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BrandButton(
                        text: 'Go to Pronunciation Lab 🎙️',
                        type: BrandButtonType.gold,
                        onPressed: () => context.push('/pronunciation'),
                      ),
                    ],
                  ),
                )
              else
                ...history.map((attempt) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: _HistoryAttemptCard(attempt: attempt),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryAttemptCard extends StatefulWidget {
  final PronunciationAttempt attempt;

  const _HistoryAttemptCard({required this.attempt});

  @override
  State<_HistoryAttemptCard> createState() => _HistoryAttemptCardState();
}

class _HistoryAttemptCardState extends State<_HistoryAttemptCard> {
  late AudioPlayer _audioPlayer;
  bool _isPlayingMyRecording = false;
  double _learnerSpeed = 1.0;
  static const List<double> _speeds = [1.0, 0.75, 0.5];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleLearnerSpeed() {
    final nextIndex = (_speeds.indexOf(_learnerSpeed) + 1) % _speeds.length;
    final nextSpeed = _speeds[nextIndex];
    setState(() => _learnerSpeed = nextSpeed);
    _audioPlayer.setSpeed(nextSpeed);

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Learner recording speed set to ${nextSpeed}x ${nextSpeed < 1.0 ? '🐢 (Slow Motion Vowel Analysis)' : '⚡'}'),
          duration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  Future<void> _playMyRecording() async {
    final path = widget.attempt.audioPath;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recorded audio file found for this past attempt.')),
      );
      return;
    }

    final file = File(path);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recorded audio file is no longer cached locally.')),
        );
      }
      return;
    }

    try {
      if (_isPlayingMyRecording) {
        await _audioPlayer.stop();
        setState(() => _isPlayingMyRecording = false);
        return;
      }

      await _audioPlayer.setFilePath(path);
      await _audioPlayer.setSpeed(_learnerSpeed);
      setState(() => _isPlayingMyRecording = true);
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      if (mounted) {
        setState(() => _isPlayingMyRecording = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPlayingMyRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing recording: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final attempt = widget.attempt;

    return BrandCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attempt.phrase,
                      style: AppTypography.lessonTitle.copyWith(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${attempt.timestamp.hour.toString().padLeft(2, '0')}:${attempt.timestamp.minute.toString().padLeft(2, '0')} • ${attempt.timestamp.day}/${attempt.timestamp.month}/${attempt.timestamp.year}',
                      style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold500,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  '${attempt.score.toStringAsFixed(1)}%',
                  style: AppTypography.labelBold.copyWith(color: AppColors.forest900),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(color: AppColors.forest700),
          const SizedBox(height: AppSpacing.xs),

          // Side-by-side Audio Controls with Speed Controls
          Row(
            children: [
              // Play My Recording Button
              Expanded(
                child: GestureDetector(
                  onTap: _playMyRecording,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.forest800,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                      border: Border.all(color: AppColors.gold500.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPlayingMyRecording ? Icons.stop_circle : Icons.play_circle_fill,
                          color: AppColors.gold500,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _isPlayingMyRecording ? 'Playing...' : 'My Attempt 🎙️',
                            style: AppTypography.labelBold.copyWith(color: Colors.white, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Learner Recording Slow-Motion Speed Chip Toggle
              GestureDetector(
                onTap: _toggleLearnerSpeed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _learnerSpeed < 1.0 ? AppColors.gold500 : AppColors.forest800,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                    border: Border.all(color: AppColors.gold500, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_learnerSpeed < 1.0) const Icon(Icons.slow_motion_video, size: 14, color: AppColors.forest900),
                      if (_learnerSpeed < 1.0) const SizedBox(width: 4),
                      Text(
                        '${_learnerSpeed}x',
                        style: AppTypography.labelBold.copyWith(
                          color: _learnerSpeed < 1.0 ? AppColors.forest900 : AppColors.gold400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Side-by-Side Elder Reference Audio Player (with 1.0x / 0.75x / 0.5x Slow-Motion toggle)
          AudioPlayerWidget(
            title: '${attempt.phrase} (Reference)',
            audioUrl: null,
          ),
        ],
      ),
    );
  }
}
