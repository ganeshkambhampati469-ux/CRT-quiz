import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_stats_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';
import '../widgets/app_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_container.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attempt = ref.watch(currentAttemptResultProvider);

    if (attempt == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Quiz Results')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('No recent attempt to display.', style: AppTextStyles.h3()),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'Go to Home',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      );
    }

    final percentage = attempt.percentage;
    final isPassed = percentage >= 70;
    final timeMins = attempt.timeTakenSeconds ~/ 60;
    final timeSecs = attempt.timeTakenSeconds % 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Quiz Result'),
          leading: IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.getContentPadding(context)),
          child: ResponsiveContainer(
            maxWidth: AppConstants.maxFormWidth + 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Score Hero Card
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      // Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPassed ? AppColors.successLight : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPassed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                              size: 16,
                              color: isPassed ? AppColors.success : AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              attempt.performanceBadge,
                              style: AppTextStyles.label(
                                color: isPassed ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Circular Score Ring
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: percentage / 100,
                                strokeWidth: 10,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isPassed ? AppColors.success : AppColors.primary,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${percentage.toStringAsFixed(0)}%',
                                  style: AppTextStyles.h1(color: AppColors.textPrimary).copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${attempt.correctCount}/${attempt.totalQuestions}',
                                  style: AppTextStyles.caption(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        attempt.quizTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h3(),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isPassed
                            ? 'Great job! You showed strong aptitude in this topic.'
                            : 'Keep practicing! Review your errors to build speed and accuracy.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Metrics Breakdown Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildResultMetric(
                        'Correct',
                        '${attempt.correctCount}',
                        Icons.check_circle_outline_rounded,
                        AppColors.success,
                        AppColors.successLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildResultMetric(
                        'Incorrect',
                        '${attempt.incorrectCount}',
                        Icons.cancel_outlined,
                        AppColors.error,
                        AppColors.errorLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildResultMetric(
                        'Skipped',
                        '${attempt.skippedCount}',
                        Icons.help_outline_rounded,
                        AppColors.textMuted,
                        AppColors.borderSubtle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildResultMetric(
                        'Time',
                        '${timeMins}m ${timeSecs}s',
                        Icons.timer_outlined,
                        AppColors.primary,
                        AppColors.primarySoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // CTAs
                PrimaryButton(
                  text: 'Review Answers',
                  icon: Icons.rate_review_outlined,
                  onPressed: () => context.go('/review'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to Home'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultMetric(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h4(color: AppColors.textPrimary)),
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
