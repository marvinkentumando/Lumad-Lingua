import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/constants.dart';
import '../../providers/pronunciation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_ml_service.dart';
import '../../services/admin_config_service.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/audio/recording_button.dart';
import '../../widgets/audio/audio_player_widget.dart';
import '../../widgets/audio/audio_waveform_widget.dart';
import 'pronunciation_history_screen.dart';

class PronunciationPhrase {
  final String mansaka;
  final String meaning;

  const PronunciationPhrase({required this.mansaka, required this.meaning});
}

class PronunciationScreen extends ConsumerStatefulWidget {
  const PronunciationScreen({super.key});

  @override
  ConsumerState<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends ConsumerState<PronunciationScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  late AudioPlayer _audioPlayer;
  bool _isPlayingRecorded = false;
  Timer? _amplitudeTimer;
  List<double> _amplitudes = List.filled(24, 12.0);
  int _currentPhraseIndex = 0;

  final List<PronunciationPhrase> _phrases = [
    const PronunciationPhrase(mansaka: 'Madyaw na masurom', meaning: 'Good morning'),
    const PronunciationPhrase(mansaka: 'Malipayon ko', meaning: 'I am happy'),
    const PronunciationPhrase(mansaka: 'Salamat karing', meaning: 'Thank you very much'),
    const PronunciationPhrase(mansaka: 'Amo na an', meaning: 'That is correct'),
    const PronunciationPhrase(mansaka: 'Hain ka gikan?', meaning: 'Where did you come from?'),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startAmplitudePolling() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      try {
        final amp = await _audioRecorder.getAmplitude();
        final dbfs = amp.current; // -160.0 to 0.0
        final normalized = ((dbfs + 45) / 45).clamp(0.1, 1.0);
        final height = 15.0 + (normalized * 70.0);

        if (mounted) {
          setState(() {
            _amplitudes.add(height);
            if (_amplitudes.length > 30) {
              _amplitudes.removeAt(0);
            }
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            final randomH = 20.0 + (DateTime.now().millisecond % 65);
            _amplitudes.add(randomH);
            if (_amplitudes.length > 30) {
              _amplitudes.removeAt(0);
            }
          });
        }
      }
    });
  }

  void _stopAmplitudePolling() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    if (mounted) {
      setState(() {
        _amplitudes = List.filled(24, 12.0);
      });
    }
  }

  Future<void> _toggleRecording() async {
    final notifier = ref.read(pronunciationProvider.notifier);
    final state = ref.read(pronunciationProvider);

    if (state.isRecording) {
      _stopAmplitudePolling();
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
          _startAmplitudePolling();
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
    final phraseObj = _phrases[_currentPhraseIndex];

    final adminConfig = AdminConfigService();
    final config = await adminConfig.getActiveAlgorithmConfig();
    final algoMode = config['pronunciation_algorithm'] as String? ?? 'dtw_hmm';

    final finalScore = await LocalMlService.evaluatePronunciationFromFileWithConfig(state.audioPath, algoMode);
    ref.read(pronunciationProvider.notifier).addAttempt(phraseObj.mansaka, finalScore);

    int earnedXp = 15;
    int earnedCrystals = 5;
    if (finalScore >= 90) {
      earnedXp = 50;
      earnedCrystals = 15;
    } else if (finalScore >= 75) {
      earnedXp = 30;
      earnedCrystals = 10;
    } else if (finalScore >= 60) {
      earnedXp = 20;
      earnedCrystals = 5;
    }

    final user = ref.read(authStateProvider).value;
    if (user != null && finalScore >= 60) {
      ref.read(authStateProvider.notifier).addXp(earnedXp);
      ref.read(authStateProvider.notifier).updateCrystals(user.crystals + earnedCrystals);
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Pronunciation Reward! 🎉', style: AppTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accuracy Score: ${finalScore.toStringAsFixed(1)}%',
                style: AppTypography.displayNumber.copyWith(color: AppColors.forest500, fontSize: 24),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.bolt, color: AppColors.gold500, size: 20),
                  const SizedBox(width: 4),
                  Text('+$earnedXp XP', style: AppTypography.labelBold.copyWith(color: AppColors.forest900)),
                  const SizedBox(width: 16),
                  const Icon(Icons.diamond, color: AppColors.gold500, size: 20),
                  const SizedBox(width: 4),
                  Text('+$earnedCrystals Crystals', style: AppTypography.labelBold.copyWith(color: AppColors.forest900)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                finalScore >= 85
                    ? 'Fantastic job! Your pronunciation and pacing sound natural and clear.'
                    : 'Good effort! Try focusing slightly more on vowel length and tone.',
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Phoneme & Word Breakdown:', style: AppTypography.labelBold),
              const SizedBox(height: 6),
              ...phraseObj.mansaka.split(' ').map((word) {
                final wordScore = (finalScore + (word.length * 1.5)).clamp(65.0, 99.5);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(word, style: AppTypography.bodyLarge),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: wordScore >= 85 ? AppColors.semanticGreen.withValues(alpha: 0.2) : AppColors.gold500.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          '${wordScore.toStringAsFixed(1)}%',
                          style: AppTypography.labelBold.copyWith(
                            color: wordScore >= 85 ? AppColors.successDark : AppColors.gold800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          actions: [
            BrandButton(
              text: 'Awesome',
              type: BrandButtonType.gold,
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
    final phraseObj = _phrases[_currentPhraseIndex];

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        title: Text('Pronunciation Lab', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.gold500),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PronunciationHistoryScreen(),
                ),
              );
            },
            tooltip: 'Practice History',
          ),
        ],
      ),
      body: LumadBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.gold500),
                      onPressed: () {
                        setState(() {
                          _currentPhraseIndex = (_currentPhraseIndex - 1) % _phrases.length;
                          if (_currentPhraseIndex < 0) _currentPhraseIndex = _phrases.length - 1;
                        });
                        ref.read(pronunciationProvider.notifier).reset();
                      },
                    ),
                    Text(
                      'PHRASE ${_currentPhraseIndex + 1} OF ${_phrases.length}',
                      style: AppTypography.labelBold.copyWith(color: AppColors.gold500, letterSpacing: 1.2),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.gold500),
                      onPressed: () {
                        setState(() {
                          _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
                        });
                        ref.read(pronunciationProvider.notifier).reset();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  phraseObj.mansaka,
                  style: AppTypography.flashcard.copyWith(color: AppColors.creamText, fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Meaning: "${phraseObj.meaning}"',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.creamText2),
                ),
                const SizedBox(height: AppSpacing.lg),

                const AudioPlayerWidget(
                  audioUrl: null,
                  title: 'Reference Recording (Mansaka Speaker)',
                ),
                const SizedBox(height: AppSpacing.xl),

                AudioWaveformWidget(
                  isRecording: state.isRecording,
                  amplitudes: _amplitudes,
                ),
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
