import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // ── Top Bar ──────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ụtụtụ ọma 👋',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text('Chukwuemeka', style: AppTextStyles.displaySmall),
                      ],
                    ),
                  ),
                  // Streak badge
                  const _StreakBadge(streak: 7),
                  const SizedBox(width: 10),
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('CO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Daily Goal Progress ───────────────────────────────────────
              _DailyGoalCard(),
              const SizedBox(height: 24),

              // ── Continue Lesson ───────────────────────────────────────────
              const Text('Continue learning', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 12),
              _ContinueLessonCard(),
              const SizedBox(height: 24),

              // ── Stats Row ─────────────────────────────────────────────────
              const Row(
                children: [
                  Expanded(child: _StatCard(value: '12', label: 'Lessons\ncompleted', icon: '📚', color: AppColors.primarySurface, textColor: AppColors.primaryDark)),
                  SizedBox(width: 12),
                  Expanded(child: _StatCard(value: '87%', label: 'Quiz\naccuracy', icon: '🎯', color: AppColors.secondarySurface, textColor: AppColors.secondaryDark)),
                  SizedBox(width: 12),
                  Expanded(child: _StatCard(value: '340', label: 'XP\nearned', icon: '⚡', color: AppColors.accentYellowSurface, textColor: Color(0xFFB8860B))),
                ],
              ),
              const SizedBox(height: 24),

              // ── Today's Topics ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Today's lessons", style: AppTextStyles.headlineMedium),
                  TextButton(
                    onPressed: () {},
                    child: Text('See all', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...const [
                _LessonItem(emoji: '👋', title: 'Greetings', subtitle: 'Igbo · Beginner', duration: '5 min', isCompleted: true),
                _LessonItem(emoji: '🔢', title: 'Numbers 1–10', subtitle: 'Igbo · Beginner', duration: '8 min', isCompleted: false),
                _LessonItem(emoji: '🎨', title: 'Colors', subtitle: 'Igbo · Beginner', duration: '6 min', isCompleted: false),
              ],
              const SizedBox(height: 24),

              // ── Leaderboard preview ───────────────────────────────────────
              _LeaderboardPreview(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ───────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: AppTextStyles.headlineSmall.copyWith(color: const Color(0xFFE65100)),
          ),
        ],
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily goal',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white.withOpacity(0.8)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text('3/5 done', style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Keep going!\nYou\'re 60% there today.', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.white.withOpacity(0.25),
              color: AppColors.accentYellow,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueLessonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(child: Text('🏠', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Family Members', style: AppTextStyles.headlineSmall),
                const Text('Igbo · Beginner · Lesson 4', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: const LinearProgressIndicator(
                    value: 0.4,
                    backgroundColor: AppColors.divider,
                    color: AppColors.secondary,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  final Color color;
  final Color textColor;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headlineLarge.copyWith(color: textColor)),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: textColor.withOpacity(0.7))),
        ],
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String duration;
  final bool isCompleted;

  const _LessonItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.primarySurface : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineSmall),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isCompleted)
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(duration, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final leaders = [
      ('🥇', 'Ngozi_learns', '1,240 XP'),
      ('🥈', 'AbdullahiK', '980 XP'),
      ('🥉', 'Adesuwa__', '760 XP'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Top learners this week', style: AppTextStyles.headlineSmall),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: Text('See all', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...leaders.map((l) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(l.$1, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(child: Text(l.$2, style: AppTextStyles.labelLarge)),
                Text(l.$3, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}