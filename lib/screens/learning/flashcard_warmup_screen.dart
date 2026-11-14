import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import '../../utils/constants.dart';
import '../../utils/audio_helper.dart';
import '../../models/lesson_model.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/brand_button.dart';

class FlashcardWarmupScreen extends ConsumerStatefulWidget {
  final LessonModel lesson;

  const FlashcardWarmupScreen({super.key, required this.lesson});

  @override
  ConsumerState<FlashcardWarmupScreen> createState() => _FlashcardWarmupScreenState();
}

class _FlashcardWarmupScreenState extends ConsumerState<FlashcardWarmupScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  final Set<int> _reviewedIndices = {};
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (widget.lesson.flashcards.isNotEmpty) {
      _reviewedIndices.add(0);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(String? audioPath) async {
    final url = AudioHelper.resolveSupabaseAudioUrl(audioPath);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio not available for this card.')),
      );
      return;
    }

    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing flashcard audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not play audio: $e')),
        );
      }
    }
  }

  void _nextCard() {
    if (_currentIndex < widget.lesson.flashcards.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _reviewedIndices.add(_currentIndex);
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _isFlipped = false;
      });
    }
  }

  void _startActivities() {
    context.pushReplacement('/lesson/${widget.lesson.id}/drills');
  }

  @override
  Widget build(BuildContext context) {
    final flashcards = widget.lesson.flashcards;

    if (flashcards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 64, color: AppColors.forestGreen),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'No flashcards available for this lesson.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                BrandButton(
                  text: 'Begin Activities',
                  onPressed: _startActivities,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentCard = flashcards[_currentIndex];
    final progress = (_currentIndex + 1) / flashcards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.lesson.title} - Warm-up'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              // Progress Bar
              Row(
                children: [
                  Text(
                    'Card ${_currentIndex + 1} of ${flashcards.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '${(_reviewedIndices.length / flashcards.length * 100).toInt()}% Reviewed',
                    style: TextStyle(fontSize: 12, color: AppColors.subtitleColor(context)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.progressTrack,
                color: AppColors.forestGreen,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Interactive Flip Card
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _isFlipped = !_isFlipped),
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
                'Tap card to flip • Tap speaker to listen',
                style: TextStyle(fontSize: 12, color: AppColors.subtitleColor(context)),
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
                        onPressed: _prevCard,
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: BrandButton(
                      text: _currentIndex == flashcards.length - 1 ? 'Finish Warm-up' : 'Next Card',
                      type: BrandButtonType.primary,
                      onPressed: () {
                        if (_currentIndex < flashcards.length - 1) {
                          _nextCard();
                        } else {
                          // Show bottom sheet or proceed to activities
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
    );
  }

  Widget _buildCardFront(LessonFlashcard card) {
    return AppCard(
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
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Text(
                  card.partOfSpeech!.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                ),
              ),
            const Spacer(),
            Text(
              card.mansaka,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textColor(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (card.pronunciation != null && card.pronunciation!.isNotEmpty)
              Text(
                '[ ${card.pronunciation} ]',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: AppColors.subtitleColor(context)),
                textAlign: TextAlign.center,
              ),
            const Spacer(),
            // Listen button that does not trigger card flip
            GestureDetector(
              onTap: () {}, // consume tap
              child: BrandButton(
                text: 'Listen',
                type: BrandButtonType.secondary,
                icon: Icons.volume_up,
                onPressed: () => _playAudio(card.audioPath),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(LessonFlashcard card) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SizedBox(
        width: double.infinity,
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'ENGLISH TRANSLATION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold500),
            ),
            const Spacer(),
            Text(
              card.english,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textColor(context)),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: BrandButton(
                text: 'Replay Audio',
                type: BrandButtonType.secondary,
                icon: Icons.replay,
                onPressed: () => _playAudio(card.audioPath),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warm-up Completed!'),
        content: const Text('Great job reviewing your flashcards. You are ready to start the interactive drills.'),
        actions: [
          BrandButton(
            text: 'Begin Activities',
            onPressed: () {
              Navigator.of(context).pop();
              _startActivities();
            },
          ),
        ],
      ),
    );
  }
}
