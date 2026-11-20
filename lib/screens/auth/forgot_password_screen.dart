import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/brand_button.dart';
import '../../widgets/common/brand_card.dart';
import '../../widgets/common/lumad_background.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final email = _emailController.text.trim();
      final success = await ref.read(authStateProvider.notifier).sendPasswordResetEmail(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSent = success;
        });

        if (!success) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to send reset email. Please verify if the email is registered.'),
              backgroundColor: AppColors.semanticRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password', style: AppTypography.h2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest700,
        elevation: 0,
      ),
      body: LumadBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Forgot your password?',
                    style: AppTypography.h1ExtraBold.copyWith(color: AppColors.textColor(context), fontSize: 26),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Enter your account email address below and we will send password reset instructions.',
                    style: AppTypography.body.copyWith(color: AppColors.subtitleColor(context)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BrandCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSent)
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.semanticGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.card),
                              border: Border.all(color: AppColors.semanticGreen),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.semanticGreen),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Password reset instructions sent to your email! 🎉',
                                    style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          Text('Email Address', style: AppTypography.labelBold.copyWith(color: Colors.white)),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _emailController,
                            validator: AppValidators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
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
                          const SizedBox(height: AppSpacing.xl),
                          BrandButton(
                            text: 'Send Reset Instructions',
                            type: BrandButtonType.gold,
                            isLoading: _isLoading,
                            onPressed: _submit,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: Text('Back to Login', style: AppTypography.labelBold.copyWith(color: AppColors.gold500)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
