import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/lesson_model.dart';
import '../presentation/providers/lessons_provider.dart';
import '../widgets/flashcard_widget.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/vocabulary_list.dart';

class LearningScreen extends ConsumerStatefulWidget {
  final String language;
  final String level;
  final String unitId;
  final int subtopicIndex;
  final String unitTitle;

  const LearningScreen({
    super.key,
    required this.language,
    required this.level,
    required this.unitId,
    required this.subtopicIndex,
    required this.unitTitle,
  });

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonResponseProvider.notifier).generateLesson(
            language: widget.language,
            level: widget.level,
            unit: widget.unitId,
            subtopicIndex: widget.subtopicIndex,
          );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    ref.read(lessonResponseProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonResponseProvider);
    final lesson = lessonState.lesson;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => _showExitConfirmation(),
        ),
        title: Column(
          children: [
            Text(
              widget.unitTitle,
              style: AppTextStyles.headlineSmall,
            ),
            if (lesson != null)
              Text(
                lesson.subtopic,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: _buildContent(lessonState),
    );
  }

  Widget _buildContent(LessonResponseState state) {
    if (state.status == LessonResponseStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.status == LessonResponseStatus.error) {
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
                  ref.read(lessonResponseProvider.notifier).generateLesson(
                        language: widget.language,
                        level: widget.level,
                        unit: widget.unitId,
                        subtopicIndex: widget.subtopicIndex,
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
      return const Center(child: Text('No lesson content'));
    }

    return Column(
      children: [
        // Progress Bar
        ProgressIndicatorWidget(
          current: widget.subtopicIndex + 1,
          total: lesson.totalSubtopics,
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: [
              // Page 1: Introduction & Cultural Note
              _buildIntroductionPage(lesson),

              // Page 2: Flashcards
              FlashcardWidget(vocabulary: lesson.vocabulary),

              // Page 3: Vocabulary List
              VocabularyList(vocabulary: lesson.vocabulary),

              // Page 4: Tip & Next Steps
              _buildCompletionPage(lesson),
            ],
          ),
        ),
        // Bottom Navigation
        _buildBottomNavigation(lesson),
      ],
    );
  }

  Widget _buildIntroductionPage(LessonResponseModel lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Introduction',
                        style: AppTextStyles.headlineSmall
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  lesson.introduction,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.museum_outlined,
                        color: AppColors.secondary, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Cultural Note',
                      style: AppTextStyles.headlineSmall
                          .copyWith(color: AppColors.secondaryDark),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.culturalNote,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Swipe to start learning →',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionPage(LessonResponseModel lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.primary,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Great Progress! 🎉',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.primaryDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve completed ${lesson.subtopic}',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_rounded,
                        color: AppColors.accentYellow),
                    const SizedBox(width: 12),
                    Text(
                      'Pro Tip',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.tip,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (lesson.nextSubtopic != null) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LearningScreen(
                        language: widget.language,
                        level: widget.level,
                        unitId: widget.unitId,
                        subtopicIndex: widget.subtopicIndex + 1,
                        unitTitle: widget.unitTitle,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Continue to Next Lesson',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(color: AppColors.primary),
              ),
              child: const Text(
                'Practice Quiz',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(LessonResponseModel lesson) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
              label: const Text('Previous'),
            )
          else
            const SizedBox(width: 80),
          const Spacer(),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? AppColors.primary
                      : AppColors.divider,
                ),
              );
            }),
          ),
          const Spacer(),
          if (_currentPage < 3)
            TextButton.icon(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              },
              label: const Text('Next'),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            )
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Lesson?'),
        content: const Text(
            'Your progress will be saved. You can continue anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
