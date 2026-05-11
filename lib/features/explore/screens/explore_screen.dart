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
      _loadAll();
    });
  }

  String get _registeredLanguage {
    final user = ref.read(currentUserProvider);
    return user?.selectedLanguage ?? 'Igbo';
  }

  void _loadAll() {
    final language = ref.read(exploreSelectedLanguageProvider);
    ref.read(exploreUnitsProvider.notifier).loadUnits(language);
    _loadRegisteredProgress();
  }

  void _loadRegisteredProgress() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final registered = user.selectedLanguage ?? 'Igbo';
    ref.read(exploreProgressProvider.notifier).loadProgress(
          userId: user.id,
          language: registered,
        );
  }

  void _onLanguageChanged(String language) {
    ref.read(exploreSelectedLanguageProvider.notifier).state = language;
    ref.read(exploreUnitsProvider.notifier).reload(language);
  }

  // A unit is unlocked only when browsing the registered language.
  // Logic mirrors home screen: completed units + current unit are open.
  bool _isUnitUnlocked(String unitId, ExploreProgressState progressState) {
    final progress = progressState.data;
    if (progress == null) return true;

    final completed = progress.completedUnits.toSet();
    if (completed.contains(unitId)) return true;
    if (progress.currentUnit.isNotEmpty && progress.currentUnit == unitId) {
      return true;
    }
    // Also unlock the next recommended unit so the user can start it
    if (progress.nextRecommendedUnit.isNotEmpty &&
        progress.nextRecommendedUnit == unitId) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = ref.watch(exploreSelectedLanguageProvider);
    final unitsState = ref.watch(exploreUnitsProvider);
    final progressState = ref.watch(exploreProgressProvider);
    final registered = _registeredLanguage;
    final isBrowsingOtherLanguage = selectedLanguage != registered;

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
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Banner when the user is browsing a different language
            if (isBrowsingOtherLanguage)
              _buildOtherLanguageBanner(
                  selectedLanguage, registered, progressState),

            Expanded(
              child: _buildBody(
                unitsState,
                progressState,
                selectedLanguage,
                registered,
                isBrowsingOtherLanguage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTabs(String selected) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
      ),
    );
  }

  Widget _buildOtherLanguageBanner(
    String browsing,
    String registered,
    ExploreProgressState progressState,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentBlueSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.accentBlue.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.accentBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accentBlue,
                ),
                children: [
                  TextSpan(
                    text: 'You\'re learning $registered. ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Tap "Start" on any $browsing lesson to switch languages.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    ExploreUnitsState state,
    ExploreProgressState progressState,
    String selectedLanguage,
    String registeredLanguage,
    bool isBrowsingOtherLanguage,
  ) {
    switch (state.status) {
      case ExploreUnitsStatus.initial:
      case ExploreUnitsStatus.loading:
        return const ExploreGridShimmer();

      case ExploreUnitsStatus.error:
        return _buildError(state.errorMessage, selectedLanguage);

      case ExploreUnitsStatus.loaded:
        final topics = state.data?.topics ?? [];
        if (topics.isEmpty) {
          return const Center(child: Text('No topics available'));
        }
        return _buildGrid(
          topics,
          progressState,
          selectedLanguage,
          registeredLanguage,
          isBrowsingOtherLanguage,
        );
    }
  }

  Widget _buildGrid(
    List<LessonUnitModel> topics,
    ExploreProgressState progressState,
    String selectedLanguage,
    String registeredLanguage,
    bool isBrowsingOtherLanguage,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: topics.length,
      itemBuilder: (context, i) {
        final unit = topics[i];

        // Lock logic only applies to the user's registered language
        final isCompleted = !isBrowsingOtherLanguage &&
            (progressState.data?.completedUnits.contains(unit.id) ?? false);
        final isLocked = !isBrowsingOtherLanguage &&
            !_isUnitUnlocked(unit.id, progressState);

        return ExploreUnitCard(
          unit: unit,
          isCompleted: isCompleted,
          isLocked: isLocked,
          onTap: () => _onUnitTapped(
            unit,
            selectedLanguage,
            registeredLanguage,
            isBrowsingOtherLanguage,
            isLocked,
            progressState,
          ),
        );
      },
    );
  }

  void _onUnitTapped(
    LessonUnitModel unit,
    String selectedLanguage,
    String registeredLanguage,
    bool isBrowsingOtherLanguage,
    bool isLocked,
    ExploreProgressState progressState,
  ) {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pass the current quiz (80%+) to unlock this topic.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExploreUnitDetailScreen(
          language: selectedLanguage,
          unitId: unit.id,
          title: unit.title,
          emoji: unit.emoji,
          level: unit.level,
          progress: progressState.data,
          registeredLanguage: registeredLanguage,
          isForeignLanguage: isBrowsingOtherLanguage,
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
