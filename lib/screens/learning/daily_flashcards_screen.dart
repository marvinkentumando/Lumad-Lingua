import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:confetti/confetti.dart';
import '../../utils/constants.dart';
import '../../models/vocabulary_model.dart';
import '../../data/mock_vocabulary.dart';
import '../../providers/auth_provider.dart';
import '../../utils/audio_helper.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';
import '../../widgets/common/lumad_top_navbar.dart';
import '../../widgets/common/screen_header.dart';

class DailyFlashcardsScreen extends ConsumerStatefulWidget {
  const DailyFlashcardsScreen({super.key});

  @override
  ConsumerState<DailyFlashcardsScreen> createState() => _DailyFlashcardsScreenState();
}

class _DailyFlashcardsScreenState extends ConsumerState<DailyFlashcardsScreen> {
  late List<VocabularyModel> _dailyWords;
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _isCompleted = false;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadDailyWords();
  }

  void _loadDailyWords() {
    final random = Random();
    final shuffled = List<VocabularyModel>.from(mockVocabularyList)..shuffle(random);
    // Take up to 10 words
    _dailyWords = shuffled.take(10).toList();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _flipCard() {
    HapticFeedback.lightImpact();
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard() {
    if (_currentIndex < _dailyWords.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
      _confettiController.play();
      AudioHelper.playSfx(AudioHelper.sfxSuccess);

      // Reward user with +50 XP and +10 Crystals
      final authNotifier = ref.read(authStateProvider.notifier);
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        authNotifier.addXp(50);
        authNotifier.updateCrystals(user.crystals + 10);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dailyWords.isEmpty) {
      return Scaffold(
        appBar: const LumadTopNavbar(),
        body: LumadBackground(
          child: Center(
            child: Text('No vocabulary available.', style: AppTypography.h3.copyWith(color: Colors.white)),
          ),
        ),
      );
    }

    if (_isCompleted) {
      return Scaffold(
        appBar: const LumadTopNavbar(),
        body: LumadBackground(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: BrandCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.celebration, size: 64, color: AppColors.gold500),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Daily Flashcards Complete! 🎉',
                          style: AppTypography.h2.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'You reviewed all 10 daily Mansaka vocabulary words.',
                          style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.gold500.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            border: Border.all(color: AppColors.gold500),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.flash_on, color: AppColors.gold400),
                              const SizedBox(width: 8),
                              Text('+50 XP • +10 Crystals Earned! 💎', style: AppTypography.labelBold.copyWith(color: AppColors.gold400)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        BrandButton(
                          text: 'Back to Home',
                          type: BrandButtonType.gold,
                          onPressed: () => context.go('/home'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [AppColors.gold500, AppColors.forestGreen, Colors.amber],
              ),
            ],
          ),
        ),
      );
    }

    final word = _dailyWords[_currentIndex];

    return Scaffold(
      appBar: const LumadTopNavbar(title: 'Daily 10 Flashcards'),
      body: LumadBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                ScreenHeader(
                  title: 'Card ${_currentIndex + 1} of ${_dailyWords.length}',
                  subtitle: 'Tap card to flip between Mansaka and English definition',
                ),
                const SizedBox(height: AppSpacing.lg),

                // Flashcard Flip View
                Expanded(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: _isFlipped ? AppColors.forest800 : AppColors.cardColor(context),
                        borderRadius: BorderRadius.circular(AppRadius.modal),
                        border: Border.all(
                          color: _isFlipped ? AppColors.gold500 : AppColors.forest700,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 8),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.gold500.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _isFlipped ? 'ENGLISH DEFINITION' : 'MANSAKA HEADWORD',
                              style: AppTypography.labelBold.copyWith(color: AppColors.gold400, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            _isFlipped ? word.translation : word.headword,
                            style: AppTypography.h1ExtraBold.copyWith(
                              color: Colors.white,
                              fontSize: _isFlipped ? 26 : 36,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (!_isFlipped && word.partOfSpeech.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              '(${word.partOfSpeech})',
                              style: AppTypography.body.copyWith(color: AppColors.gold400),
                            ),
                          ],
                          if (_isFlipped && word.examples.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.lg),
                            const Divider(color: AppColors.forest700),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Example:',
                              style: AppTypography.labelBold.copyWith(color: AppColors.gold400),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '"${word.examples.first.mansaka}"',
                              style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              word.examples.first.english,
                              style: AppTypography.body.copyWith(color: AppColors.creamBorder),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.touch_app, color: AppColors.creamBorder, size: 18),
                              const SizedBox(width: 6),
                              Text('Tap anywhere to flip card', style: AppTypography.caption.copyWith(color: AppColors.creamBorder)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Next Button
                BrandButton(
                  text: _currentIndex < _dailyWords.length - 1 ? 'Next Card ➡️' : 'Complete Review 🎉',
                  type: BrandButtonType.gold,
                  onPressed: _nextCard,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
