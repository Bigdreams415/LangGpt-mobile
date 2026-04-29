import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/translation_model.dart';
import '../../data/repositories/translation_repository_impl.dart';

class TranslationHistoryEntry {
  final TranslationRequestModel request;
  final TranslationResponseModel response;
  final DateTime timestamp;

  const TranslationHistoryEntry({
    required this.request,
    required this.response,
    required this.timestamp,
  });
}

class TranslationState {
  final String fromLanguage;
  final String toLanguage;
  final String inputText;
  final TranslationResponseModel? result;
  final bool isLoading;
  final String? error;
  final List<TranslationHistoryEntry> history;

  const TranslationState({
    this.fromLanguage = 'English',
    this.toLanguage = 'Igbo',
    this.inputText = '',
    this.result,
    this.isLoading = false,
    this.error,
    this.history = const [],
  });

  TranslationState copyWith({
    String? fromLanguage,
    String? toLanguage,
    String? inputText,
    TranslationResponseModel? result,
    bool? isLoading,
    String? error,
    List<TranslationHistoryEntry>? history,
  }) {
    return TranslationState(
      fromLanguage: fromLanguage ?? this.fromLanguage,
      toLanguage: toLanguage ?? this.toLanguage,
      inputText: inputText ?? this.inputText,
      result: result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      history: history ?? this.history,
    );
  }
}

class TranslationNotifier extends StateNotifier<TranslationState> {
  TranslationNotifier() : super(const TranslationState());

  final _repo = TranslationRepositoryImpl.instance;

  void setFromLanguage(String lang) {
    state = state.copyWith(fromLanguage: lang, result: null, error: null);
  }

  void setToLanguage(String lang) {
    state = state.copyWith(toLanguage: lang, result: null, error: null);
  }

  void swapLanguages() {
    // Only swap if both are supported languages (not English-to-English, etc.)
    final from = state.fromLanguage;
    final to = state.toLanguage;
    if (from == to) return;
    state = state.copyWith(
      fromLanguage: to,
      toLanguage: from,
      result: null,
      error: null,
    );
  }

  void setInputText(String text) {
    state = state.copyWith(inputText: text, error: null);
  }

  void selectHistoryEntry(TranslationHistoryEntry entry) {
    state = state.copyWith(
      fromLanguage: entry.request.fromLanguage,
      toLanguage: entry.request.toLanguage,
      inputText: entry.request.text,
      result: entry.response,
      error: null,
    );
  }

  Future<void> translate() async {
    final text = state.inputText.trim();
    if (text.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = TranslationRequestModel(
        text: text,
        fromLanguage: state.fromLanguage,
        toLanguage: state.toLanguage,
      );

      final response = await _repo.translate(request);

      final entry = TranslationHistoryEntry(
        request: request,
        response: response,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        result: response,
        isLoading: false,
        history: [entry, ...state.history].take(20).toList(),
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
}

final translationProvider =
    StateNotifierProvider<TranslationNotifier, TranslationState>((ref) {
  return TranslationNotifier();
});
