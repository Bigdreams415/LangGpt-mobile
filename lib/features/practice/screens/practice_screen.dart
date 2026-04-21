import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../home/presentation/providers/home_provider.dart';
import '../../lessons/data/repositories/lessons_repository_impl.dart';
import '../../progress/data/datasources/progress_remote_datasource.dart';
import '../../quiz/screens/quiz_screen.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  final _lessonsRepo = LessonsRepositoryImpl.instance;
  final _progressDataSource = ProgressRemoteDataSource.instance;

  Future<void> _startQuickQuiz() async {
    final state = ref.read(homeProvider);
    final continueLearning = state.dashboard?.continueLearning;

    if (continueLearning == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please start a lesson first before practicing.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to start practice quiz.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    var targetSubtopicIndex = 0;

    try {
      final progress = await _progressDataSource.getProgress(
        userId: user.id,
        language: continueLearning.language,
      );

      final completedForUnit = progress.completedSubtopics
          .where((s) => s.unit == continueLearning.topic && s.completed)
          .map((s) => s.subtopicIndex)
          .toList();

      if (progress.currentUnit == continueLearning.topic &&
          completedForUnit.isNotEmpty) {
        completedForUnit.sort();
        targetSubtopicIndex = completedForUnit.last + 1;
      }
    } catch (_) {
      // Fall back to the first subtopic when progress can't be loaded.
    }

    try {
      final lessonDetail = await _lessonsRepo.getLessonDetail(
        language: continueLearning.language,
        topicId: continueLearning.topic,
      );

      if (!mounted) return;

      if (lessonDetail.subtopics.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No subtopics available for this lesson yet.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (targetSubtopicIndex >= lessonDetail.subtopics.length) {
        targetSubtopicIndex = lessonDetail.subtopics.length - 1;
      }

      final targetSubtopicName =
          lessonDetail.subtopics[targetSubtopicIndex].name;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            language: continueLearning.language,
            level: continueLearning.level,
            unitId: continueLearning.topic,
            subtopicIndex: targetSubtopicIndex,
            unitTitle: continueLearning.title,
            subtopicName: targetSubtopicName,
            isPractice: true,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not prepare a practice quiz. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Practice', style: AppTextStyles.displaySmall),
              const Text('Sharpen your skills daily',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 24),

              // Practice modes
              _PracticeModeCard(
                emoji: '❓',
                title: 'Quick Quiz',
                subtitle: '5 questions · 3 minutes',
                color: AppColors.primarySurface,
                accentColor: AppColors.primary,
                tag: 'Recommended',
                onTap: _startQuickQuiz,
              ),
              const SizedBox(height: 12),
              const _PracticeModeCard(
                emoji: '💬',
                title: 'Conversation',
                subtitle: 'Chat with AI tutor',
                color: AppColors.secondarySurface,
                accentColor: AppColors.secondary,
                tag: 'New',
              ),
              const SizedBox(height: 12),
              const _PracticeModeCard(
                emoji: '🔤',
                title: 'Translation',
                subtitle: 'Translate phrases',
                color: AppColors.accentBlueSurface,
                accentColor: AppColors.accentBlue,
                tag: null,
              ),
              const SizedBox(height: 12),
              const _PracticeModeCard(
                emoji: '🔊',
                title: 'Pronunciation',
                subtitle: 'Speak & get feedback',
                color: AppColors.accentYellowSurface,
                accentColor: Color(0xFFB8860B),
                tag: 'Coming soon',
              ),

              const SizedBox(height: 28),
              const Text('Recent activity',
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: 14),

              const _ActivityItem(
                  emoji: '❓',
                  title: 'Greetings Quiz',
                  result: '4/5 correct',
                  time: '2 hours ago',
                  color: AppColors.primarySurface),
              const _ActivityItem(
                  emoji: '💬',
                  title: 'Conversation practice',
                  result: 'Hausa · 10 min',
                  time: 'Yesterday',
                  color: AppColors.secondarySurface),
              const _ActivityItem(
                  emoji: '🔤',
                  title: 'Translation drill',
                  result: '8 phrases done',
                  time: '2 days ago',
                  color: AppColors.accentBlueSurface),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color accentColor;
  final String? tag;
  final VoidCallback? onTap;

  const _PracticeModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.accentColor,
    required this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(14)),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTextStyles.headlineSmall),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(tag!,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: accentColor)),
                        ),
                      ],
                    ],
                  ),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String result;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.emoji,
    required this.title,
    required this.result,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                Text(result, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(time, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
