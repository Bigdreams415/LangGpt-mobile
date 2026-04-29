import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../presentation/providers/conversation_provider.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Row(
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser) ...[
                _Avatar(isUser: false),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.primary
                        : isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: message.isUser
                          ? const Radius.circular(18)
                          : const Radius.circular(6),
                      bottomRight: message.isUser
                          ? const Radius.circular(6)
                          : const Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: message.isUser
                              ? Colors.white
                              : isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                          height: 1.55,
                        ),
                      ),
                      // Translation for AI messages
                      if (!message.isUser &&
                          message.translation != null &&
                          message.translation!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.primaryDark.withValues(alpha: 0.3)
                                : AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Translation',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                message.translation!,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Corrections
                      if (!message.isUser &&
                          message.corrections != null &&
                          message.corrections!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded,
                                size: 14, color: AppColors.accentYellow),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                message.corrections!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFFB8860B),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 10),
                _Avatar(isUser: true),
              ],
            ],
          ),
          // Vocabulary chips
          if (!message.isUser && message.vocabularyUsed.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: message.isUser ? 0 : 46),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: message.vocabularyUsed.map((word) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.accentBlueSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.accentBlue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      word,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.accentBlue,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final bool isUser;
  const _Avatar({required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: isUser ? AppColors.primaryGradient : AppColors.terracottaGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Icon(
          isUser ? Icons.person_rounded : Icons.smart_toy_rounded,
          size: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
