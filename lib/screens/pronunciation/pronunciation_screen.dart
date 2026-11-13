import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/constants.dart';
import '../../providers/pronunciation_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/audio/recording_button.dart';
import '../../widgets/audio/audio_player_widget.dart';

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

  void _submitAssessment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backend Assessment Unavailable'),
        content: const Text(
          'DTW + SSL Speech Embedding Pronunciation Model is ready for Phase B integration via FastAPI. Frontend audio recording complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pronunciationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pronunciation Lab'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Target Phrase',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Madyaw na masurom',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Text(
                'Meaning: "Good morning"',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),

              const AudioPlayerWidget(
                audioUrl: null,
                title: 'Reference Recording (Mansaka Speaker)',
              ),
              const SizedBox(height: AppSpacing.xl),

              RecordingButton(
                isRecording: state.isRecording,
                onTap: _toggleRecording,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                state.isRecording
                    ? 'Recording... Tap to stop'
                    : (state.hasRecording ? 'Recording Saved' : 'Tap microphone to start recording'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (state.hasRecording) ...[
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isPlayingRecorded ? Icons.pause_circle : Icons.play_circle,
                          size: 36,
                          color: AppColors.blue,
                        ),
                        onPressed: _playRecordedAudio,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Your Recording',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => ref.read(pronunciationProvider.notifier).reset(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'Submit for Assessment',
                  onPressed: _submitAssessment,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
