import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../utils/constants.dart';
import '../../utils/audio_helper.dart';
import '../../models/lesson_model.dart';
import '../../data/mock_lessons.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import 'flashcard_warmup_screen.dart';

class LessonStudyScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const LessonStudyScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonStudyScreen> createState() => _LessonStudyScreenState();
}

class _LessonStudyScreenState extends ConsumerState<LessonStudyScreen> {
  LessonModel? _lesson;
  bool _isLoading = true;
  String? _error;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadLesson() async {
    try {
      // Find lesson from mockLessons or Firestore
      // For robust offline/mock fallback:
      final found = mockLessons.firstWhere(
        (l) => l.id == widget.lessonId,
        orElse: () => LessonModel(
          id: widget.lessonId,
          unitId: 'unit_1',
          title: 'Lesson Overview',
          description: 'Practice vocabulary and interactive drills.',
          lessonOrder: 1,
          flashcards: [],
        ),
      );

      if (mounted) {
        setState(() {
          _lesson = found;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playAudio(String? audioPath) async {
    final url = AudioHelper.resolveSupabaseAudioUrl(audioPath);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio not available for this item.')),
      );
      return;
    }

    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing preview audio: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson Overview')),
        body: const LoadingWidget(message: 'Loading lesson details...'),
      );
    }

    if (_error != null || _lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson Overview')),
        body: AppErrorWidget(
          message: _error ?? 'Lesson not found.',
          onRetry: _loadLesson,
        ),
      );
    }

    final lesson = _lesson!;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lesson Header Card
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor(context),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold500.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                            border: Border.all(color: AppColors.gold500),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, size: 16, color: AppColors.forestGreen),
                              const SizedBox(width: 4),
                              Text(
                                '+${lesson.xpReward} XP',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lesson.description,
                      style: TextStyle(fontSize: 14, color: AppColors.subtitleColor(context)),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(Icons.style, size: 16, color: AppColors.forestGreen),
                        const SizedBox(width: 6),
                        Text('${lesson.flashcards.length} Flashcards', style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 16),
                        const Icon(Icons.quiz, size: 16, color: AppColors.forestGreen),
                        const SizedBox(width: 6),
                        const Text('Interactive Drills', style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Action CTAs
              BrandButton(
                text: lesson.flashcards.isNotEmpty ? 'Start Flashcard Warm-up' : 'Start Lesson Activities',
                type: BrandButtonType.primary,
                icon: lesson.flashcards.isNotEmpty ? Icons.style : Icons.play_arrow,
                onPressed: () {
                  if (lesson.flashcards.isNotEmpty) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FlashcardWarmupScreen(lesson: lesson),
                      ),
                    );
                  } else {
                    context.push('/lesson/${lesson.id}/drills');
                  }
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              BrandButton(
                text: 'Skip to Activities (Practice Now)',
                type: BrandButtonType.secondary,
                onPressed: () => context.push('/lesson/${lesson.id}/drills'),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Vocabulary Preview List
              if (lesson.flashcards.isNotEmpty) ...[
                const Text(
                  'Vocabulary Preview',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lesson.flashcards.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final card = lesson.flashcards[index];
                    return AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.mansaka,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  card.english,
                                  style: TextStyle(fontSize: 14, color: AppColors.subtitleColor(context)),
                                ),
                                if (card.pronunciation != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '[ ${card.pronunciation} ]',
                                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.forestGreen),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.volume_up, color: AppColors.forestGreen),
                            onPressed: () => _playAudio(card.audioPath),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
