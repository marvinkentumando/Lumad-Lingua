import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/constants.dart';
import '../../models/daily_quest_model.dart';
import '../../providers/daily_quests_provider.dart';
import '../../providers/pronunciation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/app_localizations.dart';
import '../../services/local_ml_service.dart';
import '../../services/admin_config_service.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/audio/recording_button.dart';
import '../../widgets/audio/audio_player_widget.dart';
import '../../widgets/audio/audio_waveform_widget.dart';
import '../../widgets/audio/pitch_contour_widget.dart';
import 'pronunciation_history_screen.dart';

class PronunciationPhrase {
  final String mansaka;
  final String meaning;
  final String? audioPath;

  const PronunciationPhrase({
    required this.mansaka,
    required this.meaning,
    this.audioPath,
  });
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
    const PronunciationPhrase(
      mansaka: 'Madyaw na masurom',
      meaning: 'Good morning',
      audioPath: 'dataset/madyaw_na_masurom/madyaw_na_masurom_1__RUN-2026-0003.wav',
    ),
    const PronunciationPhrase(
      mansaka: 'Madyaw na gabila',
      meaning: 'Good afternoon',
      audioPath: 'dataset/madyaw_na_gabila/madyaw_na_gabila_1__RUN-2026-0003.wav',
    ),
    const PronunciationPhrase(
      mansaka: 'Madyaw na gabi',
      meaning: 'Good evening / Good night',
      audioPath: 'dataset/madyaw_na_gabi/madyaw_na_gabi_1__RUN-2026-0003.wav',
    ),
    const PronunciationPhrase(
      mansaka: 'Tabi kanmo',
      meaning: 'Excuse me (addressing someone)',
      audioPath: 'dataset/tabi_kanmo/tabi_kanmo_1__RUN-2026-0003.wav',
    ),
    const PronunciationPhrase(
      mansaka: 'Ama',
      meaning: 'Father',
      audioPath: 'dataset/ama/ama_1__RUN-2026-0003.wav',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _stopAmplitudePolling();
    _audioRecorder.stop();
    _audioRecorder.dispose();
    _audioPlayer.stop();
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Playback error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isPlayingRecorded = false);
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
    ref.read(pronunciationProvider.notifier).addAttempt(phraseObj.mansaka, finalScore, state.audioPath);

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

    ref.read(dailyQuestsProvider.notifier).incrementProgress(QuestType.pronunciation);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Pronunciation Reward! 🎉', style: AppTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  finalScore >= 85 ? 3 : (finalScore >= 65 ? 2 : 1),
                  (index) => const Icon(Icons.star, color: AppColors.gold500, size: 36),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: AppColors.gold500, size: 22),
                  const SizedBox(width: 4),
                  Text('+$earnedXp XP', style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 16)),
                  const SizedBox(width: 20),
                  const Icon(Icons.diamond, color: AppColors.gold500, size: 22),
                  const SizedBox(width: 4),
                  Text('+$earnedCrystals Crystals', style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 16)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                finalScore >= 85
                    ? 'Fantastic job! Your pronunciation sounds wonderful and clear! 🌟'
                    : 'Good effort! Practice saying it out loud again to get all 3 stars!',
                style: AppTypography.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            BrandButton(
              text: 'Awesome!',
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
    final langCode = ref.watch(localizationProvider);
    final phraseObj = _phrases[_currentPhraseIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(RegionalStrings.get(langCode, 'pronunciationLab'), style: AppTypography.h2.copyWith(color: Colors.white)),
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
                  style: AppTypography.flashcard.copyWith(color: AppColors.textColor(context), fontSize: 32),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Meaning: "${phraseObj.meaning}"',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.subtitleColor(context)),
                ),
                const SizedBox(height: AppSpacing.lg),

                AudioPlayerWidget(
                  audioUrl: phraseObj.audioPath,
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
                  style: AppTypography.labelBold.copyWith(color: AppColors.textColor(context)),
                ),
                if (state.hasRecording) ...[
                  const SizedBox(height: AppSpacing.md),
                  const PitchContourWidget(
                    score: 88.0,
                  ),
                  const SizedBox(height: AppSpacing.md),
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
                            'Your Recording Preview',
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
