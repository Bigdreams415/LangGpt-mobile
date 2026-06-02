import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/progress_remote_datasource.dart';
import '../../data/models/progress_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum ProgressStatus { initial, loading, loaded, error }

class ProgressState {
  final ProgressStatus status;
  final ProgressResponseModel? progress;
  final String? errorMessage;

  const ProgressState({
    required this.status,
    this.progress,
    this.errorMessage,
  });

  const ProgressState.initial()
      : status = ProgressStatus.initial,
        progress = null,
        errorMessage = null;

  ProgressState copyWith({
    ProgressStatus? status,
    ProgressResponseModel? progress,
    String? errorMessage,
  }) {
    return ProgressState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Shared, reactive source of truth for the user's learning progress.
// Screens watch this instead of fetching their own copy, so unlock state
// updates the instant a quiz is submitted.
class ProgressNotifier extends StateNotifier<ProgressState> {
  ProgressNotifier(this.ref) : super(const ProgressState.initial());

  final Ref ref;
  final _dataSource = ProgressRemoteDataSource.instance;

  Future<void> load({bool force = false}) async {
    if (!force && state.status == ProgressStatus.loaded) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = state.copyWith(status: ProgressStatus.loading, errorMessage: null);
    try {
      final progress = await _dataSource.getProgress(
        userId: user.id,
        language: user.selectedLanguage ?? 'Igbo',
      );
      if (!mounted) return;
      state = ProgressState(status: ProgressStatus.loaded, progress: progress);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: ProgressStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() => load(force: true);

  // Push a fresh snapshot returned by another call (e.g. right after a quiz
  // submit) so dependent screens reflect the new unlock state immediately.
  void setProgress(ProgressResponseModel progress) {
    state = ProgressState(status: ProgressStatus.loaded, progress: progress);
  }
}

final progressProvider =
    StateNotifierProvider<ProgressNotifier, ProgressState>((ref) {
  return ProgressNotifier(ref);
});

// Decide whether a unit may be opened. Prefers the backend's unlocked_units
// list; falls back to sequential unlocking (a unit opens once the previous one
// is completed) when an older backend doesn't send that field yet.
bool isUnitUnlocked({
  required String unitId,
  required int index,
  required List<String> orderedUnitIds,
  ProgressResponseModel? progress,
}) {
  if (progress == null) {
    return index == 0;
  }

  if (progress.unlockedUnits.isNotEmpty) {
    return progress.unlockedUnits.contains(unitId);
  }

  if (progress.completedUnits.contains(unitId)) return true;
  if (index <= 0) return true;

  final previousId = orderedUnitIds[index - 1];
  return progress.completedUnits.contains(previousId);
}
