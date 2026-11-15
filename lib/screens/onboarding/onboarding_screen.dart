import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/brand_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Learn Mansaka Language',
      'description': 'Gamified interactive lessons designed to preserve and celebrate indigenous Mansaka culture.',
      'icon': 'school',
      'isFlashcard': false,
    },
    {
      'title': 'Practice Pronunciation',
      'description': 'Listen to reference audio and practice speaking with real-time feedback.',
      'icon': 'record_voice_over',
      'isFlashcard': false,
    },
    {
      'title': 'First Mansaka Word',
      'description': 'Preview how vocabulary flashcards teach you authentic expressions:',
      'icon': 'translate',
      'isFlashcard': true,
      'mansaka': 'Madyaw na masurom',
      'pronunciation': 'Mad-yaw na ma-su-rom',
      'translation': 'Good morning',
    },
    {
      'title': 'Earn Rewards & Streaks',
      'description': 'Track your daily progress, earn XP, unlock achievements, and climb learning levels.',
      'icon': 'emoji_events',
      'isFlashcard': false,
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Skip', style: TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    final isFlashcard = item['isFlashcard'] == true;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!isFlashcard) ...[
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: const BoxDecoration(
                              color: AppColors.lightGreenBackground,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getIcon(item['icon']!),
                              size: 80,
                              color: AppColors.forestGreen,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ] else ...[
                          BrandCard(
                            backgroundColor: AppColors.gold100,
                            border: Border.all(color: AppColors.gold500, width: 2),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.volume_up_rounded, color: AppColors.gold800, size: 28),
                                    const SizedBox(width: 8),
                                    Text('Mansaka Flashcard', style: AppTypography.labelBold.copyWith(color: AppColors.gold800)),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  item['mansaka']!,
                                  style: AppTypography.flashcard.copyWith(color: AppColors.forest900, fontSize: 26),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '[ ${item['pronunciation']} ]',
                                  style: AppTypography.phoneticGuide.copyWith(color: AppColors.forest700),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  '"${item['translation']}"',
                                  style: AppTypography.h3.copyWith(color: AppColors.forest800),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: AppTypography.h1.copyWith(color: AppColors.darkCharcoal),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          item['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.darkCharcoal.withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.forestGreen
                          : AppColors.borderGray,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'school':
        return Icons.school;
      case 'record_voice_over':
        return Icons.record_voice_over;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'translate':
        return Icons.translate;
      default:
        return Icons.star;
    }
  }
}
