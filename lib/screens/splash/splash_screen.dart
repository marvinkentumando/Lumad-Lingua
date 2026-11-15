import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/constants.dart';
import '../../widgets/common/lumad_logo_emblem.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;
        if (mounted) {
          if (hasCompletedOnboarding) {
            context.go('/home');
          } else {
            context.go('/onboarding');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.forest700,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LumadLogoEmblem(size: 88, borderRadius: 24),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.appName,
                style: AppTypography.displayBold.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.tagline,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.creamBorder,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
