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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authController = ref.read(authControllerProvider.notifier);
    final success = await authController.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.go('/home');
    } else {
      final errorState = ref.read(authControllerProvider);
      final errorMsg = errorState.hasError
          ? ErrorHelpers.getAuthErrorMessage(errorState.error)
          : 'Login failed. Please check your credentials.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text);
    bool isResetting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('Reset Password', style: AppTextStyles.h3()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your registered email address to receive a password reset link.',
                    style: AppTextStyles.bodyMedium(),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email Address',
                    hint: 'student@example.com',
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isResetting ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel', style: AppTextStyles.bodyMedium(color: AppColors.textMuted)),
                ),
                PrimaryButton(
                  text: 'Send Link',
                  width: 120,
                  height: 42,
                  isLoading: isResetting,
                  onPressed: () async {
                    final email = resetEmailController.text.trim();
                    if (email.isEmpty || !email.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid email address.'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }

                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(dialogContext);
                    setDialogState(() => isResetting = true);
                    final success = await ref
                        .read(authControllerProvider.notifier)
                        .sendPasswordReset(email);

                    if (!mounted) return;
                    setDialogState(() => isResetting = false);
                    navigator.pop();

                    if (success) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Password reset link sent to $email.'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      final errorState = ref.read(authControllerProvider);
                      final errorMsg = errorState.hasError
                          ? ErrorHelpers.getAuthErrorMessage(errorState.error)
                          : 'Failed to send reset email.';

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(errorMsg),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Welcome Back',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h2(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Log in to continue your CRT preparation',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 28),

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
                        const SizedBox(height: 18),

                        // Password Field
                        AppTextField(
                          label: 'Password',
                          hint: '••••••••',
                          controller: _passwordController,
                          isPassword: true,
                          prefixIcon: Icons.lock_outline_rounded,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showForgotPasswordDialog,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: AppTextStyles.label(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Button
                        PrimaryButton(
                          text: 'Log In',
                          isLoading: _isLoading,
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 24),

                        // Signup navigation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTextStyles.bodyMedium(),
                            ),
                            GestureDetector(
                              onTap: () => context.go('/signup'),
                              child: Text(
                                'Sign Up',
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
