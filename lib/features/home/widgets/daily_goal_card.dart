import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/home_dashboard_model.dart';

class DailyGoalCard extends StatelessWidget {
  final DailyGoalModel goal;

  const DailyGoalCard({
    super.key,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (goal.percentage / 100).clamp(0.0, 1.0);
    final isComplete = percentage >= 1.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY GOAL',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${goal.completed}',
                        style: AppTextStyles.displayMedium.copyWith(
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${goal.target}',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isComplete ? 'Goal reached today 🎉' : 'lessons completed',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isComplete
                        ? AppColors.primary
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    fontWeight: isComplete ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 76,
            height: 76,
            child: CustomPaint(
              painter: _RingPainter(
                progress: percentage,
                color: AppColors.primary,
                backgroundColor: isDark ? AppColors.darkDivider : AppColors.divider,
              ),
              child: Center(
                child: Text(
                  '${(percentage * 100).toInt()}%',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
