import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../lessons/data/models/lesson_model.dart';
import '../../lessons/screens/learning_screen.dart';
import '../../progress/data/models/progress_model.dart';
import '../presentation/providers/explore_provider.dart';
import '../widgets/explore_shimmer.dart';

class ExploreUnitDetailScreen extends ConsumerStatefulWidget {
  final String language;
  final String unitId;
  final String title;
  final String emoji;
  final String level;
  final ProgressResponseModel? progress;

  const ExploreUnitDetailScreen({
    super.key,
    required this.language,
    required this.unitId,
    required this.title,
    required this.emoji,
    required this.level,
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

    final detail = state.data!;
    return _buildContent(detail);
  }

  Widget _buildContent(LessonDetailModel detail) {
    final completedSubtopics = widget.progress?.completedSubtopics
            .where((s) => s.unit == widget.unitId)
            .map((s) => s.subtopicIndex)
            .toSet() ??
        {};

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(detail)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSubtopicTile(
                detail,
                index,
                completedSubtopics.contains(index),
              ),
              childCount: detail.subtopics.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(LessonDetailModel detail) {
    final levelColor = _levelColor(widget.level);

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
                        color: levelColor.withValues(alpha: 0.25),
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
              _statChip(
                  Icons.menu_book_rounded, '${detail.subtopics.length} subtopics'),
              const SizedBox(width: 10),
              _statChip(Icons.schedule_rounded, '$totalMinutes min total'),
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
      LessonDetailModel detail, int index, bool completed) {
    final subtopic = detail.subtopics[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: completed
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
            color: completed ? AppColors.primary : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: completed
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18)
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
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.textHint, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _startLesson(detail, index),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                completed ? AppColors.primarySurface : AppColors.primary,
            foregroundColor:
                completed ? AppColors.primary : Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
            minimumSize: const Size(0, 36),
          ),
          child: Text(
            completed ? 'Redo' : 'Start',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  void _startLesson(LessonDetailModel detail, int subtopicIndex) {
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

  Color _levelColor(String level) {
    switch (level.toLowerCase()) {
      case 'intermediate':
        return AppColors.accentYellow;
      case 'advanced':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
