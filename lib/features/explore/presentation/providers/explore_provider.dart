import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../lessons/data/models/lesson_model.dart';
import '../../../progress/data/models/progress_model.dart';
import '../../data/repositories/explore_repository_impl.dart';

// ── Selected language ────────────────────────────────────────────────────────

final exploreSelectedLanguageProvider = StateProvider<String>((ref) => 'Igbo');

// ── Units list ───────────────────────────────────────────────────────────────

enum ExploreUnitsStatus { initial, loading, loaded, error }

class ExploreUnitsState {
  final ExploreUnitsStatus status;
  final LessonsListResponseModel? data;
  final String? errorMessage;

  const ExploreUnitsState({
    required this.status,
    this.data,
    this.errorMessage,
  });

  const ExploreUnitsState.initial()
      : status = ExploreUnitsStatus.initial,
        data = null,
        errorMessage = null;

  ExploreUnitsState copyWith({
    ExploreUnitsStatus? status,
    LessonsListResponseModel? data,
    String? errorMessage,
  }) =>
      ExploreUnitsState(
        status: status ?? this.status,
        data: data ?? this.data,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class ExploreUnitsNotifier extends StateNotifier<ExploreUnitsState> {
  ExploreUnitsNotifier() : super(const ExploreUnitsState.initial());

  final _repo = ExploreRepositoryImpl.instance;
  String? _loadedLanguage;

  Future<void> loadUnits(String language) async {
    if (_loadedLanguage == language &&
        state.status == ExploreUnitsStatus.loaded) {
      return;
    }

    state = state.copyWith(status: ExploreUnitsStatus.loading, errorMessage: null);

    try {
      final data = await _repo.getUnits(language: language);
      if (!mounted) return;
      _loadedLanguage = language;
      state = ExploreUnitsState(status: ExploreUnitsStatus.loaded, data: data);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: ExploreUnitsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> reload(String language) async {
    _loadedLanguage = null;
    await loadUnits(language);
  }
}

final exploreUnitsProvider =
    StateNotifierProvider<ExploreUnitsNotifier, ExploreUnitsState>(
        (ref) => ExploreUnitsNotifier());

// ── Progress ─────────────────────────────────────────────────────────────────

enum ExploreProgressStatus { initial, loading, loaded, error }

class ExploreProgressState {
  final ExploreProgressStatus status;
  final ProgressResponseModel? data;
  final String? errorMessage;

  const ExploreProgressState({
    required this.status,
    this.data,
    this.errorMessage,
  });

  const ExploreProgressState.initial()
      : status = ExploreProgressStatus.initial,
        data = null,
        errorMessage = null;

  ExploreProgressState copyWith({
    ExploreProgressStatus? status,
    ProgressResponseModel? data,
    String? errorMessage,
  }) =>
      ExploreProgressState(
        status: status ?? this.status,
        data: data ?? this.data,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class ExploreProgressNotifier extends StateNotifier<ExploreProgressState> {
  ExploreProgressNotifier() : super(const ExploreProgressState.initial());

  final _repo = ExploreRepositoryImpl.instance;

  Future<void> loadProgress({
    required String userId,
    required String language,
  }) async {
    state = state.copyWith(
        status: ExploreProgressStatus.loading, errorMessage: null);

    try {
      final data = await _repo.getUserProgress(
          userId: userId, language: language);
      if (!mounted) return;
      state = ExploreProgressState(
          status: ExploreProgressStatus.loaded, data: data);
    } catch (_) {
      // Progress is non-critical — fail silently so the unit list still shows
      if (!mounted) return;
      state = state.copyWith(status: ExploreProgressStatus.error);
    }
  }
}

final exploreProgressProvider =
    StateNotifierProvider<ExploreProgressNotifier, ExploreProgressState>(
        (ref) => ExploreProgressNotifier());

// ── Unit detail ───────────────────────────────────────────────────────────────

enum ExploreUnitDetailStatus { initial, loading, loaded, error }

class ExploreUnitDetailState {
  final ExploreUnitDetailStatus status;
  final LessonDetailModel? data;
  final String? errorMessage;

  const ExploreUnitDetailState({
    required this.status,
    this.data,
    this.errorMessage,
  });

  const ExploreUnitDetailState.initial()
      : status = ExploreUnitDetailStatus.initial,
        data = null,
        errorMessage = null;

  ExploreUnitDetailState copyWith({
    ExploreUnitDetailStatus? status,
    LessonDetailModel? data,
    String? errorMessage,
  }) =>
      ExploreUnitDetailState(
        status: status ?? this.status,
        data: data ?? this.data,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class ExploreUnitDetailNotifier
    extends StateNotifier<ExploreUnitDetailState> {
  ExploreUnitDetailNotifier() : super(const ExploreUnitDetailState.initial());

  final _repo = ExploreRepositoryImpl.instance;

  Future<void> loadUnitDetail({
    required String language,
    required String unitId,
  }) async {
    state = state.copyWith(
        status: ExploreUnitDetailStatus.loading, errorMessage: null);

    try {
      final data =
          await _repo.getUnitDetail(language: language, unitId: unitId);
      if (!mounted) return;
      state =
          ExploreUnitDetailState(status: ExploreUnitDetailStatus.loaded, data: data);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: ExploreUnitDetailStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final exploreUnitDetailProvider = AutoDisposeStateNotifierProvider<
    ExploreUnitDetailNotifier, ExploreUnitDetailState>(
  (ref) => ExploreUnitDetailNotifier(),
);
