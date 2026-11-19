import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../models/lesson_model.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';
import '../../utils/audio_helper.dart';

class FlashcardWarmupScreen extends StatefulWidget {
  final LessonModel lesson;

  const FlashcardWarmupScreen({super.key, required this.lesson});

  @override
  State<FlashcardWarmupScreen> createState() => _FlashcardWarmupScreenState();
}

class _FlashcardWarmupScreenState extends State<FlashcardWarmupScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isPlayingAudio = false;
  final Set<int> _reviewedIndices = {0};

  void _nextCard() {
    if (_currentIndex < widget.lesson.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _isPlayingAudio = false;
        _reviewedIndices.add(_currentIndex);
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
        _isPlayingAudio = false;
      });
    }
  }

  Future<void> _playAudio(String? path) async {
    if (_isPlayingAudio) {
      await AudioHelper.stopAudio();
      if (mounted) setState(() => _isPlayingAudio = false);
      return;
    }

    if (path != null && path.isNotEmpty) {
      setState(() => _isPlayingAudio = true);
      await AudioHelper.playAudio(path);
      Future.delayed(const Duration(milliseconds: 2200), () {
        if (mounted) setState(() => _isPlayingAudio = false);
      });
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Playing reference pronunciation audio...')),
      );
    }
  }

  void _startActivities() {
    context.pushReplacement('/lesson/${widget.lesson.id}');
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.forest800,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.modal)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.gold500, size: 28),
            const SizedBox(width: 8),
            Text('Warm-up Complete!', style: AppTypography.h3.copyWith(color: Colors.white)),
          ],
        ),
        content: Text(
          'You reviewed all ${widget.lesson.flashcards.length} vocabulary flashcards. Ready for interactive drills?',
          style: AppTypography.body.copyWith(color: Colors.white),
        ),
        actions: [
          BrandButton(
            text: 'Start Interactive Lesson',
            type: BrandButtonType.gold,
            onPressed: () {
              Navigator.of(context).pop();
              _startActivities();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flashcards = widget.lesson.flashcards;

    if (flashcards.isEmpty) {
      return Scaffold(
        appBar: const LumadTopNavbar(),
        body: LumadBackground(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 64, color: AppColors.gold500),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No flashcards available for this lesson.',
                    style: AppTypography.h3.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BrandButton(
                    text: 'Begin Activities',
                    type: BrandButtonType.gold,
                    onPressed: _startActivities,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final currentCard = flashcards[_currentIndex];
    final progress = (_currentIndex + 1) / flashcards.length;

    return Scaffold(
      appBar: const LumadTopNavbar(),
      body: LumadBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                ScreenHeader(
                  title: 'Flashcard Warm-up',
                  subtitle: widget.lesson.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                // Progress Bar
                Row(
                  children: [
                    Text(
                      'Card ${_currentIndex + 1} of ${flashcards.length}',
                      style: AppTypography.labelBold.copyWith(color: Colors.white),
                    ),
                    const Spacer(),
                    Text(
                      '${(_reviewedIndices.length / flashcards.length * 100).toInt()}% Reviewed',
                      style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.forest700,
                    color: AppColors.gold500,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Interactive 3D Flip Card
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _isFlipped = !_isFlipped);
                      },
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: _isFlipped ? pi : 0),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, angle, child) {
                          final isBack = angle >= pi / 2;
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: isBack
                                ? Transform(
                                    transform: Matrix4.identity()..rotateY(pi),
                                    alignment: Alignment.center,
                                    child: _buildCardBack(currentCard),
                                  )
                                : _buildCardFront(currentCard),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Tap card to flip • Tap button below to listen',
                  style: AppTypography.caption.copyWith(color: AppColors.creamBorder),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Navigation & Action Buttons
                Row(
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: BrandButton(
                          text: 'Previous',
                          type: BrandButtonType.secondary,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _prevCard();
                          },
                        ),
                      ),
                    if (_currentIndex > 0) const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: BrandButton(
                        text: _currentIndex == flashcards.length - 1 ? 'Finish Warm-up' : 'Next Card',
                        type: BrandButtonType.gold,
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          if (_currentIndex < flashcards.length - 1) {
                            _nextCard();
                          } else {
                            _showCompletionDialog();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardFront(LessonFlashcard card) {
    return BrandCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SizedBox(
        width: double.infinity,
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (card.partOfSpeech != null && card.partOfSpeech!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold500,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  card.partOfSpeech!.toUpperCase(),
                  style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 11),
                ),
              ),
            const Spacer(),
            Text(
              card.mansaka,
              style: AppTypography.flashcard.copyWith(color: Colors.white, fontSize: 32),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (card.pronunciation != null && card.pronunciation!.isNotEmpty)
              Text(
                '[ ${card.pronunciation} ]',
                style: AppTypography.phoneticGuide.copyWith(color: AppColors.gold300, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            GestureDetector(
              onTap: () {}, // Intercept tap so card doesn't flip when clicking audio
              child: BrandButton(
                text: _isPlayingAudio ? 'Pause Audio' : 'Listen Audio',
                type: BrandButtonType.secondary,
                icon: _isPlayingAudio ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                onPressed: () => _playAudio(card.audioPath),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(LessonFlashcard card) {
    return BrandCard(
      backgroundColor: AppColors.gold500,
      border: Border.all(color: AppColors.gold700, width: 1.5),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SizedBox(
        width: double.infinity,
        height: 320,
        child: DefaultTextStyle(
          style: const TextStyle(color: AppColors.forest900),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ENGLISH TRANSLATION',
                style: AppTypography.labelBold.copyWith(color: AppColors.forest900, fontSize: 11),
              ),
              const Spacer(),
              Text(
                card.english,
                style: AppTypography.h1ExtraBold.copyWith(color: AppColors.forest900, fontSize: 28),
                textAlign: TextAlign.center,
              ),
              if (card.exampleMansaka != null && card.exampleMansaka!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Example: "${card.exampleMansaka}"',
                  style: AppTypography.caption.copyWith(color: AppColors.forest900, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: BrandButton(
                  text: _isPlayingAudio ? 'Pause Audio' : 'Listen Audio',
                  type: BrandButtonType.primary,
                  icon: _isPlayingAudio ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  onPressed: () => _playAudio(card.audioPath),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
