import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/home_dashboard_model.dart';

class LeaderboardEntry extends StatelessWidget {
  final LeaderboardEntryModel entry;

  const LeaderboardEntry({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Medal or rank number
          if (entry.medal != null)
            Text(
              entry.medal!,
              style: const TextStyle(fontSize: 20),
            )
          else
            Container(
              width: 28,
              alignment: Alignment.center,
              child: Text(
                '${entry.rank}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          const SizedBox(width: 10),
          // Name
          Expanded(
            child: Text(
              entry.name,
              style: AppTextStyles.labelLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // XP
          Text(
            '${entry.xp} XP',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}