import 'package:flutter_riverpod/flutter_riverpod.dart';

class PronunciationState {
  final bool isRecording;
  final bool hasRecording;
  final String? audioPath;
  final Duration recordingDuration;
  final bool isEvaluating;

  const PronunciationState({
    this.isRecording = false,
    this.hasRecording = false,
    this.audioPath,
    this.recordingDuration = Duration.zero,
    this.isEvaluating = false,
  });

  PronunciationState copyWith({
    bool? isRecording,
    bool? hasRecording,
    String? audioPath,
    Duration? recordingDuration,
    bool? isEvaluating,
  }) {
    return PronunciationState(
      isRecording: isRecording ?? this.isRecording,
      hasRecording: hasRecording ?? this.hasRecording,
      audioPath: audioPath ?? this.audioPath,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      isEvaluating: isEvaluating ?? this.isEvaluating,
    );
  }
}

class PronunciationNotifier extends Notifier<PronunciationState> {
  @override
  PronunciationState build() => const PronunciationState();

  void startRecording() {
    state = state.copyWith(isRecording: true, hasRecording: false);
  }

  void stopRecording(String path, Duration duration) {
    state = state.copyWith(
      isRecording: false,
      hasRecording: true,
      audioPath: path,
      recordingDuration: duration,
    );
  }

  void reset() {
    state = const PronunciationState();
  }
}

final pronunciationProvider = NotifierProvider<PronunciationNotifier, PronunciationState>(() {
  return PronunciationNotifier();
});
