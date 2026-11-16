import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../utils/constants.dart';
import '../../utils/audio_helper.dart';
import '../../models/lesson_model.dart';
import '../../data/mock_lessons.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/screen_header.dart';
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
        appBar: const LumadTopNavbar(),
        body: LumadBackground(
          child: const LoadingWidget(message: 'Loading lesson details...'),
        ),
      );
    }

    if (_error != null || _lesson == null) {
      return Scaffold(
        appBar: const LumadTopNavbar(),
        body: LumadBackground(
          child: AppErrorWidget(
            message: _error ?? 'Lesson not found.',
            onRetry: _loadLesson,
          ),
        ),
      );
    }

    final lesson = _lesson!;

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: lesson.title,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Lesson Overview Header Card
                BrandCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              lesson.title,
                              style: AppTypography.h2.copyWith(color: Colors.white, fontSize: 22),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gold500,
                              borderRadius: BorderRadius.circular(AppRadius.chip),
                              border: Border.all(color: AppColors.gold700),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, size: 16, color: AppColors.forest900),
                                const SizedBox(width: 4),
                                Text(
                                  '+${lesson.xpReward} XP',
                                  style: AppTypography.labelBold.copyWith(color: AppColors.forest900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lesson.description,
                        style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(Icons.style, size: 16, color: AppColors.gold500),
                          const SizedBox(width: 6),
                          Text('${lesson.flashcards.length} Flashcards', style: AppTypography.caption.copyWith(color: Colors.white)),
                          const SizedBox(width: 16),
                          const Icon(Icons.quiz, size: 16, color: AppColors.gold500),
                          const SizedBox(width: 6),
                          Text('Interactive Drills', style: AppTypography.caption.copyWith(color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Vocabulary Preview List
                if (lesson.flashcards.isNotEmpty) ...[
                  Text(
                    'Vocabulary Preview',
                    style: AppTypography.h3,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lesson.flashcards.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final card = lesson.flashcards[index];
                      return BrandCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    card.mansaka,
                                    style: AppTypography.lessonTitle.copyWith(color: Colors.white, fontSize: 18),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    card.english,
                                    style: AppTypography.bodyLarge.copyWith(color: AppColors.creamBorder),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _playAudio(card.audioPath);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.volume_up_rounded,
                                  color: AppColors.gold500,
                                  size: 26,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // Action CTAs (Moved to lower part)
                BrandButton(
                  text: lesson.flashcards.isNotEmpty ? 'Start Flashcard Warm-up' : 'Start Lesson Activities',
                  type: BrandButtonType.gold,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
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
                const SizedBox(height: AppSpacing.md),
                BrandButton(
                  text: 'Skip to Activities (Practice Now)',
                  type: BrandButtonType.secondary,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/lesson/${lesson.id}/drills');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
