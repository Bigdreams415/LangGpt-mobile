import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_preferences_model.dart';
import '../../data/repositories/notifications_repository_impl.dart';

class NotificationPreferencesState {
  final NotificationPreferencesModel? prefs;
  final bool loading;
  final String? error;

  const NotificationPreferencesState({
    this.prefs,
    this.loading = false,
    this.error,
  });

  NotificationPreferencesState copyWith({
    NotificationPreferencesModel? prefs,
    bool? loading,
    String? error,
  }) {
    return NotificationPreferencesState(
      prefs: prefs ?? this.prefs,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferencesState> {
  NotificationPreferencesNotifier()
      : super(const NotificationPreferencesState());

  final _repo = NotificationsRepositoryImpl.instance;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final prefs = await _repo.getPreferences();
      state = NotificationPreferencesState(prefs: prefs);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  // Optimistically toggles a single preference field by its snake_case key name.
  Future<void> toggle(String fieldKey, bool value) async {
    final snapshot = state.prefs;
    if (snapshot == null) return;

    final updated = _applyField(snapshot, fieldKey, value);
    state = state.copyWith(prefs: updated, error: null);

    try {
      final result = await _repo.updatePreferences({fieldKey: value});
      state = state.copyWith(prefs: result);
    } catch (e) {
      // Roll back to the snapshot.
      state = state.copyWith(prefs: snapshot, error: e.toString());
    }
  }

  NotificationPreferencesModel _applyField(
    NotificationPreferencesModel prefs,
    String field,
    bool value,
  ) {
    switch (field) {
      case 'push_enabled':
        return prefs.copyWith(pushEnabled: value);
      case 'daily_reminders':
        return prefs.copyWith(dailyReminders: value);
      case 'streak_reminders':
        return prefs.copyWith(streakReminders: value);
      case 'lesson_updates':
        return prefs.copyWith(lessonUpdates: value);
      case 'achievements':
        return prefs.copyWith(achievements: value);
      case 'new_content':
        return prefs.copyWith(newContent: value);
      case 'marketing':
        return prefs.copyWith(marketing: value);
      default:
        return prefs;
    }
  }
}

final notificationPreferencesProvider = StateNotifierProvider.autoDispose<
    NotificationPreferencesNotifier, NotificationPreferencesState>(
  (ref) => NotificationPreferencesNotifier(),
);
