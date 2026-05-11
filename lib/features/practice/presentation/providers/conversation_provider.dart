import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'translation': translation,
        'corrections': corrections,
        'vocabulary_used': vocabularyUsed,
        'is_user': isUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        content: json['content'] as String,
        translation: json['translation'] as String?,
        corrections: json['corrections'] as String?,
        vocabularyUsed: (json['vocabulary_used'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        isUser: json['is_user'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
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

  // Unique key for caching — different topics get separate histories
  String get cacheKey =>
      'chat_${language.toLowerCase()}_${unit}_$subtopicIndex';
}

class ConversationState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final ConversationContext? context;
  final bool hasCachedMessages;

  const ConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.context,
    this.hasCachedMessages = false,
  });

  ConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    ConversationContext? context,
    bool? hasCachedMessages,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      context: context ?? this.context,
      hasCachedMessages: hasCachedMessages ?? this.hasCachedMessages,
    );
  }

  // Build history to send to backend — last 20 messages only for token efficiency
  List<Map<String, String>> get conversationHistory =>
      messages.takeLast(20).map((m) => m.toHistoryEntry()).toList();
}

extension _TakeLast<T> on List<T> {
  List<T> takeLast(int n) => length <= n ? this : sublist(length - n);
}

class ConversationNotifier extends StateNotifier<ConversationState> {
  ConversationNotifier() : super(const ConversationState());

  final _repo = ConversationRepositoryImpl.instance;
  int _messageIdCounter = 0;
  static const int _maxCachedMessages = 50;

  String get _nextId => 'msg_${++_messageIdCounter}';

  Future<void> initContext(ConversationContext context) async {
    state = state.copyWith(context: context);
    await _restoreCache(context);
  }

  Future<void> _restoreCache(ConversationContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(context.cacheKey);
      if (raw == null) return;

      final list = jsonDecode(raw) as List<dynamic>;
      final messages = list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();

      if (messages.isNotEmpty) {
        _messageIdCounter = messages.length;
        state = state.copyWith(
          messages: messages,
          hasCachedMessages: true,
        );
      }
    } catch (_) {
      // Cache read failure is non-fatal — start fresh
    }
  }

  Future<void> _persistCache(List<ChatMessage> messages) async {
    final ctx = state.context;
    if (ctx == null) return;

    try {
      final toSave = messages.takeLast(_maxCachedMessages);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        ctx.cacheKey,
        jsonEncode(toSave.map((m) => m.toJson()).toList()),
      );
    } catch (_) {
      // Cache write failure is non-fatal
    }
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

    // Build history BEFORE adding the new user message — per backend contract.
    final history = state.conversationHistory;

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(
      messages: updatedMessages,
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
        conversationHistory: history,
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

      final finalMessages = [...updatedMessages, aiMessage];
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
      );

      await _persistCache(finalMessages);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Retry the last user message if the previous request failed
  Future<void> retryLastMessage() async {
    final lastUser = state.messages
        .where((m) => m.isUser)
        .lastOrNull;
    if (lastUser == null) return;

    // Remove all messages after the last user message
    final index = state.messages.lastIndexOf(lastUser);
    final trimmed = state.messages.sublist(0, index);
    state = state.copyWith(messages: trimmed, error: null);

    await sendMessage(lastUser.content);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> clearCache() async {
    final ctx = state.context;
    if (ctx == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(ctx.cacheKey);
    } catch (_) {}

    _messageIdCounter = 0;
    state = ConversationState(context: ctx);
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
