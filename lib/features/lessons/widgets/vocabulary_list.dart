import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/lesson_model.dart';

class VocabularyList extends StatelessWidget {
  final List<VocabItemModel> vocabulary;

  const VocabularyList({
    super.key,
    required this.vocabulary,
  });

  @override
  Widget build(BuildContext context) {
    if (vocabulary.isEmpty) {
      return const Center(child: Text('No vocabulary available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: vocabulary.length,
      itemBuilder: (context, index) {
        final item = vocabulary[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.word, style: AppTextStyles.headlineSmall),
              const SizedBox(height: 4),
              Text(item.translation, style: AppTextStyles.bodyMedium),
              if (item.pronunciation.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  item.pronunciation,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (item.exampleSentence.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(item.exampleSentence, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text(
                  item.sentenceTranslation,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
