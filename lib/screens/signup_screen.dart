import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/error_helpers.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/home');
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.hasError
          ? ErrorHelpers.getAuthErrorMessage(errorState.error)
          : 'Registration failed. Please try again.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxFormWidth),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // App Logo & Header
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h2(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start your preparation journey today',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 28),

                        // Full Name Field
                        AppTextField(
                          label: 'Full Name',
                          hint: 'John Doe',
                          controller: _nameController,
                          prefixIcon: Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        AppTextField(
                          label: 'Email Address',
                          hint: 'student@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                              return 'Please enter a valid email format';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        AppTextField(
                          label: 'Password',
                          hint: 'At least 6 characters',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        AppTextField(
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          controller: _confirmPasswordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_reset_rounded,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignup(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Signup Button
                        PrimaryButton(
                          text: 'Create Account',
                          isLoading: _isLoading,
                          onPressed: _handleSignup,
                        ),
                        const SizedBox(height: 24),

                        // Login navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTextStyles.bodyMedium(),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                'Log In',
                                style: AppTextStyles.label(color: AppColors.primary),
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
        ),
      ),
    );
  }
}
