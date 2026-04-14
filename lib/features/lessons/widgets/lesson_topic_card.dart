import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/lesson_model.dart';

class LessonTopicCard extends StatelessWidget {
  final LessonTopicModel topic;
  final String language;
  final VoidCallback onTap;

  const LessonTopicCard({
    super.key,
    required this.topic,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: topic.isCompleted
                        ? AppColors.primarySurface
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      topic.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: AppTextStyles.headlineSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topic.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondarySurface,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              topic.level.toUpperCase(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.secondaryDark,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.timer_outlined,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${topic.durationMinutes} min',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (topic.isCompleted)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: AppColors.textHint,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}