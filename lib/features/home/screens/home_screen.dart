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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                const SizedBox(height: 16),

                _buildTopBar(homeState),
                const SizedBox(height: 28),

                _buildDailyGoalCard(homeState),
                const SizedBox(height: 28),

                if (homeState.status == HomeStatus.loaded)
                  _buildContinueLearningSection(homeState.dashboard),
                const SizedBox(height: 28),

                _buildStatsRow(homeState),
                const SizedBox(height: 28),

                _buildTodayLessonsSection(homeState),
                const SizedBox(height: 28),

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
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials = _initials(user?.fullName ?? '');
    final language = user?.selectedLanguage;

    String name = 'Learner';
    if (state.status == HomeStatus.loaded && state.dashboard != null) {
      name = state.dashboard!.userName;
    } else if (user?.fullName != null && user!.fullName.isNotEmpty) {
      name = user.fullName.split(' ').first;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              if (state.status == HomeStatus.loading)
                const ShimmerBox(width: 140, height: 28, borderRadius: 8)
              else
                Text(
                  name,
                  style: AppTextStyles.displaySmall.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (language != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Learning $language',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (state.status == HomeStatus.loaded && state.dashboard != null)
          StreakBadge(streak: state.dashboard!.streak)
        else if (state.status == HomeStatus.loading)
          const ShimmerBox(width: 70, height: 32, borderRadius: 100)
        else
          StreakBadge(streak: user?.streakCount ?? 0),
        const SizedBox(width: 10),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
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
        Text(
          'Continue learning',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.lessonDetail,
              arguments: {
                'topicId': continueLesson.topic,
                'language': continueLesson.language,
                'title': continueLesson.title,
              },
            );
          },
          child: ContinueLessonCard(lesson: continueLesson),
        ),
      ],
    );
  }

  // Stats Row Builder
  Widget _buildStatsRow(HomeState state) {
    if (state.status == HomeStatus.loading) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        height: 86,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
        ),
      );
    }

    if (state.status == HomeStatus.error || state.dashboard == null) {
      return const SizedBox.shrink();
    }

    final stats = state.dashboard!.stats;

    return StatsOverviewCard(
      lessonsValue: stats.lessonsCompleted.toString(),
      accuracyValue: '${stats.quizAccuracy.toInt()}%',
      xpValue: stats.totalXp.toString(),
    );
  }

  // Today's Lessons Section 
  Widget _buildTodayLessonsSection(HomeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Today's lessons",
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.allLessons);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See all',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
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
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top learners',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            user?.selectedLanguage != null
                ? '${user!.selectedLanguage} · ranked by XP'
                : 'Ranked by XP',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
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
              (entry) => LeaderboardEntry(
                entry: entry,
                isCurrentUser: user?.fullName != null &&
                    entry.name == user!.fullName,
              ),
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
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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
