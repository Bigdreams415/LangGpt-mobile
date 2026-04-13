import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedLanguage = 'Igbo';

  final _languages = ['Igbo', 'Yoruba', 'Hausa'];

  final _topics = [
    ('👋', 'Greetings', '8 lessons', AppColors.primarySurface, AppColors.primary),
    ('🔢', 'Numbers', '10 lessons', AppColors.accentYellowSurface, const Color(0xFFB8860B)),
    ('🎨', 'Colors', '6 lessons', AppColors.secondarySurface, AppColors.secondaryDark),
    ('👨‍👩‍👧', 'Family', '7 lessons', AppColors.accentBlueSurface, AppColors.accentBlue),
    ('🍲', 'Food', '9 lessons', const Color(0xFFF3E5F5), const Color(0xFF6A1B9A)),
    ('🕐', 'Time & Days', '8 lessons', AppColors.primarySurface, AppColors.primaryDark),
    ('🛒', 'Market', '11 lessons', AppColors.secondarySurface, AppColors.secondary),
    ('✈️', 'Travel', '12 lessons', AppColors.accentBlueSurface, AppColors.accentBlue),
    ('💬', 'Proverbs', '15 lessons', const Color(0xFFFFF8E1), const Color(0xFF795548)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Explore', style: AppTextStyles.displaySmall),
                  const Text('All topics across every language', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 20),

                  // Language filter
                  Row(
                    children: _languages.map((lang) {
                      final isSelected = _selectedLanguage == lang;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedLanguage = lang),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.divider,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            lang,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: _topics.length,
                itemBuilder: (context, i) {
                  final t = _topics[i];
                  return _TopicCard(
                    emoji: t.$1,
                    title: t.$2,
                    subtitle: t.$3,
                    bgColor: t.$4,
                    textColor: t.$5,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color textColor;

  const _TopicCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.textColor,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const Spacer(),
            Text(title, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}