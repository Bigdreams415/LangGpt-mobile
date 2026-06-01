class NotificationPreferencesModel {
  final bool pushEnabled;
  final bool dailyReminders;
  final bool streakReminders;
  final bool lessonUpdates;
  final bool achievements;
  final bool newContent;
  final bool marketing;

  const NotificationPreferencesModel({
    required this.pushEnabled,
    required this.dailyReminders,
    required this.streakReminders,
    required this.lessonUpdates,
    required this.achievements,
    required this.newContent,
    required this.marketing,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      pushEnabled: json['push_enabled'] as bool? ?? true,
      dailyReminders: json['daily_reminders'] as bool? ?? true,
      streakReminders: json['streak_reminders'] as bool? ?? true,
      lessonUpdates: json['lesson_updates'] as bool? ?? true,
      achievements: json['achievements'] as bool? ?? true,
      newContent: json['new_content'] as bool? ?? true,
      marketing: json['marketing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'push_enabled': pushEnabled,
    'daily_reminders': dailyReminders,
    'streak_reminders': streakReminders,
    'lesson_updates': lessonUpdates,
    'achievements': achievements,
    'new_content': newContent,
    'marketing': marketing,
  };

  // Returns a partial JSON with only the provided fields — used for PUT requests.
  static Map<String, dynamic> toJsonPartial({
    bool? pushEnabled,
    bool? dailyReminders,
    bool? streakReminders,
    bool? lessonUpdates,
    bool? achievements,
    bool? newContent,
    bool? marketing,
  }) {
    final map = <String, dynamic>{};
    if (pushEnabled != null) map['push_enabled'] = pushEnabled;
    if (dailyReminders != null) map['daily_reminders'] = dailyReminders;
    if (streakReminders != null) map['streak_reminders'] = streakReminders;
    if (lessonUpdates != null) map['lesson_updates'] = lessonUpdates;
    if (achievements != null) map['achievements'] = achievements;
    if (newContent != null) map['new_content'] = newContent;
    if (marketing != null) map['marketing'] = marketing;
    return map;
  }

  NotificationPreferencesModel copyWith({
    bool? pushEnabled,
    bool? dailyReminders,
    bool? streakReminders,
    bool? lessonUpdates,
    bool? achievements,
    bool? newContent,
    bool? marketing,
  }) {
    return NotificationPreferencesModel(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      streakReminders: streakReminders ?? this.streakReminders,
      lessonUpdates: lessonUpdates ?? this.lessonUpdates,
      achievements: achievements ?? this.achievements,
      newContent: newContent ?? this.newContent,
      marketing: marketing ?? this.marketing,
    );
  }
}
