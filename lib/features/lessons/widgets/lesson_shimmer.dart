import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../home/widgets/shimmer_widgets.dart';

class LessonTopicShimmer extends StatelessWidget {
  const LessonTopicShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Row(
        children: [
          ShimmerBox(width: 50, height: 50, borderRadius: 12),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120, height: 18, borderRadius: 6),
                SizedBox(height: 6),
                ShimmerBox(width: 200, height: 14, borderRadius: 4),
                SizedBox(height: 8),
                Row(
                  children: [
                    ShimmerBox(width: 60, height: 20, borderRadius: 10),
                    SizedBox(width: 8),
                    ShimmerBox(width: 50, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          ShimmerBox(width: 18, height: 18, borderRadius: 4),
        ],
      ),
    );
  }
}