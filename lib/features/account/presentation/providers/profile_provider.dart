import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../progress/data/datasources/progress_remote_datasource.dart';
import '../../../progress/data/models/progress_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileState {
  final bool isLoading;
  final ProgressResponseModel? progress;

  const ProfileState({
    this.isLoading = false,
    this.progress,
  });

  ProfileState copyWith({bool? isLoading, ProgressResponseModel? progress}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this.ref) : super(const ProfileState());

  final Ref ref;
  final _progressDataSource = ProgressRemoteDataSource.instance;

  Future<void> loadProgress() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final progress = await _progressDataSource.getProgress(
        userId: user.id,
        language: user.selectedLanguage ?? 'Igbo',
      );
      state = ProfileState(isLoading: false, progress: progress);
    } catch (_) {
      state = const ProfileState(isLoading: false);
    }
  }
}

final profileProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>((ref) {
  final notifier = ProfileNotifier(ref);
  notifier.loadProgress();
  return notifier;
});
