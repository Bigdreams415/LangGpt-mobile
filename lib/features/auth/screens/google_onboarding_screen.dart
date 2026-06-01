import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import '../presentation/providers/auth_provider.dart';

class GoogleOnboardingScreen extends ConsumerStatefulWidget {
  const GoogleOnboardingScreen({super.key});

  @override
  ConsumerState<GoogleOnboardingScreen> createState() =>
      _GoogleOnboardingScreenState();
}

class _GoogleOnboardingScreenState
    extends ConsumerState<GoogleOnboardingScreen> {
  String? _selectedLanguage;
  String? _selectedLevel;
  bool _isLoading = false;

  static const _languages = [
    _LanguageOption(
      code: 'Igbo',
      name: 'Igbo',
      subtitle: 'Southeast Nigeria',
      speakers: '~45M speakers',
      color: AppColors.primary,
      bgColor: AppColors.primarySurface,
    ),
    _LanguageOption(
      code: 'Yoruba',
      name: 'Yoruba',
      subtitle: 'Southwest Nigeria',
      speakers: '~50M speakers',
      color: AppColors.secondary,
      bgColor: AppColors.secondarySurface,
    ),
    _LanguageOption(
      code: 'Hausa',
      name: 'Hausa',
      subtitle: 'North Nigeria',
      speakers: '~80M speakers',
      color: AppColors.accentBlue,
      bgColor: AppColors.accentBlueSurface,
    ),
  ];

  static const _levels = [
    _LevelOption(value: 'beginner', title: 'Beginner', subtitle: 'I know little to nothing', icon: '🌱'),
    _LevelOption(value: 'intermediate', title: 'Intermediate', subtitle: 'I know some basics', icon: '🌿'),
    _LevelOption(value: 'advanced', title: 'Advanced', subtitle: 'I can hold conversations', icon: '🌳'),
  ];

  void _handleFinish() async {
    if (_selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a language to learn'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your current level'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await ref.read(authProvider.notifier).setupLanguageAndLevel(
          _selectedLanguage!,
          _selectedLevel!,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              const Text('Your learning\npath', style: AppTextStyles.displaySmall),
              const SizedBox(height: 8),
              const Text(
                'Choose what you want to learn and your current level.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Language Selection
              const Text('Which language do you want to learn?',
                  style: AppTextStyles.headlineSmall),
              const SizedBox(height: 14),
              ...List.generate(_languages.length, (i) {
                final lang = _languages[i];
                final isSelected = _selectedLanguage == lang.code;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLanguage = lang.code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? lang.bgColor : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? lang.color : AppColors.divider,
                        width: isSelected ? 2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: lang.color.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: lang.bgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('🇳🇬', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(lang.name, style: AppTextStyles.headlineSmall),
                              Text(lang.subtitle, style: AppTextStyles.bodySmall),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: lang.bgColor,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  lang.speakers,
                                  style: AppTextStyles.labelSmall.copyWith(color: lang.color),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: lang.color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                          )
                        else
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.divider, width: 2),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 28),

              // Level Selection
              const Text("What's your current level?", style: AppTextStyles.headlineSmall),
              const SizedBox(height: 14),
              Row(
                children: _levels.map((lvl) {
                  final isSelected = _selectedLevel == lvl.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedLevel = lvl.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: _levels.last == lvl ? 0 : 10),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primarySurface : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.divider,
                            width: isSelected ? 2 : 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(lvl.icon, style: const TextStyle(fontSize: 26)),
                            const SizedBox(height: 6),
                            Text(
                              lvl.title,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(lvl.subtitle, style: AppTextStyles.labelSmall, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              AppButton(
                label: "Let's go! 🚀",
                onPressed: _handleFinish,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String name;
  final String subtitle;
  final String speakers;
  final Color color;
  final Color bgColor;
  const _LanguageOption({
    required this.code,
    required this.name,
    required this.subtitle,
    required this.speakers,
    required this.color,
    required this.bgColor,
  });
}

class _LevelOption {
  final String value;
  final String title;
  final String subtitle;
  final String icon;
  const _LevelOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
