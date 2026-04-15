import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../progress/data/datasources/progress_remote_datasource.dart';
import '../../progress/data/models/progress_model.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../presentation/providers/lessons_provider.dart';
import '../widgets/lesson_topic_card.dart';
import '../widgets/lesson_shimmer.dart';

class AllLessonsScreen extends ConsumerStatefulWidget {
  const AllLessonsScreen({super.key});

  @override
  ConsumerState<AllLessonsScreen> createState() => _AllLessonsScreenState();
}

class _AllLessonsScreenState extends ConsumerState<AllLessonsScreen> {
  final _progressDataSource = ProgressRemoteDataSource.instance;
  ProgressResponseModel? _progress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLessons();
      _loadProgress();
    });
  }

  void _loadLessons() {
    final user = ref.read(currentUserProvider);
    final language = user?.selectedLanguage ?? 'Igbo';
    final level = user?.level;

    ref.read(lessonsListProvider.notifier).loadLessonsList(
          language: language,
          level: level,
        );
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

  bool _isTopicUnlocked({
    required String topicId,
    required List<dynamic> allTopics,
    required int index,
  }) {
    final progress = _progress;
    if (progress == null) {
      return index == 0;
    }

    final completedUnits = progress.completedUnits.toSet();
    if (completedUnits.contains(topicId)) return true;

    if (progress.currentUnit.isNotEmpty) {
      return progress.currentUnit == topicId;
    }

    final firstUncompleted = allTopics
        .cast<dynamic>()
        .firstWhere(
          (topic) => !completedUnits.contains(topic.id as String),
          orElse: () => allTopics.first,
        )
        .id as String;
    return firstUncompleted == topicId;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final lessonsState = ref.watch(lessonsListProvider);
    final language = user?.selectedLanguage ?? 'Igbo';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$language Lessons',
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(lessonsListProvider.notifier).refreshLessonsList(
                  language: language,
                  level: user?.level,
                ),
            _loadProgress(),
          ]);
        },
        color: AppColors.primary,
        child: _buildContent(lessonsState),
      ),
    );
  }

  Widget _buildContent(LessonsListState state) {
    if (state.status == LessonsListStatus.loading) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 6,
        itemBuilder: (context, index) => const LessonTopicShimmer(),
      );
    }

    if (state.status == LessonsListStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Failed to load lessons',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadLessons,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.lessonsList == null || state.lessonsList!.topics.isEmpty) {
      return const Center(
        child: Text('No lessons available'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: state.lessonsList!.topics.length,
      itemBuilder: (context, index) {
        final topic = state.lessonsList!.topics[index];
        final unlocked = _isTopicUnlocked(
          topicId: topic.id,
          allTopics: state.lessonsList!.topics,
          index: index,
        );

        return LessonTopicCard(
          topic: topic,
          language: state.lessonsList!.language,
          isLocked: !unlocked,
          onTap: () {
            if (!unlocked) {
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
              '/lesson-detail',
              arguments: {
                'topicId': topic.id,
                'language': state.lessonsList!.language,
                'title': topic.title,
              },
            );
          },
        );
      },
    );
  }
}
