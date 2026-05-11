import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../home/presentation/providers/home_provider.dart';
import '../../lessons/data/repositories/lessons_repository_impl.dart';
import '../../progress/data/datasources/progress_remote_datasource.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../presentation/providers/conversation_provider.dart';
import '../presentation/providers/practice_activity_provider.dart';
import 'conversation_screen.dart';
import 'translation_screen.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  final _lessonsRepo = LessonsRepositoryImpl.instance;
  final _progressDataSource = ProgressRemoteDataSource.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadActivity());
  }

  void _loadActivity() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    ref.read(practiceActivityProvider.notifier).load(
          userId: user.id,
          language: user.selectedLanguage ?? 'Igbo',
        );
  }

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
    } catch (_) {}

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

  void _startTranslation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TranslationScreen()),
    ).then((_) => _loadActivity());
  }

  Future<void> _startConversation() async {
    final state = ref.read(homeProvider);
    final continueLearning = state.dashboard?.continueLearning;

    if (continueLearning == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please start a lesson first before practicing conversation.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final ctx = ConversationContext(
      language: continueLearning.language,
      level: continueLearning.level,
      unit: continueLearning.topic,
      subtopicIndex: 0,
      unitTitle: continueLearning.title,
    );

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConversationScreen(context: ctx)),
    );

    if (!mounted) return;

    final convState = ref.read(conversationProvider);
    final userMsgCount = convState.messages.where((m) => m.isUser).length;
    if (userMsgCount > 0) {
      await saveConversationActivity(
        language: ctx.language,
        unitTitle: ctx.unitTitle,
        messageCount: userMsgCount,
      );
      _loadActivity();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityState = ref.watch(practiceActivityProvider);

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
              _PracticeModeCard(
                emoji: '💬',
                title: 'Conversation',
                subtitle: 'Chat with AI tutor',
                color: AppColors.secondarySurface,
                accentColor: AppColors.secondary,
                tag: 'New',
                onTap: _startConversation,
              ),
              const SizedBox(height: 12),
              _PracticeModeCard(
                emoji: '🔤',
                title: 'Translation',
                subtitle: 'Translate phrases',
                color: AppColors.accentBlueSurface,
                accentColor: AppColors.accentBlue,
                tag: null,
                onTap: _startTranslation,
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

              _buildActivitySection(activityState),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivitySection(PracticeActivityState state) {
    switch (state.status) {
      case PracticeActivityStatus.initial:
      case PracticeActivityStatus.loading:
        return const _ActivityShimmer();

      case PracticeActivityStatus.error:
      case PracticeActivityStatus.loaded:
        if (state.activities.isEmpty) {
          return _buildEmptyActivity();
        }
        return Column(
          children: state.activities
              .map((a) => _ActivityItem(
                    emoji: a.emoji,
                    title: a.title,
                    result: a.subtitle,
                    time: a.timeAgo,
                    color: _colorForType(a.type),
                  ))
              .toList(),
        );
    }
  }

  Widget _buildEmptyActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.history_rounded,
              size: 40, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text(
            'No activity yet',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Complete a quiz, conversation, or translation\nto see your progress here.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _colorForType(ActivityType type) {
    switch (type) {
      case ActivityType.quiz:
        return AppColors.primarySurface;
      case ActivityType.conversation:
        return AppColors.secondarySurface;
      case ActivityType.translation:
        return AppColors.accentBlueSurface;
    }
  }
}

class _ActivityShimmer extends StatelessWidget {
  const _ActivityShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 11,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 11,
                width: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
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
