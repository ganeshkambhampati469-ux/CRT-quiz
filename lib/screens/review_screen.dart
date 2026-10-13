import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/attempt_model.dart';
import '../providers/user_stats_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive_helper.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_container.dart';

enum ReviewFilter { all, correct, incorrect, skipped }

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  ReviewFilter _filter = ReviewFilter.all;

  @override
  Widget build(BuildContext context) {
    final attempt = ref.watch(currentAttemptResultProvider);

    if (attempt == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Review Answers')),
        body: Center(
          child: EmptyStateWidget(
            icon: Icons.history_rounded,
            title: 'No Review Available',
            description: 'Please complete a quiz first to review questions and explanations.',
            actionText: 'Go to Home',
            onAction: () => context.go('/home'),
          ),
        ),
      );
    }

    final filteredAnswers = attempt.answers.where((a) {
      switch (_filter) {
        case ReviewFilter.all:
          return true;
        case ReviewFilter.correct:
          return a.isCorrect;
        case ReviewFilter.incorrect:
          return !a.isCorrect && !a.isSkipped;
        case ReviewFilter.skipped:
          return a.isSkipped;
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Review: ${attempt.quizTitle}', style: AppTextStyles.h4()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/result'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Home',
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ResponsiveHelper.getContentPadding(context)),
        child: ResponsiveContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Banner
              AppCard(
                padding: const EdgeInsets.all(18),
                backgroundColor: AppColors.primarySoft,
                borderSide: const BorderSide(color: AppColors.primaryLight),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryStat('Score', '${attempt.score.toStringAsFixed(0)}%'),
                    _buildSummaryStat('Correct', '${attempt.correctCount}'),
                    _buildSummaryStat('Incorrect', '${attempt.incorrectCount}'),
                    _buildSummaryStat('Skipped', '${attempt.skippedCount}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All (${attempt.totalQuestions})', ReviewFilter.all),
                    const SizedBox(width: 8),
                    _buildFilterChip('Correct (${attempt.correctCount})', ReviewFilter.correct),
                    const SizedBox(width: 8),
                    _buildFilterChip('Incorrect (${attempt.incorrectCount})', ReviewFilter.incorrect),
                    const SizedBox(width: 8),
                    _buildFilterChip('Skipped (${attempt.skippedCount})', ReviewFilter.skipped),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Question List
              if (filteredAnswers.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      'No questions in this filter category.',
                      style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredAnswers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final record = filteredAnswers[index];
                    final originalIndex = attempt.answers.indexOf(record) + 1;
                    return _buildQuestionReviewCard(record, originalIndex);
                  },
                ),
              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Finish Review & Go Home',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.h3(color: AppColors.primaryDark)),
        Text(label, style: AppTextStyles.caption(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildFilterChip(String label, ReviewFilter filter) {
    final isSelected = _filter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: AppTextStyles.label(
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _filter = filter);
        }
      },
    );
  }

  Widget _buildQuestionReviewCard(AnswerRecord record, int questionNumber) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (record.isSkipped) {
      statusColor = AppColors.textMuted;
      statusText = 'Skipped';
      statusIcon = Icons.remove_circle_outline_rounded;
    } else if (record.isCorrect) {
      statusColor = AppColors.success;
      statusText = 'Correct';
      statusIcon = Icons.check_circle_outline_rounded;
    } else {
      statusColor = AppColors.error;
      statusText = 'Incorrect';
      statusIcon = Icons.cancel_outlined;
    }

    final selectedLetter = record.selectedIndex != null
        ? String.fromCharCode(65 + record.selectedIndex!)
        : 'None';
    final correctLetter = String.fromCharCode(65 + record.correctIndex);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Q number + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question $questionNumber', style: AppTextStyles.label(color: AppColors.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: AppTextStyles.caption(color: statusColor).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Text
          Text(
            record.questionText,
            style: AppTextStyles.bodyLarge().copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Answer Comparison Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Answer:', style: AppTextStyles.caption(color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        'Option $selectedLetter',
                        style: AppTextStyles.label(
                          color: record.isCorrect ? AppColors.success : (record.isSkipped ? AppColors.textMuted : AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 32, width: 1, color: AppColors.border),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Correct Answer:', style: AppTextStyles.caption(color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        'Option $correctLetter',
                        style: AppTextStyles.label(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Explanation Box (if available)
          if (record.explanation != null && record.explanation!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondaryLight.withAlpha(80)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, size: 20, color: AppColors.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explanation:', style: AppTextStyles.caption(color: AppColors.secondary).copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(
                          record.explanation!,
                          style: AppTextStyles.bodySmall(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
