import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../widgets/common/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Learn Mansaka Language',
      'description': 'Gamified interactive lessons designed to preserve and celebrate indigenous Mansaka culture.',
      'icon': 'school',
    },
    {
      'title': 'Practice Pronunciation',
      'description': 'Listen to reference audio and practice speaking with real-time feedback.',
      'icon': 'record_voice_over',
    },
    {
      'title': 'Earn Rewards & Streaks',
      'description': 'Track your daily progress, earn XP, unlock achievements, and climb learning levels.',
      'icon': 'emoji_events',
    },
  ];

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
                  onPressed: () => context.go('/login'),
                  child: const Text('Skip', style: TextStyle(color: AppColors.forestGreen)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                        Text(
                          item['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          item['description']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
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
                    context.go('/login');
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
      default:
        return Icons.star;
    }
  }
}
