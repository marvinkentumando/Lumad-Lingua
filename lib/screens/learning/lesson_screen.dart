import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../models/activity_model.dart';
import '../../providers/activity_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/audio_helper.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/learning/lesson_progress_bar.dart';
import '../../widgets/learning/answer_option.dart';
import '../../widgets/audio/audio_player_widget.dart';
import '../../widgets/audio/recording_button.dart';
import '../../widgets/audio/pitch_contour_widget.dart';
import '../../services/local_ml_service.dart';

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
  bool _isRecording = false;
  bool _isOutOfHeartsDialogShown = false;

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
      _isRecording = false;
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

    final soundEffectsEnabled = ref.read(soundEffectsProvider);
    if (correct) {
      HapticFeedback.lightImpact();
      AudioHelper.playSfx(AudioHelper.sfxCorrect, enabled: soundEffectsEnabled);
    } else {
      HapticFeedback.heavyImpact();
      AudioHelper.playSfx(AudioHelper.sfxError, enabled: soundEffectsEnabled);
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

  void _showHeartInfoModal(int currentHearts) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.forest800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.modal)),
        title: Row(
          children: [
            const Icon(Icons.favorite, color: AppColors.semanticRed, size: 28),
            const SizedBox(width: 8),
            Text('Heart Regeneration', style: AppTypography.h3.copyWith(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have $currentHearts / 5 hearts remaining.', style: AppTypography.body.copyWith(color: Colors.white)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.forest900,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.forest700),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.gold500, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Next Heart Refill in', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                        const SizedBox(height: 2),
                        Text('18:42 mins', style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          BrandButton(
            text: 'Practice to Earn Heart',
            type: BrandButtonType.primary,
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(lessonSessionProvider.notifier).refillHearts();
              _isOutOfHeartsDialogShown = false;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Practice completed! +1 Heart restored. 💖')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(lessonSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: sessionAsync.when(
          data: (session) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Interactive Lesson'),
              const Spacer(),
              GestureDetector(
                onTap: () => _showHeartInfoModal(session.hearts),
                child: Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < session.hearts ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.semanticRed,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.timer, color: AppColors.gold500, size: 14),
                  ],
                ),
              ),
            ],
          ),
          loading: () => const Text('Interactive Lesson'),
          error: (err, stack) => const Text('Interactive Lesson'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: Colors.white70),
            tooltip: 'Report Question',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Question reported to instructors. Thank you! 🚩')),
              );
            },
          ),
        ],
      ),
      body: sessionAsync.when(
        data: (session) {
          if (session.hearts == 0) {
            if (!_isOutOfHeartsDialogShown) {
              _isOutOfHeartsDialogShown = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => AlertDialog(
                    title: Text('Out of Hearts! 💔', style: AppTypography.h3),
                    content: Text('You have lost all 5 hearts due to mistakes. Refill your hearts with 30 crystals or exit the lesson.', style: AppTypography.body),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (context.mounted) context.pop();
                        },
                        child: const Text('Exit Lesson'),
                      ),
                      BrandButton(
                        text: 'Practice Drills',
                        type: BrandButtonType.primary,
                        onPressed: () {
                          ref.read(lessonSessionProvider.notifier).refillHearts();
                          _isOutOfHeartsDialogShown = false;
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quick practice completed! Hearts restored. 💖')),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      BrandButton(
                        text: 'Refill Hearts (-30 Crystals)',
                        type: BrandButtonType.gold,
                        onPressed: () {
                          final user = ref.read(authStateProvider).value;
                          if (user != null && user.crystals >= 30) {
                            ref.read(authStateProvider.notifier).updateCrystals(user.crystals - 30);
                            ref.read(lessonSessionProvider.notifier).refillHearts();
                            _isOutOfHeartsDialogShown = false;
                            Navigator.of(dialogContext).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Not enough crystals for heart refill!')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              });
            }
            return const Center(child: Text('Out of hearts.'));
          }

          if (session.isFinished) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(
                '/lesson-result',
                extra: {
                  'lessonId': session.lessonId,
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

          final isDark = Theme.of(context).brightness == Brightness.dark;

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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                activity.questionText,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.darkCharcoal,
                                ),
                              ),
                            ),
                            if (activity.audioAssetPath != null && activity.audioAssetPath!.isNotEmpty) ...[
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: AppColors.gold500),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Playing audio pronunciation...')),
                                  );
                                },
                              ),
                            ],
                            if (activity.type == ActivityType.multipleChoice && activity.options != null && activity.correctOptionIndex != null) ...[
                              IconButton(
                                icon: const Icon(Icons.lightbulb_outline, color: AppColors.gold500),
                                tooltip: 'Get Hint (-5 Crystals)',
                                onPressed: () {
                                  final user = ref.read(authStateProvider).value;
                                  if (user != null && user.crystals >= 5) {
                                    ref.read(authStateProvider.notifier).updateCrystals(user.crystals - 5);
                                    setState(() {
                                      _selectedOptionIndex = activity.correctOptionIndex;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Hint applied! Correct option highlighted (-5 Crystals).')),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Not enough crystals for a hint!')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ],
                        ).animate(target: _isAnswerChecked == true && !_isCorrect ? 1 : 0).shake(hz: 4, offset: const Offset(6, 0)),
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
                            title: 'Listen to Audio',
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
                            padding: const EdgeInsets.all(AppSpacing.md),
                            constraints: const BoxConstraints(minHeight: 60),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(AppRadius.button),
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
                            child: Column(
                              children: [
                                RecordingButton(
                                  isRecording: _isRecording,
                                  onTap: () {
                                    setState(() => _isRecording = !_isRecording);
                                  },
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _isRecording ? 'Listening to your speech...' : 'Tap mic to record pronunciation',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _isRecording ? AppColors.semanticRed : AppColors.forestGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          PitchContourWidget(
                            referencePitchPoints: LocalMlService.generateReferencePitchContour(activity.targetMansaka ?? 'Madyaw na masurom'),
                            score: _isAnswerChecked == true ? 92.0 : 85.0,
                            phraseTitle: activity.targetMansaka ?? 'Madyaw na masurom',
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
                            ? (isDark ? const Color(0xFF1B3822) : AppColors.lightGreenBackground)
                            : (isDark ? const Color(0xFF381518) : AppColors.coralRed.withValues(alpha: 0.1)))
                        : (isDark ? AppColors.forest800 : Colors.white),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isAnswerChecked == true) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            if (_isCorrect) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gold500,
                                  borderRadius: BorderRadius.circular(AppRadius.chip),
                                ),
                                child: Text(
                                  '+${activity.xpReward} XP',
                                  style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 12),
                                ),
                              ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
                            ],
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
                ).animate().fadeIn(duration: 200.ms),
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
