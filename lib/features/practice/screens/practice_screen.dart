import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text('Practice', style: AppTextStyles.displaySmall),
              Text('Sharpen your skills daily', style: AppTextStyles.bodyMedium),
              SizedBox(height: 24),

              // Practice modes
              _PracticeModeCard(
                emoji: '❓',
                title: 'Quick Quiz',
                subtitle: '5 questions · 3 minutes',
                color: AppColors.primarySurface,
                accentColor: AppColors.primary,
                tag: 'Recommended',
              ),
              SizedBox(height: 12),
              _PracticeModeCard(
                emoji: '💬',
                title: 'Conversation',
                subtitle: 'Chat with AI tutor',
                color: AppColors.secondarySurface,
                accentColor: AppColors.secondary,
                tag: 'New',
              ),
              SizedBox(height: 12),
              _PracticeModeCard(
                emoji: '🔤',
                title: 'Translation',
                subtitle: 'Translate phrases',
                color: AppColors.accentBlueSurface,
                accentColor: AppColors.accentBlue,
                tag: null,
              ),
              SizedBox(height: 12),
              _PracticeModeCard(
                emoji: '🔊',
                title: 'Pronunciation',
                subtitle: 'Speak & get feedback',
                color: AppColors.accentYellowSurface,
                accentColor: Color(0xFFB8860B),
                tag: 'Coming soon',
              ),

              SizedBox(height: 28),
              Text('Recent activity', style: AppTextStyles.headlineMedium),
              SizedBox(height: 14),

              _ActivityItem(emoji: '❓', title: 'Greetings Quiz', result: '4/5 correct', time: '2 hours ago', color: AppColors.primarySurface),
              _ActivityItem(emoji: '💬', title: 'Conversation practice', result: 'Hausa · 10 min', time: 'Yesterday', color: AppColors.secondarySurface),
              _ActivityItem(emoji: '🔤', title: 'Translation drill', result: '8 phrases done', time: '2 days ago', color: AppColors.accentBlueSurface),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _PracticeModeCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Color accentColor;
  final String? tag;

  const _PracticeModeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.accentColor,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTextStyles.headlineSmall),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(tag!, style: AppTextStyles.labelSmall.copyWith(color: accentColor)),
                        ),
                      ],
                    ],
                  ),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String result;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.emoji,
    required this.title,
    required this.result,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                Text(result, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(time, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}