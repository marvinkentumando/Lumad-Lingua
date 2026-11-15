import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/constants.dart';
import '../../providers/pronunciation_provider.dart';
import '../../services/local_ml_service.dart';
import '../../services/admin_config_service.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/audio/recording_button.dart';
import '../../widgets/audio/audio_player_widget.dart';
import '../../widgets/audio/audio_waveform_widget.dart';

class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});

  @override
  ConsumerState<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  late AudioPlayer _audioPlayer;
  bool _isPlayingRecorded = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    final notifier = ref.read(pronunciationProvider.notifier);
    final state = ref.read(pronunciationProvider);

    if (state.isRecording) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        notifier.stopRecording(path, Duration.zero);
      }
    } else {
      final permission = await Permission.microphone.request();
      if (permission.isGranted) {
        if (await _audioRecorder.hasPermission()) {
          final directory = await getTemporaryDirectory();
          final String recordPath = '${directory.path}/mock_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
          notifier.startRecording();
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: recordPath,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required to practice pronunciation.')),
          );
        }
      }
    }
  }

  Future<void> _playRecordedAudio() async {
    final state = ref.read(pronunciationProvider);
    if (state.audioPath != null && state.audioPath!.isNotEmpty) {
      try {
        setState(() => _isPlayingRecorded = true);
        await _audioPlayer.setFilePath(state.audioPath!);
        await _audioPlayer.play();
        setState(() => _isPlayingRecorded = false);
      } catch (e) {
        setState(() => _isPlayingRecorded = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playback error: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recorded audio found.')),
      );
    }
  }

  Future<void> _submitAssessment() async {
    final state = ref.read(pronunciationProvider);

    final adminConfig = AdminConfigService();
    final config = await adminConfig.getActiveAlgorithmConfig();
    final algoMode = config['pronunciation_algorithm'] as String? ?? 'dtw_hmm';

    final finalScore = await LocalMlService.evaluatePronunciationFromFileWithConfig(state.audioPath, algoMode);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Pronunciation Assessment', style: AppTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accuracy Score: ${finalScore.toStringAsFixed(1)}%',
                style: AppTypography.displayNumber.copyWith(color: AppColors.forest500, fontSize: 24),
              ),
              const SizedBox(height: 12),
              Text(
                finalScore >= 85
                    ? 'Fantastic job! Your pronunciation and pacing sound natural and clear.'
                    : 'Good effort! Try focusing slightly more on vowel length and tone.',
                style: AppTypography.body,
              ),
            ],
          ),
          actions: [
            BrandButton(
              text: 'OK',
              type: BrandButtonType.primary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pronunciationProvider);

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        title: Text('Pronunciation Lab', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
      ),
      body: LumadBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'TARGET PHRASE',
                  style: AppTypography.labelBold.copyWith(color: AppColors.gold500, letterSpacing: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'Madyaw na masurom',
                  style: AppTypography.flashcard.copyWith(color: AppColors.creamText, fontSize: 32),
                ),
                Text(
                  'Meaning: "Good morning"',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.creamText2),
                ),
                const SizedBox(height: AppSpacing.lg),

                const AudioPlayerWidget(
                  audioUrl: null,
                  title: 'Reference Recording (Mansaka Speaker)',
                ),
                const SizedBox(height: AppSpacing.xl),

                AudioWaveformWidget(isRecording: state.isRecording),
                const SizedBox(height: AppSpacing.md),

                RecordingButton(
                  isRecording: state.isRecording,
                  onTap: _toggleRecording,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.isRecording
                      ? 'Recording... Tap to stop'
                      : (state.hasRecording ? 'Recording Saved' : 'Tap microphone to start recording'),
                  style: AppTypography.labelBold.copyWith(color: AppColors.creamText),
                ),
                if (state.hasRecording) ...[
                  const SizedBox(height: AppSpacing.lg),
                  BrandCard(
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlayingRecorded ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            size: 36,
                            color: AppColors.gold500,
                          ),
                          onPressed: _playRecordedAudio,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your Recording',
                            style: AppTypography.labelBold.copyWith(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.semanticRed),
                          onPressed: () => ref.read(pronunciationProvider.notifier).reset(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BrandButton(
                    text: 'Submit for Assessment',
                    type: BrandButtonType.gold,
                    onPressed: _submitAssessment,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
