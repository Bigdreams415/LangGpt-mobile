import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../progress/data/datasources/progress_remote_datasource.dart';
import '../../progress/data/models/progress_model.dart';
import '../presentation/providers/home_provider.dart';
import '../data/models/home_dashboard_model.dart';
import '../widgets/streak_badge.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/continue_lesson_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/lesson_item.dart';
import '../widgets/leaderboard_entry.dart';
import '../widgets/shimmer_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _progressDataSource = ProgressRemoteDataSource.instance;
  ProgressResponseModel? _progress;

  @override
  void initState() {
    super.initState();
    // Load home data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).loadDashboard();
      _loadProgress();
    });
  }

  Future<void> _loadProgress() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final language = user.selectedLanguage ?? 'Igbo';
    try {
      final progress = await _progressDataSource.getProgress(
        userId: user.id,
        language: language,
      );
      if (!mounted) return;
      setState(() => _progress = progress);
    } catch (_) {
      if (!mounted) return;
      setState(() => _progress = null);
    }
  }

  bool _isTopicUnlocked({required String topicId, required HomeState state}) {
    final progress = _progress;

    if (progress == null) {
      final currentFromDashboard = state.dashboard?.continueLearning?.topic;
      if (currentFromDashboard != null && currentFromDashboard.isNotEmpty) {
        return topicId == currentFromDashboard;
      }
      return true;
    }

    final completedUnits = progress.completedUnits.toSet();
    if (completedUnits.contains(topicId)) return true;
    if (progress.currentUnit.isNotEmpty) return progress.currentUnit == topicId;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(homeProvider.notifier).refreshDashboard(),
              _loadProgress(),
            ]);
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Top Bar with real user data 
                _buildTopBar(homeState),
                const SizedBox(height: 24),

                // Daily Goal Progress 
                _buildDailyGoalCard(homeState),
                const SizedBox(height: 24),

                // Continue Lesson 
                if (homeState.status == HomeStatus.loaded)
                  _buildContinueLearningSection(homeState.dashboard),
                const SizedBox(height: 24),

                // Stats Row 
                _buildStatsRow(homeState),
                const SizedBox(height: 24),

                // Today's Topics 
                _buildTodayLessonsSection(homeState),
                const SizedBox(height: 24),

                // Leaderboard preview 
                _buildLeaderboardSection(homeState),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Top Bar Builder 
  Widget _buildTopBar(HomeState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Show name from real data or placeholder while loading
              if (state.status == HomeStatus.loaded && state.dashboard != null)
                Text(
                  state.dashboard!.userName,
                  style: AppTextStyles.displaySmall,
                )
              else if (state.status == HomeStatus.loading)
                const ShimmerBox(width: 120, height: 24, borderRadius: 8)
              else
                const Text('Learner', style: AppTextStyles.displaySmall),
            ],
          ),
        ),
        // Streak badge with real data
        if (state.status == HomeStatus.loaded && state.dashboard != null)
          StreakBadge(streak: state.dashboard!.streak)
        else if (state.status == HomeStatus.loading)
          const ShimmerBox(width: 70, height: 40, borderRadius: 12)
        else
          const StreakBadge(streak: 0),
        const SizedBox(width: 10),
        // Avatar with user initials
        _buildAvatar(state),
      ],
    );
  }

  Widget _buildAvatar(HomeState state) {
    String initials = '?';
    if (state.status == HomeStatus.loaded && state.dashboard != null) {
      final name = state.dashboard!.userName;
      initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
      // If there's a last name, add it
      if (name.contains(' ')) {
        final parts = name.split(' ');
        initials = parts[0][0].toUpperCase() +
            (parts.length > 1 ? parts[1][0].toUpperCase() : '');
      }
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: state.status == HomeStatus.loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Ụtụtụ ọma 👋';
    if (hour < 17) return 'Ehihie ọma ☀️';
    return 'Mgbede ọma 🌙';
  }

  // Daily Goal Card Builder 
  Widget _buildDailyGoalCard(HomeState state) {
    if (state.status == HomeStatus.loading) {
      return const DailyGoalShimmer();
    }

    if (state.status == HomeStatus.error) {
      return _buildErrorCard(
        message: state.errorMessage ?? 'Failed to load daily goal',
        onRetry: () => ref.read(homeProvider.notifier).refreshDashboard(),
      );
    }

    final dashboard = state.dashboard;
    if (dashboard == null) return const SizedBox.shrink();
    return DailyGoalCard(goal: dashboard.dailyGoal);
  }

  // Continue Learning Section 
  Widget _buildContinueLearningSection(HomeDashboardModel? dashboard) {
    if (dashboard?.continueLearning == null) {
      return const SizedBox.shrink();
    }

    final continueLesson = dashboard!.continueLearning!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Continue learning', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        ContinueLessonCard(lesson: continueLesson),
      ],
    );
  }

  // Stats Row Builder
  Widget _buildStatsRow(HomeState state) {
    if (state.status == HomeStatus.loading) {
      return Row(
        children: [
          const Expanded(child: StatCardShimmer()),
          const SizedBox(width: 12),
          const Expanded(child: StatCardShimmer()),
          const SizedBox(width: 12),
          const Expanded(child: StatCardShimmer()),
        ],
      );
    }

    if (state.status == HomeStatus.error || state.dashboard == null) {
      return const SizedBox.shrink();
    }

    final stats = state.dashboard!.stats;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: stats.lessonsCompleted.toString(),
            label: 'Lessons\ncompleted',
            icon: '📚',
            color: AppColors.primarySurface,
            textColor: AppColors.primaryDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: '${stats.quizAccuracy.toInt()}%',
            label: 'Quiz\naccuracy',
            icon: '🎯',
            color: AppColors.secondarySurface,
            textColor: AppColors.secondaryDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            value: stats.totalXp.toString(),
            label: 'XP\nearned',
            icon: '⚡',
            color: AppColors.accentYellowSurface,
            textColor: const Color(0xFFB8860B),
          ),
        ),
      ],
    );
  }

  // Today's Lessons Section 
  Widget _buildTodayLessonsSection(HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Today's lessons", style: AppTextStyles.headlineMedium),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.allLessons);
              },
              child: Text(
                'See all',
                style:
                    AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.status == HomeStatus.loading)
          ...List.generate(3, (_) => const LessonItemShimmer())
        else if (state.status == HomeStatus.error)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    state.errorMessage ?? 'Failed to load lessons',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        ref.read(homeProvider.notifier).refreshDashboard(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (state.dashboard?.todayLessons.isEmpty ?? true)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('No lessons available'),
            ),
          )
        else
          ...state.dashboard!.todayLessons.map(
            (lesson) {
              final isUnlocked =
                  _isTopicUnlocked(topicId: lesson.id, state: state);
              return GestureDetector(
                onTap: () {
                  if (!isUnlocked) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Pass the current quiz (80%+) to unlock this topic.'),
                      ),
                    );
                    return;
                  }

                  Navigator.pushNamed(
                    context,
                    AppRoutes.lessonDetail,
                    arguments: {
                      'topicId': lesson.id,
                      'language':
                          state.dashboard?.continueLearning?.language ?? 'Igbo',
                      'title': lesson.title,
                    },
                  );
                },
                child: LessonItem(
                  lesson: lesson,
                  isLocked: !isUnlocked,
                ),
              );
            },
          ),
      ],
    );
  }

  // Leaderboard Section 
  Widget _buildLeaderboardSection(HomeState state) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Top learners this week',
                  style: AppTextStyles.headlineSmall),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to full leaderboard
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'See all',
                  style: AppTextStyles.labelLarge
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.status == HomeStatus.loading)
            ...List.generate(3, (_) => const LeaderboardShimmer())
          else if (state.status == HomeStatus.error || state.dashboard == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Leaderboard unavailable'),
              ),
            )
          else if (state.dashboard!.leaderboard.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No rankings yet'),
              ),
            )
          else
            ...state.dashboard!.leaderboard.map(
              (entry) => LeaderboardEntry(entry: entry),
            ),
        ],
      ),
    );
  }

  // Error Card
  Widget _buildErrorCard(
      {required String message, required VoidCallback onRetry}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
