import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../lessons/data/models/lesson_model.dart';
import '../presentation/providers/explore_provider.dart';
import '../widgets/explore_shimmer.dart';
import '../widgets/explore_unit_card.dart';
import 'explore_unit_detail_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  static const _languages = ['Igbo', 'Yoruba', 'Hausa'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  void _loadData() {
    final language = ref.read(exploreSelectedLanguageProvider);
    ref.read(exploreUnitsProvider.notifier).loadUnits(language);

    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref.read(exploreProgressProvider.notifier).loadProgress(
            userId: user.id,
            language: language,
          );
    }
  }

  void _onLanguageChanged(String language) {
    ref.read(exploreSelectedLanguageProvider.notifier).state = language;
    ref.read(exploreUnitsProvider.notifier).reload(language);

    final user = ref.read(currentUserProvider);
    if (user != null) {
      ref.read(exploreProgressProvider.notifier).loadProgress(
            userId: user.id,
            language: language,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = ref.watch(exploreSelectedLanguageProvider);
    final unitsState = ref.watch(exploreUnitsProvider);
    final progressState = ref.watch(exploreProgressProvider);

    final completedUnits =
        progressState.data?.completedUnits.toSet() ?? <String>{};

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explore', style: AppTextStyles.displaySmall),
                  const Text(
                    'All topics across every language',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  _buildLanguageTabs(selectedLanguage),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Expanded(
              child: _buildBody(
                  unitsState, completedUnits, selectedLanguage, progressState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTabs(String selected) {
    return Row(
      children: _languages.map((lang) {
        final isSelected = selected == lang;
        return GestureDetector(
          onTap: () => _onLanguageChanged(lang),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 10),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: 1.5,
              ),
            ),
            child: Text(
              lang,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBody(
    ExploreUnitsState state,
    Set<String> completedUnits,
    String language,
    ExploreProgressState progressState,
  ) {
    switch (state.status) {
      case ExploreUnitsStatus.initial:
      case ExploreUnitsStatus.loading:
        return const ExploreGridShimmer();

      case ExploreUnitsStatus.error:
        return _buildError(state.errorMessage, language);

      case ExploreUnitsStatus.loaded:
        final topics = state.data?.topics ?? [];
        if (topics.isEmpty) {
          return const Center(child: Text('No topics available'));
        }
        return _buildGrid(topics, completedUnits, language, progressState);
    }
  }

  Widget _buildGrid(
    List<LessonUnitModel> topics,
    Set<String> completedUnits,
    String language,
    ExploreProgressState progressState,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: topics.length,
      itemBuilder: (context, i) {
        final unit = topics[i];
        return ExploreUnitCard(
          unit: unit,
          isCompleted: completedUnits.contains(unit.id),
          onTap: () => _openUnit(unit, language, progressState),
        );
      },
    );
  }

  void _openUnit(
      LessonUnitModel unit, String language, ExploreProgressState progressState) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExploreUnitDetailScreen(
          language: language,
          unitId: unit.id,
          title: unit.title,
          emoji: unit.emoji,
          level: unit.level,
          progress: progressState.data,
        ),
      ),
    );
  }

  Widget _buildError(String? message, String language) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.textHint, size: 56),
            const SizedBox(height: 16),
            Text(
              message ?? 'Failed to load topics',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(exploreUnitsProvider.notifier).reload(language),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
