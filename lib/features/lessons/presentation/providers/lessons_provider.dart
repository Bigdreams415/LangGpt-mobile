import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/lesson_model.dart';
import '../../data/repositories/lessons_repository_impl.dart';

// ─── Lessons List State ─────────────────────────────────────────────────────

enum LessonsListStatus { initial, loading, loaded, error }

class LessonsListState {
  final LessonsListStatus status;
  final LessonsListResponseModel? lessonsList;
  final String? errorMessage;

  const LessonsListState({
    required this.status,
    this.lessonsList,
    this.errorMessage,
  });

  const LessonsListState.initial()
      : status = LessonsListStatus.initial,
        lessonsList = null,
        errorMessage = null;

  LessonsListState copyWith({
    LessonsListStatus? status,
    LessonsListResponseModel? lessonsList,
    String? errorMessage,
  }) {
    return LessonsListState(
      status: status ?? this.status,
      lessonsList: lessonsList ?? this.lessonsList,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─── Lesson Detail State ────────────────────────────────────────────────────

enum LessonDetailStatus { initial, loading, loaded, error }

class LessonDetailState {
  final LessonDetailStatus status;
  final LessonDetailModel? lesson;
  final String? errorMessage;

  const LessonDetailState({
    required this.status,
    this.lesson,
    this.errorMessage,
  });

  const LessonDetailState.initial()
      : status = LessonDetailStatus.initial,
        lesson = null,
        errorMessage = null;

  LessonDetailState copyWith({
    LessonDetailStatus? status,
    LessonDetailModel? lesson,
    String? errorMessage,
  }) {
    return LessonDetailState(
      status: status ?? this.status,
      lesson: lesson ?? this.lesson,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─── Lessons Notifier ───────────────────────────────────────────────────────

class LessonsNotifier extends StateNotifier<LessonsListState> {
  LessonsNotifier() : super(const LessonsListState.initial());

  final _repo = LessonsRepositoryImpl.instance;

  Future<void> loadLessonsList({
    required String language,
    String? level,
  }) async {
    if (state.status == LessonsListStatus.loaded) return;

    state = state.copyWith(status: LessonsListStatus.loading, errorMessage: null);

    try {
      final lessonsList = await _repo.getLessonsList(
        language: language,
        level: level,
      );
      state = LessonsListState(
        status: LessonsListStatus.loaded,
        lessonsList: lessonsList,
      );
    } catch (e) {
      state = state.copyWith(
        status: LessonsListStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshLessonsList({
    required String language,
    String? level,
  }) async {
    state = state.copyWith(status: LessonsListStatus.loading, errorMessage: null);

    try {
      final lessonsList = await _repo.getLessonsList(
        language: language,
        level: level,
      );
      state = LessonsListState(
        status: LessonsListStatus.loaded,
        lessonsList: lessonsList,
      );
    } catch (e) {
      state = state.copyWith(
        status: LessonsListStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// ─── Lesson Detail Notifier ─────────────────────────────────────────────────

class LessonDetailNotifier extends StateNotifier<LessonDetailState> {
  LessonDetailNotifier() : super(const LessonDetailState.initial());

  final _repo = LessonsRepositoryImpl.instance;

  Future<void> loadLessonDetail({
    required String language,
    required String topicId,
  }) async {
    state = state.copyWith(status: LessonDetailStatus.loading, errorMessage: null);

    try {
      final lesson = await _repo.getLessonDetail(
        language: language,
        topicId: topicId,
      );
      state = LessonDetailState(
        status: LessonDetailStatus.loaded,
        lesson: lesson,
      );
    } catch (e) {
      state = state.copyWith(
        status: LessonDetailStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const LessonDetailState.initial();
  }
}

// ─── Providers ──────────────────────────────────────────────────────────────

final lessonsListProvider = StateNotifierProvider<LessonsNotifier, LessonsListState>((ref) {
  return LessonsNotifier();
});

final lessonDetailProvider = StateNotifierProvider<LessonDetailNotifier, LessonDetailState>((ref) {
  return LessonDetailNotifier();
});