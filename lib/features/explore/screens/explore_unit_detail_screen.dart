import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../lessons/data/models/lesson_model.dart';
import '../../lessons/screens/learning_screen.dart';
import '../../progress/data/models/progress_model.dart';
import '../presentation/providers/explore_provider.dart';
import '../widgets/explore_language_dialog.dart';
import '../widgets/explore_shimmer.dart';

class ExploreUnitDetailScreen extends ConsumerStatefulWidget {
  final String language;
  final String unitId;
  final String title;
  final String emoji;
  final String level;
  final ProgressResponseModel? progress;
  final String registeredLanguage;
  final bool isForeignLanguage;

  const ExploreUnitDetailScreen({
    super.key,
    required this.language,
    required this.unitId,
    required this.title,
    required this.emoji,
    required this.level,
    required this.registeredLanguage,
    required this.isForeignLanguage,
    this.progress,
  });

  @override
  ConsumerState<ExploreUnitDetailScreen> createState() =>
      _ExploreUnitDetailScreenState();
}

class _ExploreUnitDetailScreenState
    extends ConsumerState<ExploreUnitDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(exploreUnitDetailProvider.notifier).loadUnitDetail(
            language: widget.language,
            unitId: widget.unitId,
          );
    });
  }

  // Returns the set of completed subtopic indices for this unit
  Set<int> get _completedIndices {
    if (widget.progress == null || widget.isForeignLanguage) return {};
    return widget.progress!.completedSubtopics
        .where((s) => s.unit == widget.unitId)
        .map((s) => s.subtopicIndex)
        .toSet();
  }

  // The first subtopic index that hasn't been completed yet
  int _nextUnlockedIndex(int totalSubtopics) {
    if (widget.isForeignLanguage) return 0;
    final completed = _completedIndices;
    for (var i = 0; i < totalSubtopics; i++) {
      if (!completed.contains(i)) return i;
    }
    return totalSubtopics; // All done
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreUnitDetailProvider);

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
        title: Text(widget.title, style: AppTextStyles.headlineMedium),
        centerTitle: true,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(ExploreUnitDetailState state) {
    if (state.status == ExploreUnitDetailStatus.loading ||
        state.status == ExploreUnitDetailStatus.initial) {
      return const ExploreSubtopicShimmer();
    }

    if (state.status == ExploreUnitDetailStatus.error) {
      return _buildError(state.errorMessage);
    }

    return _buildContent(state.data!);
  }

  Widget _buildContent(LessonDetailModel detail) {
    final nextUnlocked = _nextUnlockedIndex(detail.subtopics.length);
    final completed = _completedIndices;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(detail)),

        // Foreign language notice
        if (widget.isForeignLanguage)
          SliverToBoxAdapter(
            child: _buildForeignLanguageBanner(),
          ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSubtopicTile(
                detail,
                index,
                isCompleted: completed.contains(index),
                isLocked: !widget.isForeignLanguage &&
                    index > nextUnlocked &&
                    !completed.contains(index),
              ),
              childCount: detail.subtopics.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForeignLanguageBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentBlueSurface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.accentBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.accentBlue),
                children: [
                  TextSpan(
                    text: 'You\'re learning ${widget.registeredLanguage}. ',
                    style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(
                      text:
                          'Tap "Start" to switch your learning language to '),
                  TextSpan(
                    text: widget.language,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LessonDetailModel detail) {
    final totalMinutes = detail.subtopics
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(widget.emoji,
                      style: const TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _capitalize(widget.level),
                        style: AppTextStyles.labelSmall
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statChip(Icons.menu_book_rounded,
                  '${detail.subtopics.length} subtopics'),
              const SizedBox(width: 10),
              _statChip(
                  Icons.schedule_rounded, '$totalMinutes min total'),
              const SizedBox(width: 10),
              _statChip(Icons.language_rounded, widget.language),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtopicTile(
    LessonDetailModel detail,
    int index, {
    required bool isCompleted,
    required bool isLocked,
  }) {
    final subtopic = detail.subtopics[index];

    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.primary.withValues(alpha: 0.35)
                : AppColors.divider,
          ),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primary
                  : isLocked
                      ? AppColors.surfaceVariant
                      : AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 18)
                  : isLocked
                      ? const Icon(Icons.lock_rounded,
                          color: AppColors.textHint, size: 16)
                      : Text(
                          '${index + 1}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
            ),
          ),
          title: Text(
            subtopic.name,
            style: AppTextStyles.bodyMedium
                .copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                subtopic.description,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      size: 12, color: AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    '${subtopic.durationMinutes} min',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textHint, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          trailing: _buildButton(detail, index, isCompleted, isLocked),
        ),
      ),
    );
  }

  Widget _buildButton(
    LessonDetailModel detail,
    int index,
    bool isCompleted,
    bool isLocked,
  ) {
    if (isLocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'Locked',
          style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textHint, fontSize: 12),
        ),
      );
    }

    final label = isCompleted ? 'Redo' : 'Start';
    final bgColor =
        isCompleted ? AppColors.primarySurface : AppColors.primary;
    final fgColor = isCompleted ? AppColors.primary : Colors.white;

    return ElevatedButton(
      onPressed: () => _onStartTapped(detail, index),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        minimumSize: const Size(0, 36),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _onStartTapped(LessonDetailModel detail, int subtopicIndex) {
    if (widget.isForeignLanguage) {
      showLanguageMismatchDialog(
        context: context,
        ref: ref,
        browseLanguage: widget.language,
        registeredLanguage: widget.registeredLanguage,
        onSwitched: () {
          // After switching, launch the lesson
          _launchLesson(detail, subtopicIndex);
        },
      );
      return;
    }
    _launchLesson(detail, subtopicIndex);
  }

  void _launchLesson(LessonDetailModel detail, int subtopicIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningScreen(
          language: widget.language,
          level: detail.level,
          unitId: widget.unitId,
          subtopicIndex: subtopicIndex,
          unitTitle: widget.title,
        ),
      ),
    );
  }

  Widget _buildError(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              message ?? 'Failed to load unit details',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(exploreUnitDetailProvider.notifier).loadUnitDetail(
                      language: widget.language,
                      unitId: widget.unitId,
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
