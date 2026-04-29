import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String>? onSend;
  final bool isLoading;
  const ChatInputBar({super.key, this.onSend, this.isLoading = false});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isLoading) return;
    widget.onSend?.call(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canSend = _hasText && !widget.isLoading;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkDivider : AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? AppColors.darkDivider : AppColors.divider,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: !widget.isLoading,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.textHintDark : AppColors.textHint,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: canSend ? _handleSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: canSend ? AppColors.primaryGradient : null,
                  color: canSend
                      ? null
                      : isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: canSend
                              ? Colors.white
                              : isDark
                                  ? AppColors.textHintDark
                                  : AppColors.textHint,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
