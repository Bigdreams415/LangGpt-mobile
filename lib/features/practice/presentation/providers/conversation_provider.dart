import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/conversation_repository_impl.dart';

class ChatMessage {
  final String id;
  final String content;
  final String? translation;
  final String? corrections;
  final List<String> vocabularyUsed;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.content,
    this.translation,
    this.corrections,
    this.vocabularyUsed = const [],
    required this.isUser,
    required this.timestamp,
  });

  Map<String, String> toHistoryEntry() => {
        'role': isUser ? 'user' : 'assistant',
        'content': content,
      };
}

class ConversationContext {
  final String language;
  final String level;
  final String unit;
  final int subtopicIndex;
  final String? subtopicName;
  final String unitTitle;

  const ConversationContext({
    required this.language,
    required this.level,
    required this.unit,
    required this.subtopicIndex,
    this.subtopicName,
    required this.unitTitle,
  });
}

class ConversationState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final ConversationContext? context;

  const ConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.context,
  });

  ConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    ConversationContext? context,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      context: context ?? this.context,
    );
  }

  List<Map<String, String>> get conversationHistory =>
      messages.map((m) => m.toHistoryEntry()).toList();
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  ConversationNotifier() : super(const ConversationState());

  final _repo = ConversationRepositoryImpl.instance;
  int _messageIdCounter = 0;

  String get _nextId => 'msg_${++_messageIdCounter}';

  void initContext(ConversationContext context) {
    state = state.copyWith(context: context);
  }

  Future<void> sendMessage(String text) async {
    final ctx = state.context;
    if (ctx == null || text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _nextId,
      content: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      final request = ConversationRequestModel(
        language: ctx.language,
        level: ctx.level,
        unit: ctx.unit,
        subtopicIndex: ctx.subtopicIndex,
        subtopicName: ctx.subtopicName,
        userMessage: text.trim(),
        conversationHistory: state.conversationHistory,
      );

      final response = await _repo.sendMessage(request);

      final aiMessage = ChatMessage(
        id: _nextId,
        content: response.reply,
        translation: response.translation,
        corrections: response.corrections,
        vocabularyUsed: response.vocabularyUsed,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    _messageIdCounter = 0;
    state = const ConversationState();
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier();
});
