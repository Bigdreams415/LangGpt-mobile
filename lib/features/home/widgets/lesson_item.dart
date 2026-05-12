import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/home_dashboard_model.dart';

class LessonItem extends StatelessWidget {
  final TodayLessonModel lesson;
  final bool isLocked;

  const LessonItem({
    super.key,
    required this.lesson,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Opacity(
            opacity: isLocked ? 0.5 : 1.0,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  lesson.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isLocked
                        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                        : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (lesson.isCompleted)
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 14,
              ),
            )
          else if (isLocked)
            Icon(
              Icons.lock_outline_rounded,
              color: isDark ? AppColors.textHintDark : AppColors.textHint,
              size: 18,
            )
          else
            Row(
              children: [
                Text(
                  '${lesson.durationMinutes} min',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
