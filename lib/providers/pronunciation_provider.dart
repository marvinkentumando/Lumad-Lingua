import 'package:flutter_riverpod/flutter_riverpod.dart';

class PronunciationAttempt {
  final String phrase;
  final double score;
  final DateTime timestamp;

  const PronunciationAttempt({
    required this.phrase,
    required this.score,
    required this.timestamp,
  });
}

class PronunciationState {
  final bool isRecording;
  final bool hasRecording;
  final String? audioPath;
  final Duration recordingDuration;
  final bool isEvaluating;
  final List<PronunciationAttempt> history;

  const PronunciationState({
    this.isRecording = false,
    this.hasRecording = false,
    this.audioPath,
    this.recordingDuration = Duration.zero,
    this.isEvaluating = false,
    this.history = const [],
  });

  PronunciationState copyWith({
    bool? isRecording,
    bool? hasRecording,
    String? audioPath,
    Duration? recordingDuration,
    bool? isEvaluating,
    List<PronunciationAttempt>? history,
  }) {
    return PronunciationState(
      isRecording: isRecording ?? this.isRecording,
      hasRecording: hasRecording ?? this.hasRecording,
      audioPath: audioPath ?? this.audioPath,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      isEvaluating: isEvaluating ?? this.isEvaluating,
      history: history ?? this.history,
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

  void addAttempt(String phrase, double score) {
    final updated = List<PronunciationAttempt>.from(state.history)
      ..insert(0, PronunciationAttempt(phrase: phrase, score: score, timestamp: DateTime.now()));
    state = state.copyWith(history: updated);
  }

  void reset() {
    state = PronunciationState(history: state.history);
  }
}

final pronunciationProvider = NotifierProvider<PronunciationNotifier, PronunciationState>(() {
  return PronunciationNotifier();
});
