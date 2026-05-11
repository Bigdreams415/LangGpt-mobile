import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../lessons/data/models/lesson_model.dart';

class ExploreUnitCard extends StatelessWidget {
  final LessonUnitModel unit;
  final bool isCompleted;
  final VoidCallback onTap;

  const ExploreUnitCard({
    super.key,
    required this.unit,
    required this.onTap,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final levelStyle = _levelStyle(unit.level);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.divider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: levelStyle.bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      unit.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const Spacer(),
                if (isCompleted)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              unit.title,
              style: AppTextStyles.headlineSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: levelStyle.badgeColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _capitalize(unit.level),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: levelStyle.textColor,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${unit.subtopicCount} lessons',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${unit.durationMinutes} min',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textHint,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  _LevelStyle _levelStyle(String level) {
    switch (level.toLowerCase()) {
      case 'intermediate':
        return const _LevelStyle(
          bgColor: AppColors.accentYellowSurface,
          badgeColor: AppColors.accentYellowSurface,
          textColor: Color(0xFFB8860B),
        );
      case 'advanced':
        return const _LevelStyle(
          bgColor: AppColors.secondarySurface,
          badgeColor: AppColors.secondarySurface,
          textColor: AppColors.secondaryDark,
        );
      default: // beginner
        return const _LevelStyle(
          bgColor: AppColors.primarySurface,
          badgeColor: AppColors.primarySurface,
          textColor: AppColors.primaryDark,
        );
    }
  }
}

class _LevelStyle {
  final Color bgColor;
  final Color badgeColor;
  final Color textColor;

  const _LevelStyle({
    required this.bgColor,
    required this.badgeColor,
    required this.textColor,
  });
}
