import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkCharcoal,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Join Lumad Lingua',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Start your journey in preserving Mansaka language',
                  style: TextStyle(color: AppColors.darkCharcoal),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _nameController,
                  validator: AppValidators.validateName,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Email Address', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _emailController,
                  validator: AppValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _passwordController,
                  validator: AppValidators.validatePassword,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _confirmPasswordController,
                  validator: (val) => AppValidators.validateConfirmPassword(val, _passwordController.text),
                  obscureText: _obscurePassword,
                  decoration: const InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  text: 'Register',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
