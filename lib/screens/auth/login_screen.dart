import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_logo_emblem.dart';
import '../../widgets/common/lumad_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: AppColors.semanticRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: LumadBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    // Centered Lumad Logo Emblem with Ancestral Glow
                    const LumadLogoEmblem(size: 68, borderRadius: 18),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Welcome Back!',
                      style: AppTypography.h1ExtraBold.copyWith(color: AppColors.textColor(context), fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign in to preserve Mansaka heritage & sync your progress',
                      style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Card Form Container
                    BrandCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Address',
                            style: AppTypography.labelBold.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _emailController,
                            validator: AppValidators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.forest900),
                            decoration: InputDecoration(
                              hintText: 'Enter your email',
                              hintStyle: AppTypography.body.copyWith(color: AppColors.creamText3),
                              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.forest500),
                              filled: true,
                              fillColor: AppColors.creamSurface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                borderSide: const BorderSide(color: AppColors.creamBorder, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                borderSide: const BorderSide(color: AppColors.creamBorder, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                borderSide: const BorderSide(color: AppColors.gold500, width: 2.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Password',
                            style: AppTypography.labelBold.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _passwordController,
                            validator: AppValidators.validatePassword,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _handleLogin(),
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.forest900),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: AppTypography.body.copyWith(color: AppColors.creamText3),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.forest500),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.forest500,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: AppColors.creamSurface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                borderSide: const BorderSide(color: AppColors.creamBorder, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                borderSide: const BorderSide(color: AppColors.creamBorder, width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.button),
                                borderSide: const BorderSide(color: AppColors.gold500, width: 2.0),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              child: Text(
                                'Forgot Password?',
                                style: AppTypography.labelBold.copyWith(color: AppColors.gold500),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          BrandButton(
                            text: 'Sign In',
                            type: BrandButtonType.gold,
                            isLoading: authState.isLoading,
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Guest Exploration Secondary CTA
                    BrandButton(
                      text: 'Continue as Guest Learner',
                      type: BrandButtonType.secondary,
                      icon: Icons.explore,
                      onPressed: () => context.go('/home'),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Bottom Register Redirect Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Create Account',
                            style: AppTypography.labelBold.copyWith(
                              color: AppColors.gold500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
