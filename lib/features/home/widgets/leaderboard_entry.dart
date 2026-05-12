import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/home_dashboard_model.dart';

class LeaderboardEntry extends StatelessWidget {
  final LeaderboardEntryModel entry;
  final bool isCurrentUser;

  const LeaderboardEntry({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
  });

  Color _avatarBg(bool isDark) {
    if (isCurrentUser) {
      return AppColors.primary;
    }
    return isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
  }

  Color _avatarFg(bool isDark) {
    if (isCurrentUser) return Colors.white;
    return isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Center(
              child: entry.medal != null
                  ? Text(
                      entry.medal!,
                      style: const TextStyle(fontSize: 18),
                    )
                  : Text(
                      '${entry.rank}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _avatarBg(isDark),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                style: AppTextStyles.labelLarge.copyWith(
                  color: _avatarFg(isDark),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    entry.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: isCurrentUser ? FontWeight.w700 : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCurrentUser) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'YOU',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${entry.xp}',
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'XP',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
