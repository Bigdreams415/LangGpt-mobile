import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _languages = [
    _LanguageOption(
      code: 'en',
      name: 'English',
      subtitle: 'Default app language',
      flag: '🇬🇧',
      color: AppColors.accentBlue,
      surface: AppColors.accentBlueSurface,
    ),
    _LanguageOption(
      code: 'igbo',
      name: 'Igbo',
      subtitle: 'Southeast Nigeria · ~45M speakers',
      flag: '🇳🇬',
      color: AppColors.primary,
      surface: AppColors.primarySurface,
    ),
    _LanguageOption(
      code: 'yoruba',
      name: 'Yoruba',
      subtitle: 'Southwest Nigeria · ~50M speakers',
      flag: '🇳🇬',
      color: AppColors.accentYellow,
      surface: AppColors.accentYellowSurface,
    ),
    _LanguageOption(
      code: 'hausa',
      name: 'Hausa',
      subtitle: 'North Nigeria · ~80M speakers',
      flag: '🇳🇬',
      color: AppColors.secondary,
      surface: AppColors.secondarySurface,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('App language'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            'Choose your preferred language for the app interface.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ..._languages.map((lang) => _LanguageCard(option: lang)),
        ],
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String name;
  final String subtitle;
  final String flag;
  final Color color;
  final Color surface;
  const _LanguageOption({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.flag,
    required this.color,
    required this.surface,
  });
}

class _LanguageCard extends StatefulWidget {
  final _LanguageOption option;
  const _LanguageCard({required this.option});

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opt = widget.option;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() => _selected = !_selected);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selected
                  ? (isDark ? opt.color.withValues(alpha: 0.12) : opt.surface)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _selected
                    ? opt.color
                    : isDark
                        ? AppColors.darkDivider
                        : AppColors.divider,
                width: _selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selected
                        ? opt.color.withValues(alpha: 0.15)
                        : (isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(opt.flag, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt.name,
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: _selected ? opt.color : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        opt.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textHintDark : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selected ? opt.color : Colors.transparent,
                    border: Border.all(
                      color: _selected ? opt.color : (isDark ? AppColors.darkDivider : AppColors.divider),
                      width: 2,
                    ),
                  ),
                  child: _selected
                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
