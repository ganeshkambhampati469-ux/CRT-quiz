import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/user_stats_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/error_helpers.dart';
import '../utils/responsive_helper.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_container.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isEditingName = false;
  bool _isSavingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Log Out', style: AppTextStyles.h3()),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: AppTextStyles.bodyMedium(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: AppTextStyles.bodyMedium(color: AppColors.textMuted)),
            ),
            PrimaryButton(
              text: 'Log Out',
              width: 110,
              height: 40,
              variant: ButtonVariant.danger,
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await ref.read(authControllerProvider.notifier).signOut();
                if (mounted) {
                  context.go('/login');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Change Password', style: AppTextStyles.h3()),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        label: 'Current Password',
                        hint: '••••••••',
                        controller: currentPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Enter current password' : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'New Password',
                        hint: 'At least 6 characters',
                        controller: newPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_reset_rounded,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter new password';
                          if (val.length < 6) return 'Minimum 6 characters required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Confirm New Password',
                        hint: 'Re-enter new password',
                        controller: confirmPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_reset_rounded,
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Confirm new password';
                          if (val != newPasswordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
                  child: Text('Cancel', style: AppTextStyles.bodyMedium(color: AppColors.textMuted)),
                ),
                PrimaryButton(
                  text: 'Update',
                  width: 110,
                  height: 40,
                  isLoading: isSubmitting,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(dialogCtx);

                    setDialogState(() => isSubmitting = true);
                    final success = await ref
                        .read(authControllerProvider.notifier)
                        .changePassword(
                          currentPassword: currentPasswordController.text.trim(),
                          newPassword: newPasswordController.text.trim(),
                        );

                    if (!mounted) return;
                    setDialogState(() => isSubmitting = false);
                    navigator.pop();

                    if (success) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Password updated successfully!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      final errorState = ref.read(authControllerProvider);
                      final errorMsg = errorState.hasError
                          ? ErrorHelpers.getAuthErrorMessage(errorState.error)
                          : 'Failed to update password.';

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

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.substring(0, trimmed.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final userAttemptsAsync = ref.watch(userAttemptsProvider);
    final user = userProfileAsync.value;
    final authUser = ref.watch(authStateProvider).value;

    final displayName = user?.name.isNotEmpty == true
        ? user!.name
        : (authUser?.displayName ?? 'Student');
    final email = user?.email.isNotEmpty == true ? user!.email : (authUser?.email ?? '');

    if (!_isEditingName && _nameController.text.isEmpty) {
      _nameController.text = displayName;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Student Profile', style: AppTextStyles.h3()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/home'),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) {
            context.go('/home');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ResponsiveContainer(
          padding: EdgeInsets.all(ResponsiveHelper.getContentPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Header & Initials Avatar
              AppCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Badge
                        Container(
                          width: 68,
                          height: 68,
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(displayName),
                              style: AppTextStyles.h2(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),
                        // User Name & Email Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!_isEditingName) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.h3(),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20),
                                      color: AppColors.primary,
                                      tooltip: 'Edit Name',
                                      onPressed: () {
                                        setState(() {
                                          _isEditingName = true;
                                          _nameController.text = displayName;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _nameController,
                                        autofocus: true,
                                        style: AppTextStyles.h4(),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: _isSavingName
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.check_rounded, color: AppColors.success),
                                      onPressed: _isSavingName
                                          ? null
                                          : () async {
                                              final newName = _nameController.text.trim();
                                              if (newName.isEmpty) return;
                                              setState(() => _isSavingName = true);
                                              await ref
                                                  .read(authControllerProvider.notifier)
                                                  .updateDisplayName(newName);
                                              if (mounted) {
                                                setState(() {
                                                  _isSavingName = false;
                                                  _isEditingName = false;
                                                });
                                              }
                                            },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                                      onPressed: () {
                                        setState(() {
                                          _isEditingName = false;
                                          _nameController.text = displayName;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                              Text(
                                email,
                                style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 6),
                              if (user != null) ...[
                                Text(
                                  'Member since ${DateFormat.yMMMd().format(user.createdAt)}',
                                  style: AppTextStyles.caption(color: AppColors.textLight),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showChangePasswordDialog,
                            icon: const Icon(Icons.lock_reset_rounded, size: 18),
                            label: const Text('Change Password'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _showLogoutDialog,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('Log Out'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Statistics Card
              Text('Performance Overview', style: AppTextStyles.h3()),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Quizzes Taken',
                      '${user?.totalQuizzesTaken ?? 0}',
                      Icons.assignment_turned_in_outlined,
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      'Average Accuracy',
                      '${(user?.averageScore ?? 0.0).toStringAsFixed(0)}%',
                      Icons.analytics_outlined,
                      AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      'Highest Score',
                      '${(user?.bestScore ?? 0.0).toStringAsFixed(0)}%',
                      Icons.military_tech_outlined,
                      Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 3. Quiz Attempts History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Attempts', style: AppTextStyles.h3()),
                  userAttemptsAsync.maybeWhen(
                    data: (attempts) => Text(
                      '${attempts.length} records',
                      style: AppTextStyles.caption(color: AppColors.textMuted),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              userAttemptsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Failed to load history: $e'),
                ),
                data: (attempts) {
                  if (attempts.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.history_rounded,
                      title: 'No Quiz History Yet',
                      description: 'Take your first CRT practice quiz to track your performance.',
                      actionText: 'Explore Quizzes',
                      onAction: () => context.go('/home'),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: attempts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final attempt = attempts[index];
                      final isPassed = attempt.percentage >= 70;

                      return AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isPassed ? AppColors.successLight : AppColors.errorLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isPassed ? Icons.check_circle_outline : Icons.close_rounded,
                                color: isPassed ? AppColors.success : AppColors.error,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    attempt.quizTitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.label(),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${DateFormat.yMMMd().format(attempt.attemptedAt)} • ${attempt.correctCount}/${attempt.totalQuestions} correct • ${attempt.timeTakenSeconds ~/ 60}m ${attempt.timeTakenSeconds % 60}s',
                                    style: AppTextStyles.caption(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isPassed
                                    ? AppColors.success.withAlpha(20)
                                    : AppColors.error.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${attempt.score.toStringAsFixed(0)}%',
                                style: AppTextStyles.label(
                                  color: isPassed ? AppColors.success : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.h2(color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
