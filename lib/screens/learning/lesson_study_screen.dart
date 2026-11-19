import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../models/lesson_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../utils/audio_helper.dart';

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
  String? _playingCardId;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    try {
      final firestoreService = FirestoreService();
      final units = await firestoreService.getUnits();
      LessonModel? found;

      for (final unit in units) {
        final unitLessons = await firestoreService.getLessonsForUnitInternal(unit.id);
        try {
          found = unitLessons.firstWhere((l) => l.id == widget.lessonId);
          break;
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _lesson = found;
          _isLoading = false;
          if (found == null) {
            _error = 'Lesson not found in Firebase.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading lesson: $e';
        });
      }
    }
  }

  Future<void> _playAudio(String? path, [String? cardId]) async {
    if (_playingCardId == cardId) {
      await AudioHelper.stopAudio();
      if (mounted) setState(() => _playingCardId = null);
      return;
    }

    if (path != null && path.isNotEmpty) {
      setState(() => _playingCardId = cardId);
      await AudioHelper.playAudio(path);
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (mounted && _playingCardId == cardId) {
          setState(() => _playingCardId = null);
        }
      });
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playing reference pronunciation audio...')),
      );
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
                const ScreenHeader(
                  title: 'Lesson Overview',
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
                      final isPlaying = _playingCardId == card.id;

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
                                _playAudio(card.audioPath, card.id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                                  color: AppColors.gold500,
                                  size: 28,
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
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (lesson.flashcards.isNotEmpty) {
                      context.push('/lesson-warmup', extra: lesson);
                    } else {
                      context.push('/lesson/${lesson.id}');
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                BrandButton(
                  text: 'Back to Learning Path',
                  type: BrandButtonType.secondary,
                  icon: Icons.arrow_back,
                  onPressed: () => context.pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
