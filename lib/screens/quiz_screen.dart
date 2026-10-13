import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/quiz_session_provider.dart';
import '../providers/user_stats_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive_helper.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/primary_button.dart';
import '../widgets/responsive_container.dart';

class QuizScreen extends ConsumerWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizDetailProvider(quizId));

    return quizAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: EmptyStateWidget(
            icon: Icons.error_outline_rounded,
            title: 'Quiz Not Found',
            description: 'Could not load quiz details. Please try another quiz.',
            actionText: 'Back to Home',
            onAction: () => context.go('/home'),
          ),
        ),
      ),
      data: (quiz) {
        if (quiz == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: EmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'Quiz Not Found',
                description: 'The requested quiz does not exist.',
                actionText: 'Back to Home',
                onAction: () => context.go('/home'),
              ),
            ),
          );
        }
        return _QuizSessionView(quiz: quiz);
      },
    );
  }
}

class _QuizSessionView extends ConsumerStatefulWidget {
  final QuizModel quiz;

  const _QuizSessionView({required this.quiz});

  @override
  ConsumerState<_QuizSessionView> createState() => _QuizSessionViewState();
}

class _QuizSessionViewState extends ConsumerState<_QuizSessionView> {
  bool _submittedDialogShown = false;

  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Leave Quiz?', style: AppTextStyles.h3()),
          content: Text(
            'Your progress will not be saved if you exit now. Are you sure you want to leave?',
            style: AppTextStyles.bodyMedium(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text('Stay', style: AppTextStyles.bodyMedium(color: AppColors.primary)),
            ),
            PrimaryButton(
              text: 'Exit',
              width: 90,
              height: 40,
              variant: ButtonVariant.danger,
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                context.go('/home');
              },
            ),
          ],
        );
      },
    );
  }

  void _showSubmitConfirmDialog(QuizSessionState sessionState) {
    final answered = sessionState.answeredCount;
    final total = sessionState.totalQuestions;
    final unanswered = total - answered;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Submit Quiz', style: AppTextStyles.h3()),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you ready to submit your answers?',
                style: AppTextStyles.bodyMedium(),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('$answered', style: AppTextStyles.h3(color: AppColors.success)),
                        Text('Answered', style: AppTextStyles.caption()),
                      ],
                    ),
                    Container(height: 28, width: 1, color: AppColors.border),
                    Column(
                      children: [
                        Text('$unanswered', style: AppTextStyles.h3(color: AppColors.warning)),
                        Text('Unanswered', style: AppTextStyles.caption()),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text('Review More', style: AppTextStyles.bodyMedium(color: AppColors.textMuted)),
            ),
            PrimaryButton(
              text: 'Submit Now',
              width: 130,
              height: 40,
              isLoading: sessionState.isSubmitting,
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await _performSubmit();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performSubmit() async {
    final sessionNotifier = ref.read(quizSessionProvider(widget.quiz).notifier);
    final authUser = ref.read(authStateProvider).value;
    final uid = authUser?.uid ?? '';

    final attempt = await sessionNotifier.submitQuiz(uid);

    if (!mounted) return;
    ref.read(currentAttemptResultProvider.notifier).state = attempt;
    context.go('/result');
  }

  void _showQuestionPalette(QuizSessionState sessionState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomCtx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Questions Overview', style: AppTextStyles.h3()),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(bottomCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(sessionState.quiz.questions.length, (idx) {
                  final isCurrent = sessionState.currentQuestionIndex == idx;
                  final isAnswered = sessionState.selectedAnswers[idx] != null;

                  Color bg = AppColors.surface;
                  Color text = AppColors.textPrimary;
                  BorderSide side = const BorderSide(color: AppColors.border);

                  if (isCurrent) {
                    bg = AppColors.primary;
                    text = Colors.white;
                    side = const BorderSide(color: AppColors.primary);
                  } else if (isAnswered) {
                    bg = AppColors.successLight;
                    text = AppColors.success;
                    side = const BorderSide(color: AppColors.success);
                  }

                  return InkWell(
                    onTap: () {
                      ref
                          .read(quizSessionProvider(widget.quiz).notifier)
                          .jumpToQuestion(idx);
                      Navigator.of(bottomCtx).pop();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.fromBorderSide(side),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: AppTextStyles.label(color: text),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(quizSessionProvider(widget.quiz));
    final sessionNotifier = ref.read(quizSessionProvider(widget.quiz).notifier);

    // Auto-submit if time ran out
    if (sessionState.isTimeUp && !_submittedDialogShown) {
      _submittedDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Time's up! Automatically submitting your answers..."),
            backgroundColor: AppColors.warning,
          ),
        );
        _performSubmit();
      });
    }

    final currentIndex = sessionState.currentQuestionIndex;
    final currentQuestion = widget.quiz.questions[currentIndex];
    final totalQuestions = widget.quiz.questions.length;
    final selectedOption = sessionState.selectedAnswers[currentIndex];

    final mins = sessionState.remainingSeconds ~/ 60;
    final secs = sessionState.remainingSeconds % 60;
    final timerString = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    final isTimerWarning = sessionState.remainingSeconds <= 60;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmDialog();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _showExitConfirmDialog,
          ),
          title: Text(
            widget.quiz.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.h4(),
          ),
          actions: [
            // Timer Badge
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isTimerWarning ? AppColors.errorLight : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isTimerWarning ? AppColors.error : AppColors.primaryLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: isTimerWarning ? AppColors.error : AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timerString,
                    style: AppTextStyles.label(
                      color: isTimerWarning ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.grid_view_rounded),
              tooltip: 'Question Grid',
              onPressed: () => _showQuestionPalette(sessionState),
            ),
          ],
        ),
        body: Column(
          children: [
            // Linear Progress Indicator
            LinearProgressIndicator(
              value: (currentIndex + 1) / totalQuestions,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(ResponsiveHelper.getContentPadding(context)),
                child: ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question Count & Progress Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Question ${currentIndex + 1} of $totalQuestions',
                              style: AppTextStyles.caption(color: AppColors.primary),
                            ),
                          ),
                          Text(
                            '${sessionState.answeredCount}/$totalQuestions Answered',
                            style: AppTextStyles.caption(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Question Statement Card
                      AppCard(
                        padding: const EdgeInsets.all(22),
                        child: Text(
                          currentQuestion.questionText,
                          style: AppTextStyles.bodyLarge(color: AppColors.textPrimary).copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Multiple Choice Option Cards
                      Text('Select your answer:', style: AppTextStyles.label(color: AppColors.textMuted)),
                      const SizedBox(height: 12),

                      ...List.generate(currentQuestion.options.length, (optIndex) {
                        final isSelected = selectedOption == optIndex;
                        final optionLetter = String.fromCharCode(65 + optIndex); // A, B, C, D

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            onTap: () => sessionNotifier.selectOption(currentIndex, optIndex),
                            backgroundColor: isSelected ? AppColors.primarySoft : AppColors.surface,
                            borderSide: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.surface,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.border,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      optionLetter,
                                      style: AppTextStyles.label(
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    currentQuestion.options[optIndex],
                                    style: AppTextStyles.bodyMedium(
                                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                                    ).copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: ResponsiveContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button
                    OutlinedButton.icon(
                      onPressed: sessionState.isFirstQuestion
                          ? null
                          : () => sessionNotifier.previousQuestion(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Previous'),
                    ),

                    // Next or Submit Button
                    if (!sessionState.isLastQuestion)
                      PrimaryButton(
                        text: 'Next',
                        width: 120,
                        height: 44,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => sessionNotifier.nextQuestion(),
                      )
                    else
                      PrimaryButton(
                        text: 'Submit Quiz',
                        width: 140,
                        height: 44,
                        variant: ButtonVariant.secondary,
                        icon: Icons.send_rounded,
                        isLoading: sessionState.isSubmitting,
                        onPressed: () => _showSubmitConfirmDialog(sessionState),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
