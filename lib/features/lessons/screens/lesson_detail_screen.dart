import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../presentation/providers/lessons_provider.dart';
import 'learning_screen.dart';

class LessonDetailScreen extends ConsumerStatefulWidget {
  final String topicId;
  final String language;
  final String title;

  const LessonDetailScreen({
    super.key,
    required this.topicId,
    required this.language,
    required this.title,
  });

  @override
  ConsumerState<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends ConsumerState<LessonDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(lessonDetailProvider.notifier).loadLessonDetail(
            language: widget.language,
            topicId: widget.topicId,
          );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonDetailProvider);

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
          widget.title,
          style: AppTextStyles.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: _buildContent(lessonState),
    );
  }

  Widget _buildContent(LessonDetailState state) {
    if (state.status == LessonDetailStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == LessonDetailStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                state.errorMessage ?? 'Failed to load lesson',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(lessonDetailProvider.notifier).loadLessonDetail(
                        language: widget.language,
                        topicId: widget.topicId,
                      );
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final lesson = state.lesson;
    if (lesson == null) {
      return const Center(child: Text('Lesson not found'));
    }

    final content = lesson.content;
    final vocabulary = (content['vocabulary'] as List?) ?? const [];
    final phrases = (content['phrases'] as List?) ?? const [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with emoji and level
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    lesson.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondarySurface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      lesson.level.toUpperCase(),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Vocabulary Section
          Text(
            'Vocabulary',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 12),
          ...vocabulary.map((item) {
            final row = item as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text((row['word'] ?? '') as String,
                      style: AppTextStyles.labelLarge),
                  Text((row['translation'] ?? '') as String,
                      style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // Phrases Section
          Text(
            'Useful Phrases',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 12),
          ...phrases.map((item) {
            final row = item as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((row['phrase'] ?? '') as String,
                      style: AppTextStyles.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    (row['translation'] ?? '') as String,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 32),

          // Start Practice Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LearningScreen(
                      language: widget.language,
                      level: lesson.level,
                      unitId: lesson.id,
                      subtopicIndex: 0,
                      unitTitle: lesson.title,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Practice',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
