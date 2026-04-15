class SubtopicModel {
  final String name;
  final String description;
  final int durationMinutes;
  final bool isCompleted;

  const SubtopicModel({
    required this.name,
    required this.description,
    required this.durationMinutes,
    this.isCompleted = false,
  });

  factory SubtopicModel.fromJson(Map<String, dynamic> json) {
    return SubtopicModel(
      name: json['name'] as String,
      description: json['description'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 5,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'duration_minutes': durationMinutes,
        'is_completed': isCompleted,
      };
}

class LessonUnitModel {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final int durationMinutes;
  final String level;
  final int subtopicCount;
  final bool isCompleted;

  const LessonUnitModel({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    required this.durationMinutes,
    required this.level,
    required this.subtopicCount,
    this.isCompleted = false,
  });

  factory LessonUnitModel.fromJson(Map<String, dynamic> json) {
    return LessonUnitModel(
      id: json['id'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      description: json['description'] as String,
      durationMinutes: json['duration_minutes'] as int,
      level: json['level'] as String,
      subtopicCount: json['subtopic_count'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

class LessonsListResponseModel {
  final List<LessonUnitModel> topics;
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
          .map((e) => LessonUnitModel.fromJson(e as Map<String, dynamic>))
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
  final List<SubtopicModel> subtopics;
  final Map<String, dynamic> content;

  const LessonDetailModel({
    required this.id,
    required this.language,
    required this.title,
    required this.emoji,
    required this.level,
    required this.subtopics,
    required this.content,
  });

  factory LessonDetailModel.fromJson(Map<String, dynamic> json) {
    return LessonDetailModel(
      id: json['id'] as String,
      language: json['language'] as String,
      title: json['title'] as String,
      emoji: json['emoji'] as String,
      level: json['level'] as String,
      subtopics: (json['subtopics'] as List)
          .map((e) => SubtopicModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      content: json['content'] as Map<String, dynamic>? ?? {},
    );
  }
}

// AI-Generated Lesson Response
class VocabItemModel {
  final String word;
  final String translation;
  final String pronunciation;
  final String exampleSentence;
  final String sentenceTranslation;

  const VocabItemModel({
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.exampleSentence,
    required this.sentenceTranslation,
  });

  factory VocabItemModel.fromJson(Map<String, dynamic> json) {
    return VocabItemModel(
      word: json['word'] as String,
      translation: json['translation'] as String,
      pronunciation: json['pronunciation'] as String,
      exampleSentence: json['example_sentence'] as String,
      sentenceTranslation: json['sentence_translation'] as String,
    );
  }
}

class LessonResponseModel {
  final String language;
  final String level;
  final String unit;
  final String subtopic;
  final int subtopicIndex;
  final int totalSubtopics;
  final String introduction;
  final List<VocabItemModel> vocabulary;
  final String culturalNote;
  final String tip;
  final String? nextSubtopic;

  const LessonResponseModel({
    required this.language,
    required this.level,
    required this.unit,
    required this.subtopic,
    required this.subtopicIndex,
    required this.totalSubtopics,
    required this.introduction,
    required this.vocabulary,
    required this.culturalNote,
    required this.tip,
    this.nextSubtopic,
  });

  factory LessonResponseModel.fromJson(Map<String, dynamic> json) {
    return LessonResponseModel(
      language: json['language'] as String,
      level: json['level'] as String,
      unit: json['unit'] as String,
      subtopic: json['subtopic'] as String,
      subtopicIndex: json['subtopic_index'] as int,
      totalSubtopics: json['total_subtopics'] as int,
      introduction: json['introduction'] as String,
      vocabulary: (json['vocabulary'] as List)
          .map((e) => VocabItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      culturalNote: json['cultural_note'] as String,
      tip: json['tip'] as String,
      nextSubtopic: json['next_subtopic'] as String?,
    );
  }
}