import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/responsive_container.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final filteredQuizzes = ref.watch(filteredQuizzesProvider);
    final quizzesAsync = ref.watch(quizzesStreamProvider);
    final selectedTopic = ref.watch(selectedTopicFilterProvider);

    final user = userProfileAsync.value;
    final userName = user?.name.isNotEmpty == true
        ? user!.name
        : (ref.watch(authStateProvider).value?.displayName ?? 'Aspirant');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(AppConstants.appName, style: AppTextStyles.h3()),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 26),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            context.go('/profile');
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
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(quizzesStreamProvider);
          ref.invalidate(userProfileProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ResponsiveContainer(
            padding: EdgeInsets.all(ResponsiveHelper.getContentPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Personalized Greeting Banner
                _buildHeroGreeting(context, userName, userProfileAsync.isLoading),
                const SizedBox(height: 24),

                // 2. Dashboard Summary Cards
                _buildDashboardMetrics(context, user),
                const SizedBox(height: 32),

                // 3. Section Header & Search Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Available Quizzes', style: AppTextStyles.h2()),
                    Text(
                      '${filteredQuizzes.length} Quizzes',
                      style: AppTextStyles.bodyMedium(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Topic Filter Chips
                _buildTopicFilterChips(ref, selectedTopic),
                const SizedBox(height: 20),

                // 4. Quizzes Grid / List
                quizzesAsync.when(
                  loading: () => _buildLoadingSkeleton(context),
                  error: (err, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Failed to load quizzes: $err'),
                    ),
                  ),
                  data: (_) {
                    if (filteredQuizzes.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: 'No Quizzes Found',
                        description: 'Try choosing another topic filter or resetting search.',
                        actionText: 'View All Quizzes',
                        onAction: () {
                          ref.read(selectedTopicFilterProvider.notifier).state = 'All Topics';
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      );
                    }

                    final colCount = ResponsiveHelper.getGridColumnCount(context);
                    if (colCount == 1) {
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredQuizzes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _buildQuizCard(context, filteredQuizzes[index]);
                        },
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: colCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: filteredQuizzes.length,
                      itemBuilder: (context, index) {
                        return _buildQuizCard(context, filteredQuizzes[index]);
                      },
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroGreeting(BuildContext context, String name, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: Colors.amberAccent),
                    const SizedBox(width: 4),
                    Text(
                      'Placement Prep Mode',
                      style: AppTextStyles.caption(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isLoading ? 'Welcome Back!' : 'Welcome back, $name! 👋',
            style: AppTextStyles.h2(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Ready to test your aptitude skills and elevate your placement readiness?',
            style: AppTextStyles.bodyMedium(
              color: Colors.white.withAlpha(220),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardMetrics(BuildContext context, dynamic user) {
    final totalTaken = user?.totalQuizzesTaken ?? 0;
    final avgScore = user?.averageScore ?? 0.0;
    final bestScore = user?.bestScore ?? 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            title: 'Quizzes Taken',
            value: '$totalTaken',
            icon: Icons.checklist_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.primarySoft,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            title: 'Average Score',
            value: '${avgScore.toStringAsFixed(0)}%',
            icon: Icons.pie_chart_outline_rounded,
            iconColor: AppColors.secondary,
            iconBg: AppColors.secondarySoft,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            title: 'Best Score',
            value: '${bestScore.toStringAsFixed(0)}%',
            icon: Icons.emoji_events_outlined,
            iconColor: Colors.amber.shade700,
            iconBg: Colors.amber.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h2(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicFilterChips(WidgetRef ref, String selectedTopic) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AppConstants.quizTopics.map((topic) {
          final isSelected = selectedTopic == topic;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(topic),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: AppTextStyles.label(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedTopicFilterProvider.notifier).state = topic;
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context, QuizModel quiz) {
    Color difficultyColor;
    switch (quiz.difficulty.toLowerCase()) {
      case 'easy':
        difficultyColor = AppColors.difficultyEasy;
        break;
      case 'hard':
        difficultyColor = AppColors.difficultyHard;
        break;
      case 'medium':
      default:
        difficultyColor = AppColors.difficultyMedium;
        break;
    }

    return AppCard(
      onTap: () => context.go('/quiz/${quiz.id}'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Topic tag & Difficulty badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quiz.topic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: difficultyColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: difficultyColor.withAlpha(80)),
                    ),
                    child: Text(
                      quiz.difficulty,
                      style: AppTextStyles.caption(color: difficultyColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Quiz Title
              Text(
                quiz.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h4(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Metrics & CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.questionCount} Qs',
                    style: AppTextStyles.bodySmall(),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.timer_outlined, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.timeLimitMinutes} mins',
                    style: AppTextStyles.bodySmall(),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Start',
                      style: AppTextStyles.caption(color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ShimmerSkeleton(
            height: 140,
            borderRadius: 16,
          ),
        ),
      ),
    );
  }
}
