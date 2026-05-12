import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class StatsOverviewCard extends StatelessWidget {
  final String lessonsValue;
  final String accuracyValue;
  final String xpValue;

  const StatsOverviewCard({
    super.key,
    required this.lessonsValue,
    required this.accuracyValue,
    required this.xpValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
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
            child: _StatColumn(
              value: lessonsValue,
              label: 'Lessons',
              isDark: isDark,
            ),
          ),
          _Divider(isDark: isDark),
          Expanded(
            child: _StatColumn(
              value: accuracyValue,
              label: 'Accuracy',
              isDark: isDark,
            ),
          ),
          _Divider(isDark: isDark),
          Expanded(
            child: _StatColumn(
              value: xpValue,
              label: 'XP',
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _StatColumn({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.displaySmall.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: isDark ? AppColors.darkDivider : AppColors.divider,
    );
  }
}
