import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/translation_model.dart';
import '../presentation/providers/translation_provider.dart';

const _allLanguages = ['English', 'Igbo', 'Yoruba', 'Hausa'];
const _targetLanguages = ['Igbo', 'Yoruba', 'Hausa'];
const _langFlags = {
  'English': '🇬🇧',
  'Igbo': '🇳🇬',
  'Yoruba': '🇳🇬',
  'Hausa': '🇳🇬',
};

class TranslationScreen extends ConsumerStatefulWidget {
  const TranslationScreen({super.key});

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleTranslate() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    ref.read(translationProvider.notifier).setInputText(text);
    ref.read(translationProvider.notifier).translate();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSwap = state.fromLanguage != 'English';

    // Sync text controller with state when history entry is selected
    ref.listen(translationProvider, (prev, next) {
      if (next.inputText != prev?.inputText &&
          _textController.text != next.inputText) {
        _textController.text = next.inputText;
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Translate'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              children: [
                // Language selector
                _LanguageSelector(
                  fromLanguage: state.fromLanguage,
                  toLanguage: state.toLanguage,
                  canSwap: canSwap,
                  onFromChanged: (lang) =>
                      ref.read(translationProvider.notifier).setFromLanguage(lang),
                  onToChanged: (lang) =>
                      ref.read(translationProvider.notifier).setToLanguage(lang),
                  onSwap: canSwap
                      ? () => ref.read(translationProvider.notifier).swapLanguages()
                      : null,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                // Text input
                _TextInputCard(
                  controller: _textController,
                  language: state.fromLanguage,
                  isDark: isDark,
                  onTranslate: _handleTranslate,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 16),

                // Translate button
                AppButton(
                  label: 'Translate',
                  isLoading: state.isLoading,
                  onPressed: _handleTranslate,
                ),
                const SizedBox(height: 16),

                // Error banner
                if (state.error != null)
                  _ErrorBanner(
                    message: state.error!,
                    onDismiss: () =>
                        ref.read(translationProvider.notifier).clearError(),
                  ),
                if (state.error != null) const SizedBox(height: 16),

                // Result card
                if (state.result != null) ...[
                  _ResultCard(
                    response: state.result!,
                    fromLanguage: state.fromLanguage,
                    toLanguage: state.toLanguage,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                ],

                // History
                if (state.history.isNotEmpty) ...[
                  Text(
                    'Recent translations',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  ...state.history.map(
                    (entry) => _HistoryItem(
                      entry: entry,
                      isDark: isDark,
                      onTap: () => ref
                          .read(translationProvider.notifier)
                          .selectHistoryEntry(entry),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
              ],
            ),
          ),

          // Keyboard / bottom
          if (state.isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isDark ? AppColors.darkSurface : AppColors.primarySurface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Translating...',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---- Language Selector ----

class _LanguageSelector extends StatelessWidget {
  final String fromLanguage;
  final String toLanguage;
  final bool canSwap;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;
  final VoidCallback? onSwap;
  final bool isDark;

  const _LanguageSelector({
    required this.fromLanguage,
    required this.toLanguage,
    required this.canSwap,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onSwap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LangChip(
            label: 'From',
            language: fromLanguage,
            languages: _allLanguages,
            onChanged: onFromChanged,
            isDark: isDark,
          ),
        ),
        GestureDetector(
          onTap: onSwap,
          child: AnimatedRotation(
            turns: 0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: canSwap
                    ? (isDark ? AppColors.darkSurfaceVariant : AppColors.primarySurface)
                    : (isDark ? AppColors.darkSurface : AppColors.surfaceVariant),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.swap_horiz_rounded,
                size: 20,
                color: canSwap
                    ? AppColors.primary
                    : (isDark ? AppColors.textHintDark : AppColors.textHint),
              ),
            ),
          ),
        ),
        Expanded(
          child: _LangChip(
            label: 'To',
            language: toLanguage,
            languages: _targetLanguages,
            onChanged: onToChanged,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final String language;
  final List<String> languages;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _LangChip({
    required this.label,
    required this.language,
    required this.languages,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _langFlags[language] ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  language,
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 18,
                  color: isDark ? AppColors.textHintDark : AppColors.textHint,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Select language', style: AppTextStyles.headlineMedium),
              const SizedBox(height: 12),
              ...languages.map((lang) {
                final isSelected = lang == language;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      onChanged(lang);
                      Navigator.pop(ctx);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Text(
                            _langFlags[lang] ?? '',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lang,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected ? AppColors.primary : null,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

// ---- Text Input Card ----

class _TextInputCard extends StatelessWidget {
  final TextEditingController controller;
  final String language;
  final bool isDark;
  final VoidCallback onTranslate;
  final bool isLoading;

  const _TextInputCard({
    required this.controller,
    required this.language,
    required this.isDark,
    required this.onTranslate,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: !isLoading,
        maxLines: 6,
        minLines: 4,
        textInputAction: TextInputAction.newline,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          height: 1.6,
        ),
        decoration: InputDecoration(
          hintText: 'Enter text to translate from $language...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.textHintDark : AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        onSubmitted: (_) => onTranslate(),
      ),
    );
  }
}

// ---- Result Card ----

class _ResultCard extends StatelessWidget {
  final TranslationResponseModel response;
  final String fromLanguage;
  final String toLanguage;
  final bool isDark;

  const _ResultCard({
    required this.response,
    required this.fromLanguage,
    required this.toLanguage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkDivider : AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$fromLanguage → $toLanguage',
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Original text
          _ResultSection(
            label: 'Original',
            content: response.original,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Translation
          _ResultSection(
            label: 'Translation',
            content: response.translation,
            highlight: true,
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Pronunciation
          if (response.pronunciation.isNotEmpty) ...[
            _ResultSection(
              label: 'Pronunciation',
              content: response.pronunciation,
              isDark: isDark,
            ),
            const SizedBox(height: 14),
          ],

          // Breakdown
          if (response.breakdown != null &&
              response.breakdown!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.accentBlue.withValues(alpha: 0.12)
                    : AppColors.accentBlueSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Word breakdown',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accentBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    response.breakdown!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final String label;
  final String content;
  final bool highlight;
  final bool isDark;

  const _ResultSection({
    required this.label,
    required this.content,
    this.highlight = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: highlight
                ? AppColors.primary
                : (isDark ? AppColors.textHintDark : AppColors.textHint),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: (highlight ? AppTextStyles.headlineSmall : AppTextStyles.bodyLarge)
              .copyWith(
            color: highlight
                ? AppColors.primary
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

// ---- History Item ----

class _HistoryItem extends StatelessWidget {
  final TranslationHistoryEntry entry;
  final bool isDark;
  final VoidCallback onTap;

  const _HistoryItem({
    required this.entry,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.request.text,
                        style: AppTextStyles.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.request.fromLanguage} → ${entry.request.toLanguage}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textHintDark
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  entry.response.translation,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Error Banner ----

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondarySurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close_rounded,
                size: 16, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

// ---- App Button (inline, same as shared one) ----

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
