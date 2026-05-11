import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../progress/data/datasources/progress_remote_datasource.dart';

enum ActivityType { quiz, conversation, translation }

class PracticeActivity {
  final ActivityType type;
  final String title;
  final String subtitle;
  final String timeAgo;
  final DateTime timestamp;

  const PracticeActivity({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
    required this.timestamp,
  });

  String get emoji {
    switch (type) {
      case ActivityType.quiz:
        return '❓';
      case ActivityType.conversation:
        return '💬';
      case ActivityType.translation:
        return '🔤';
    }
  }
}

// Saves a conversation session to SharedPreferences when it ends
Future<void> saveConversationActivity({
  required String language,
  required String unitTitle,
  required int messageCount,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('practice_activity') ?? '[]';
    final list = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

    list.insert(0, {
      'type': 'conversation',
      'title': '$language Conversation',
      'subtitle': '$unitTitle · $messageCount messages',
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Keep only the last 20 activity entries
    final trimmed = list.take(20).toList();
    await prefs.setString('practice_activity', jsonEncode(trimmed));
  } catch (_) {}
}

// Saves a translation session to SharedPreferences
Future<void> saveTranslationActivity({
  required String fromLang,
  required String toLang,
  required int phraseCount,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('practice_activity') ?? '[]';
    final list = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

    list.insert(0, {
      'type': 'translation',
      'title': 'Translation',
      'subtitle': '$fromLang → $toLang · $phraseCount phrase${phraseCount == 1 ? '' : 's'}',
      'timestamp': DateTime.now().toIso8601String(),
    });

    final trimmed = list.take(20).toList();
    await prefs.setString('practice_activity', jsonEncode(trimmed));
  } catch (_) {}
}

String _formatTimeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return '${(diff.inDays / 7).floor()}w ago';
}

ActivityType _typeFromString(String s) {
  switch (s) {
    case 'conversation':
      return ActivityType.conversation;
    case 'translation':
      return ActivityType.translation;
    default:
      return ActivityType.quiz;
  }
}

enum PracticeActivityStatus { initial, loading, loaded, error }

class PracticeActivityState {
  final PracticeActivityStatus status;
  final List<PracticeActivity> activities;

  const PracticeActivityState({
    this.status = PracticeActivityStatus.initial,
    this.activities = const [],
  });

  PracticeActivityState copyWith({
    PracticeActivityStatus? status,
    List<PracticeActivity>? activities,
  }) =>
      PracticeActivityState(
        status: status ?? this.status,
        activities: activities ?? this.activities,
      );
}

class PracticeActivityNotifier extends StateNotifier<PracticeActivityState> {
  PracticeActivityNotifier() : super(const PracticeActivityState());

  final _progress = ProgressRemoteDataSource.instance;

  Future<void> load({required String userId, required String language}) async {
    state = state.copyWith(status: PracticeActivityStatus.loading);

    final activities = <PracticeActivity>[];

    // Load quiz activity from progress API
    try {
      final progress = await _progress.getProgress(
        userId: userId,
        language: language,
      );

      final recent = progress.completedSubtopics
        ..sort((a, b) {
          // No timestamp on SubtopicProgressModel — sort by score desc as proxy
          return b.score.compareTo(a.score);
        });

      for (final s in recent.take(3)) {
        activities.add(PracticeActivity(
          type: ActivityType.quiz,
          title: '${_capitalize(s.unit)} Quiz',
          subtitle: '${s.score}% · ${s.subtopicName}',
          timeAgo: 'Recent',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ));
      }
    } catch (_) {
      // Progress load failed — continue with local activity only
    }

    // Load conversation + translation activity from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('practice_activity') ?? '[]';
      final list = (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

      for (final entry in list) {
        final ts = DateTime.tryParse(entry['timestamp'] as String? ?? '') ??
            DateTime.now();
        activities.add(PracticeActivity(
          type: _typeFromString(entry['type'] as String? ?? ''),
          title: entry['title'] as String? ?? 'Practice session',
          subtitle: entry['subtitle'] as String? ?? '',
          timeAgo: _formatTimeAgo(ts),
          timestamp: ts,
        ));
      }
    } catch (_) {}

    // Sort all activities by timestamp descending
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (!mounted) return;
    state = state.copyWith(
      status: PracticeActivityStatus.loaded,
      activities: activities.take(5).toList(),
    );
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');

final practiceActivityProvider =
    StateNotifierProvider<PracticeActivityNotifier, PracticeActivityState>(
        (ref) => PracticeActivityNotifier());
