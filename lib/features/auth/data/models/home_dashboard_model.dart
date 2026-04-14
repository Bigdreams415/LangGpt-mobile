class DailyGoalModel {
  final int completed;
  final int target;
  final double percentage;

  const DailyGoalModel({
    required this.completed,
    required this.target,
    required this.percentage,
  });

  factory DailyGoalModel.fromJson(Map<String, dynamic> json) {
    return DailyGoalModel(
      completed: json['completed'] as int,
      target: json['target'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}

class ContinueLessonModel {
  final String topic;
  final String title;
  final String language;
  final String level;
  final double progressPercentage;
  final String emoji;

  const ContinueLessonModel({
    required this.topic,
    required this.title,
    required this.language,
    required this.level,
    required this.progressPercentage,
    required this.emoji,
  });

  factory ContinueLessonModel.fromJson(Map<String, dynamic> json) {
    return ContinueLessonModel(
      topic: json['topic'] as String,
      title: json['title'] as String,
      language: json['language'] as String,
      level: json['level'] as String,
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
      emoji: json['emoji'] as String,
    );
  }
}

class StatCardModel {
  final int lessonsCompleted;
  final double quizAccuracy;
  final int totalXp;

  const StatCardModel({
    required this.lessonsCompleted,
    required this.quizAccuracy,
    required this.totalXp,
  });

  factory StatCardModel.fromJson(Map<String, dynamic> json) {
    return StatCardModel(
      lessonsCompleted: json['lessons_completed'] as int,
      quizAccuracy: (json['quiz_accuracy'] as num).toDouble(),
      totalXp: json['total_xp'] as int,
    );
  }
}

class TodayLessonModel {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final bool isCompleted;

  const TodayLessonModel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.isCompleted,
  });

  factory TodayLessonModel.fromJson(Map<String, dynamic> json) {
    return TodayLessonModel(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      durationMinutes: json['duration_minutes'] as int,
      isCompleted: json['is_completed'] as bool,
    );
  }
}

class LeaderboardEntryModel {
  final int rank;
  final String name;
  final int xp;
  final String? medal;

  const LeaderboardEntryModel({
    required this.rank,
    required this.name,
    required this.xp,
    this.medal,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] as int,
      name: json['name'] as String,
      xp: json['xp'] as int,
      medal: json['medal'] as String?,
    );
  }
}

class HomeDashboardModel {
  final String userName;
  final int streak;
  final DailyGoalModel dailyGoal;
  final ContinueLessonModel? continueLearning;
  final StatCardModel stats;
  final List<TodayLessonModel> todayLessons;
  final List<LeaderboardEntryModel> leaderboard;

  const HomeDashboardModel({
    required this.userName,
    required this.streak,
    required this.dailyGoal,
    this.continueLearning,
    required this.stats,
    required this.todayLessons,
    required this.leaderboard,
  });

  factory HomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return HomeDashboardModel(
      userName: json['user_name'] as String,
      streak: json['streak'] as int,
      dailyGoal: DailyGoalModel.fromJson(json['daily_goal'] as Map<String, dynamic>),
      continueLearning: json['continue_learning'] != null
          ? ContinueLessonModel.fromJson(json['continue_learning'] as Map<String, dynamic>)
          : null,
      stats: StatCardModel.fromJson(json['stats'] as Map<String, dynamic>),
      todayLessons: (json['today_lessons'] as List)
          .map((e) => TodayLessonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      leaderboard: (json['leaderboard'] as List)
          .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}