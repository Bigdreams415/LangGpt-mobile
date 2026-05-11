import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../presentation/providers/explore_provider.dart';

Future<void> showLanguageMismatchDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String browseLanguage,
  required String registeredLanguage,
  VoidCallback? onSwitched,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LanguageMismatchSheet(
      browseLanguage: browseLanguage,
      registeredLanguage: registeredLanguage,
      ref: ref,
      onSwitched: onSwitched,
    ),
  );
}

class _LanguageMismatchSheet extends StatefulWidget {
  final String browseLanguage;
  final String registeredLanguage;
  final WidgetRef ref;
  final VoidCallback? onSwitched;

  const _LanguageMismatchSheet({
    required this.browseLanguage,
    required this.registeredLanguage,
    required this.ref,
    this.onSwitched,
  });

  @override
  State<_LanguageMismatchSheet> createState() => _LanguageMismatchSheetState();
}

class _LanguageMismatchSheetState extends State<_LanguageMismatchSheet> {
  bool _switching = false;

  String _flag(String language) {
    switch (language.toLowerCase()) {
      case 'igbo':
      case 'yoruba':
      case 'hausa':
        return '🇳🇬';
      default:
        return '🌍';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accentBlueSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text('🌍', style: TextStyle(fontSize: 34)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Exploring ${widget.browseLanguage}',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              children: [
                const TextSpan(text: "You're currently registered as an "),
                TextSpan(
                  text: widget.registeredLanguage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                    text:
                        ' learner. Your XP and progress only track in your registered language.\n\nWant to switch to '),
                TextSpan(
                  text: widget.browseLanguage,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _switching ? null : _switchLanguage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _switching
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_flag(widget.browseLanguage),
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'Switch to ${widget.browseLanguage}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Keep learning ${widget.registeredLanguage}',
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchLanguage() async {
    setState(() => _switching = true);
    try {
      await widget.ref
          .read(authProvider.notifier)
          .switchLanguage(widget.browseLanguage);

      // Reset explore progress to load for the new language
      widget.ref.read(exploreSelectedLanguageProvider.notifier).state =
          widget.browseLanguage;

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSwitched?.call();
    } catch (_) {
      if (!mounted) return;
      setState(() => _switching = false);
    }
  }
}
