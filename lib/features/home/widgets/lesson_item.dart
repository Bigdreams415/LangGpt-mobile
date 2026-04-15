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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.surfaceVariant : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: lesson.isCompleted
                  ? AppColors.primarySurface
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: AppTextStyles.headlineSmall,
                ),
                Text(
                  lesson.subtitle,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (lesson.isCompleted)
                Container(
                  width: 24,
                  height: 24,
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
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.textHint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '${lesson.durationMinutes} min',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
