import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../presentation/providers/conversation_provider.dart';

class ChatMessageBubble extends StatefulWidget {
  final ChatMessage message;
  const ChatMessageBubble({super.key, required this.message});

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  bool _correctionsExpanded = false;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final msg = widget.message;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!msg.isUser) ...[
                const _Avatar(isUser: false),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: _copyToClipboard,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? AppColors.primary
                          : isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: msg.isUser
                            ? const Radius.circular(18)
                            : const Radius.circular(6),
                        bottomRight: msg.isUser
                            ? const Radius.circular(6)
                            : const Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.content,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: msg.isUser
                                ? Colors.white
                                : isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                            height: 1.55,
                          ),
                        ),
                        // Translation for AI messages
                        if (!msg.isUser &&
                            msg.translation != null &&
                            msg.translation!.isNotEmpty) ...[
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
                                  style: AppTextStyles.labelSmall
                                      .copyWith(color: AppColors.primaryLight),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg.translation!,
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
                        // Corrections — collapsed chip, expand on tap
                        if (!msg.isUser &&
                            msg.corrections != null &&
                            msg.corrections!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(
                                () => _correctionsExpanded = !_correctionsExpanded),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accentYellow
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 14,
                                    color: AppColors.accentYellow,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Correction',
                                    style: AppTextStyles.labelSmall.copyWith(
                                        color: const Color(0xFFB8860B)),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    _correctionsExpanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    size: 14,
                                    color: const Color(0xFFB8860B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_correctionsExpanded) ...[
                            const SizedBox(height: 6),
                            Text(
                              msg.corrections!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFFB8860B),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (msg.isUser) ...[
                const SizedBox(width: 10),
                const _Avatar(isUser: true),
              ],
            ],
          ),
          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: msg.isUser ? 0 : 44,
              right: msg.isUser ? 44 : 0,
            ),
            child: Text(
              _formatMsgTime(msg.timestamp),
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
                fontSize: 10,
              ),
            ),
          ),
          // Vocabulary chips
          if (!msg.isUser && msg.vocabularyUsed.isNotEmpty) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: msg.vocabularyUsed.map((word) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
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

String _formatMsgTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  return '${diff.inDays}d ago';
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
        gradient: isUser
            ? AppColors.primaryGradient
            : AppColors.terracottaGradient,
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
