import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../models/activity_model.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/learning/lesson_progress_bar.dart';
import '../../widgets/learning/answer_option.dart';
import '../../widgets/audio/audio_player_widget.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  int? _selectedOptionIndex;
  bool? _isAnswerChecked;
  bool _isCorrect = false;

  final List<String> _selectedArrangement = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(lessonSessionProvider.notifier).startLesson(widget.lessonId);
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedOptionIndex = null;
      _isAnswerChecked = null;
      _isCorrect = false;
      _selectedArrangement.clear();
    });
  }

  void _checkAnswer(ActivityModel activity) {
    bool correct = false;

    if (activity.type == ActivityType.multipleChoice ||
        activity.type == ActivityType.listeningExercise) {
      correct = _selectedOptionIndex == activity.correctOptionIndex;
    } else if (activity.type == ActivityType.wordArrangement) {
      if (activity.correctArrangement != null) {
        correct = _selectedArrangement.join(' ') == activity.correctArrangement!.join(' ');
      }
    } else if (activity.type == ActivityType.wordMatching) {
      correct = true;
    } else if (activity.type == ActivityType.pronunciationPractice) {
      correct = true;
    }

    setState(() {
      _isAnswerChecked = true;
      _isCorrect = correct;
    });
  }

  void _nextActivity(ActivityModel activity) {
    ref.read(lessonSessionProvider.notifier).answerCurrentActivity(_isCorrect, activity.xpReward);
    _resetSelection();
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(lessonSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Lesson'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session.isFinished) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(
                '/lesson-result',
                extra: {
                  'earnedXp': session.earnedXp,
                  'stars': session.stars,
                  'score': session.score,
                  'total': session.activities.length,
                },
              );
            });
            return const LoadingWidget(message: 'Calculating rewards...');
          }

          final activity = session.currentActivity;
          if (activity == null) {
            return const Center(child: Text('No activity found.'));
          }

          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                  child: LessonProgressBar(
                    currentStep: session.currentIndex,
                    totalSteps: session.activities.length,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.questionText,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Render based on Activity Type
                        if (activity.type == ActivityType.multipleChoice) ...[
                          if (activity.options != null)
                            ...List.generate(
                              activity.options!.length,
                              (index) => AnswerOptionCard(
                                text: activity.options![index],
                                isSelected: _selectedOptionIndex == index,
                                isCorrect: _isAnswerChecked == true ? _isCorrect : null,
                                onTap: _isAnswerChecked == true
                                    ? () {}
                                    : () {
                                        setState(() => _selectedOptionIndex = index);
                                      },
                              ),
                            ),
                        ] else if (activity.type == ActivityType.listeningExercise) ...[
                          AudioPlayerWidget(
                            audioUrl: activity.audioAssetPath,
                            title: activity.targetMansaka ?? 'Mansaka Phrase',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (activity.options != null)
                            ...List.generate(
                              activity.options!.length,
                              (index) => AnswerOptionCard(
                                text: activity.options![index],
                                isSelected: _selectedOptionIndex == index,
                                isCorrect: _isAnswerChecked == true ? _isCorrect : null,
                                onTap: _isAnswerChecked == true
                                    ? () {}
                                    : () {
                                        setState(() => _selectedOptionIndex = index);
                                      },
                              ),
                            ),
                        ] else if (activity.type == ActivityType.wordArrangement) ...[
                          Container(
                            constraints: const BoxConstraints(minHeight: 60),
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.softGray,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderGray),
                            ),
                            child: Wrap(
                              spacing: 8,
                              children: _selectedArrangement
                                  .map(
                                    (word) => Chip(
                                      label: Text(word),
                                      onDeleted: _isAnswerChecked == true
                                          ? null
                                          : () {
                                              setState(() {
                                                _selectedArrangement.remove(word);
                                              });
                                            },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (activity.wordsToArrange != null)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: activity.wordsToArrange!
                                  .where((word) => !_selectedArrangement.contains(word))
                                  .map(
                                    (word) => ActionChip(
                                      label: Text(word, style: const TextStyle(fontSize: 16)),
                                      onPressed: _isAnswerChecked == true
                                          ? null
                                          : () {
                                              setState(() {
                                                _selectedArrangement.add(word);
                                              });
                                            },
                                    ),
                                  )
                                  .toList(),
                            ),
                        ] else if (activity.type == ActivityType.pronunciationPractice) ...[
                          AudioPlayerWidget(
                            audioUrl: null,
                            title: activity.targetMansaka ?? 'Madyaw na masurom',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.mic),
                              label: const Text('Open Pronunciation Lab'),
                              onPressed: () => context.push('/pronunciation'),
                            ),
                          ),
                        ] else ...[
                          const Text('Follow question instructions above.'),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom Action Feedback Bar
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _isAnswerChecked == true
                        ? (_isCorrect
                            ? AppColors.lightGreenBackground
                            : AppColors.coralRed.withValues(alpha: 0.1))
                        : Colors.white,
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isAnswerChecked == true) ...[
                        Row(
                          children: [
                            Icon(
                              _isCorrect ? Icons.check_circle : Icons.error,
                              color: _isCorrect ? AppColors.forestGreen : AppColors.coralRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCorrect ? 'Excellent! Correct Answer.' : 'Not quite right.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _isCorrect ? AppColors.forestGreen : AppColors.coralRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      AppButton(
                        text: _isAnswerChecked == true
                            ? 'Continue'
                            : 'Check Answer',
                        onPressed: _isAnswerChecked == true
                            ? () => _nextActivity(activity)
                            : () => _checkAnswer(activity),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading lesson activities...'),
        error: (err, stack) => AppErrorWidget(
          message: 'Error starting lesson: $err',
          onRetry: () => ref.read(lessonSessionProvider.notifier).startLesson(widget.lessonId),
        ),
      ),
    );
  }
}
