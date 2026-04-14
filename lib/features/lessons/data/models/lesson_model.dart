class LessonTopicModel {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final int durationMinutes;
  final bool isCompleted;
  final String level;

  const LessonTopicModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.durationMinutes,
    required this.isCompleted,
    required this.level,
  });

  factory LessonTopicModel.fromJson(Map<String, dynamic> json) {
    return LessonTopicModel(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      durationMinutes: json['duration_minutes'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'description': description,
        'duration_minutes': durationMinutes,
        'is_completed': isCompleted,
        'level': level,
      };
}

class LessonsListResponseModel {
  final List<LessonTopicModel> topics;
  final int total;
  final String language;

  const LessonsListResponseModel({
    required this.topics,
    required this.total,
    required this.language,
  });

  factory LessonsListResponseModel.fromJson(Map<String, dynamic> json) {
    return LessonsListResponseModel(
      topics: (json['topics'] as List)
          .map((e) => LessonTopicModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      language: json['language'] as String,
    );
  }
}

class LessonDetailModel {
  final String id;
  final String language;
  final String title;
  final String emoji;
  final String level;
  final LessonContentModel content;

  const LessonDetailModel({
    required this.id,
    required this.language,
    required this.title,
    required this.emoji,
    required this.level,
    required this.content,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    return LessonDetailModel(
      id: json['id'] as String,
      language: json['language'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      level: json['level'] as String,
      content: LessonContentModel.fromJson(json['content'] as Map<String, dynamic>),
    );
  }
}

class LessonContentModel {
  final List<VocabularyItemModel> vocabulary;
  final List<PhraseItemModel> phrases;

  const LessonContentModel({
    required this.vocabulary,
    required this.phrases,
  });

  factory LessonContentModel.fromJson(Map<String, dynamic> json) {
    return LessonContentModel(
      vocabulary: (json['vocabulary'] as List)
          .map((e) => VocabularyItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      phrases: (json['phrases'] as List)
          .map((e) => PhraseItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class VocabularyItemModel {
  final String word;
  final String translation;

  const VocabularyItemModel({
    required this.word,
    required this.translation,
  });

  factory VocabularyItemModel.fromJson(Map<String, dynamic> json) {
    return VocabularyItemModel(
      word: json['word'] as String,
      translation: json['translation'] as String,
    );
  }
}

class PhraseItemModel {
  final String phrase;
  final String translation;

  const PhraseItemModel({
    required this.phrase,
    required this.translation,
  });

  factory PhraseItemModel.fromJson(Map<String, dynamic> json) {
    return PhraseItemModel(
      phrase: json['phrase'] as String,
      translation: json['translation'] as String,
    );
  }
}