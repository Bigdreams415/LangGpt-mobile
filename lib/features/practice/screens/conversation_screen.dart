import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../presentation/providers/conversation_provider.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final ConversationContext context;

  const ConversationScreen({super.key, required this.context});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(conversationProvider.notifier).initContext(widget.context);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    ref.read(conversationProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ctx = widget.context;

    // Scroll to bottom when new messages arrive
    ref.listen(conversationProvider, (prev, next) {
      if (next.messages.length > (prev?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Tutor',
              style: AppTextStyles.headlineSmall,
            ),
            Text(
              '${ctx.language} · ${ctx.unitTitle}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showContextInfo(context, ctx, isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: state.messages.isEmpty
                ? _EmptyChatState(
                    unitTitle: ctx.unitTitle,
                    language: ctx.language,
                    level: ctx.level,
                    onSuggestionTap: (text) {
                      _handleSend(text);
                    },
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: state.messages.length +
                        (state.isLoading ? 1 : 0) +
                        (state.error != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Error banner
                      if (state.error != null && index == 0) {
                        return _ErrorBanner(
                          message: state.error!,
                          onDismiss: () =>
                              ref.read(conversationProvider.notifier).clearError(),
                        );
                      }

                      final adjustedIndex =
                          state.error != null ? index - 1 : index;

                      if (adjustedIndex < state.messages.length) {
                        return ChatMessageBubble(
                          message: state.messages[adjustedIndex],
                        );
                      }

                      // Typing indicator
                      return const _TypingIndicator();
                    },
                  ),
          ),
          // Input bar
          ChatInputBar(
            onSend: (text) => _handleSend(text),
            isLoading: state.isLoading,
          ),
        ],
      ),
    );
  }

  void _showContextInfo(
    BuildContext context,
    ConversationContext ctx,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
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
              const SizedBox(height: 20),
              Text('Conversation Context',
                  style: AppTextStyles.headlineMedium),
              const SizedBox(height: 16),
              _ContextRow(
                  label: 'Language', value: ctx.language, isDark: isDark),
              _ContextRow(label: 'Level', value: ctx.level, isDark: isDark),
              _ContextRow(
                  label: 'Unit', value: ctx.unitTitle, isDark: isDark),
              if (ctx.subtopicName != null)
                _ContextRow(
                    label: 'Subtopic',
                    value: ctx.subtopicName!,
                    isDark: isDark),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    ref.read(conversationProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                  child: const Text('Start new conversation',
                      style: TextStyle(color: AppColors.secondary)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ---- Empty Chat State ----

class _EmptyChatState extends StatelessWidget {
  final String unitTitle;
  final String language;
  final String level;
  final ValueChanged<String> onSuggestionTap;

  const _EmptyChatState({
    required this.unitTitle,
    required this.language,
    required this.level,
    required this.onSuggestionTap,
  });

  List<String> get _suggestions {
    final suggestions = <String>[
      'Hello! How do I greet someone in $language?',
      'Can you teach me some common $language phrases?',
      'How do I introduce myself in $language?',
    ];

    if (level == 'beginner') {
      return suggestions;
    } else if (level == 'intermediate') {
      return [
        'Let\'s have a conversation in $language about daily routines.',
        'How do I express opinions in $language?',
        'Can we practice $language past tense?',
      ];
    } else {
      return [
        'Let\'s discuss Nigerian culture in $language.',
        'What are some $language proverbs and their meanings?',
        'Can we debate a topic in $language?',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      children: [
        // Welcome illustration area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.primarySurface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chat with your AI Tutor',
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Practice $language in a natural conversation.\nYour tutor will correct your mistakes and help you improve.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$language · $level · $unitTitle',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Try asking...',
          style: AppTextStyles.labelLarge.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ..._suggestions.map(
          (suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onSuggestionTap(suggestion),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.textHintDark
                              : AppColors.textHint),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---- Context Row ----

class _ContextRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _ContextRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textHintDark : AppColors.textHint,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Typing Indicator ----

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: AppColors.terracottaGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                const SizedBox(width: 4),
                _Dot(delay: 200),
                const SizedBox(width: 4),
                _Dot(delay: 400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.textHint,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
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
      margin: const EdgeInsets.only(bottom: 12),
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
