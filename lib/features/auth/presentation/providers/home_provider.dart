import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/home_dashboard_model.dart';
import '../../data/repositories/home_repository_impl.dart';

// Home State 

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final HomeDashboardModel? dashboard;
  final String? errorMessage;

  const HomeState({
    required this.status,
    this.dashboard,
    this.errorMessage,
  });

  const HomeState.initial()
      : status = HomeStatus.initial,
        dashboard = null,
        errorMessage = null;

  HomeState copyWith({
    HomeStatus? status,
    HomeDashboardModel? dashboard,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Home Notifier
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState.initial());

  final _repo = HomeRepositoryImpl.instance;

  /// Load home dashboard data
  Future<void> loadDashboard() async {
    // Don't reload if already loaded successfully
    if (state.status == HomeStatus.loaded) return;

    state = state.copyWith(status: HomeStatus.loading, errorMessage: null);
    
    try {
      final dashboard = await _repo.getHomeDashboard();
      state = HomeState(
        status: HomeStatus.loaded,
        dashboard: dashboard,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh data (force reload even if already loaded)
  Future<void> refreshDashboard() async {
    state = state.copyWith(status: HomeStatus.loading, errorMessage: null);
    
    try {
      final dashboard = await _repo.getHomeDashboard();
      state = HomeState(
        status: HomeStatus.loaded,
        dashboard: dashboard,
      );
    } catch (e) {
      state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

// Providers 

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

// Convenience providers for specific pieces of data
final homeDashboardProvider = Provider<HomeDashboardModel?>((ref) {
  return ref.watch(homeProvider).dashboard;
});

final homeStatusProvider = Provider<HomeStatus>((ref) {
  return ref.watch(homeProvider).status;
});

final homeErrorProvider = Provider<String?>((ref) {
  return ref.watch(homeProvider).errorMessage;
});