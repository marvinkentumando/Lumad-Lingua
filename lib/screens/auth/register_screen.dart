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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

    _passwordController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double strength = 0.0;
    if (password.length >= 6) strength += 0.33;
    if (password.length >= 8) strength += 0.20;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.24;
    if (RegExp(r'[0-9]').hasMatch(password) || RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.23;
    return strength.clamp(0.0, 1.0);
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.33) return AppColors.semanticRed;
    if (strength <= 0.66) return AppColors.gold500;
    return AppColors.semanticGreen;
  }

  String _getStrengthText(double strength) {
    if (strength == 0.0) return '';
    if (strength <= 0.33) return 'Weak Password 🔴';
    if (strength <= 0.66) return 'Medium Strength 🟡';
    return 'Strong Password 🟢';
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref.read(authStateProvider.notifier).register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (success && mounted) {
        context.go('/home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration failed. Email may already be in use.'),
            backgroundColor: AppColors.semanticRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final passwordStrength = _calculatePasswordStrength(_passwordController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
        elevation: 0,
      ),
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
                    const SizedBox(height: AppSpacing.sm),
                    const LumadLogoEmblem(size: 56, borderRadius: 14),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Join Lumad Lingua',
                      style: AppTypography.h1ExtraBold.copyWith(color: AppColors.textColor(context), fontSize: 26),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start your journey in preserving Mansaka language & heritage',
                      style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Card Form Container
                    BrandCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Display Name', style: AppTypography.labelBold.copyWith(color: Colors.white)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _nameController,
                            validator: AppValidators.validateName,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.forest900),
                            decoration: InputDecoration(
                              hintText: 'Enter your display name',
                              hintStyle: AppTypography.body.copyWith(color: AppColors.creamText3),
                              prefixIcon: const Icon(Icons.person_outline, color: AppColors.forest500),
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
                          Text('Email Address', style: AppTypography.labelBold.copyWith(color: Colors.white)),
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
                          Text('Password', style: AppTypography.labelBold.copyWith(color: Colors.white)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _passwordController,
                            validator: AppValidators.validatePassword,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.forest900),
                            decoration: InputDecoration(
                              hintText: 'Create a password',
                              hintStyle: AppTypography.body.copyWith(color: AppColors.creamText3),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.forest500),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.forest500),
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
                          if (_passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: passwordStrength,
                                      backgroundColor: AppColors.forest700,
                                      color: _getStrengthColor(passwordStrength),
                                      minHeight: 6,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getStrengthText(passwordStrength),
                                  style: AppTypography.caption.copyWith(
                                    color: _getStrengthColor(passwordStrength),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          Text('Confirm Password', style: AppTypography.labelBold.copyWith(color: Colors.white)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _confirmPasswordController,
                            validator: (val) => AppValidators.validateConfirmPassword(val, _passwordController.text),
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            onFieldSubmitted: (_) => _handleRegister(),
                            style: AppTypography.bodyLarge.copyWith(color: AppColors.forest900),
                            decoration: InputDecoration(
                              hintText: 'Re-enter your password',
                              hintStyle: AppTypography.body.copyWith(color: AppColors.creamText3),
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.forest500),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.forest500),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
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
                          const SizedBox(height: AppSpacing.lg),
                          BrandButton(
                            text: 'Create Account',
                            type: BrandButtonType.gold,
                            isLoading: authState.isLoading,
                            onPressed: _handleRegister,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ', style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context))),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Sign In',
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
