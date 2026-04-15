class SubtopicProgressModel {
  final String unit;
  final String subtopicName;
  final int subtopicIndex;
  final int score;
  final bool completed;

  const SubtopicProgressModel({
    required this.unit,
    required this.subtopicName,
    required this.subtopicIndex,
    required this.score,
    required this.completed,
  });

  factory SubtopicProgressModel.fromJson(Map<String, dynamic> json) {
    return SubtopicProgressModel(
      unit: json['unit'] as String,
      subtopicName: json['subtopic_name'] as String,
      subtopicIndex: json['subtopic_index'] as int,
      score: json['score'] as int,
      completed: json['completed'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'unit': unit,
        'subtopic_name': subtopicName,
        'subtopic_index': subtopicIndex,
        'score': score,
        'completed': completed,
      };
}

class ProgressResponseModel {
  final String userId;
  final String language;
  final List<String> completedUnits;
  final List<SubtopicProgressModel> completedSubtopics;
  final String currentUnit;
  final String currentSubtopic;
  final String currentLevel;
  final int totalScore;
  final String nextRecommendedUnit;
  final String nextRecommendedSubtopic;
  final double overallProgressPercent;

  const ProgressResponseModel({
    required this.userId,
    required this.language,
    required this.completedUnits,
    required this.completedSubtopics,
    required this.currentUnit,
    required this.currentSubtopic,
    required this.currentLevel,
    required this.totalScore,
    required this.nextRecommendedUnit,
    required this.nextRecommendedSubtopic,
    required this.overallProgressPercent,
  });

  factory ProgressResponseModel.fromJson(Map<String, dynamic> json) {
    return ProgressResponseModel(
      userId: json['user_id'] as String,
      language: json['language'] as String,
      completedUnits: (json['completed_units'] as List).cast<String>(),
      completedSubtopics: (json['completed_subtopics'] as List)
          .map((e) => SubtopicProgressModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentUnit: json['current_unit'] as String,
      currentSubtopic: json['current_subtopic'] as String,
      currentLevel: json['current_level'] as String,
      totalScore: json['total_score'] as int,
      nextRecommendedUnit: json['next_recommended_unit'] as String,
      nextRecommendedSubtopic: json['next_recommended_subtopic'] as String,
      overallProgressPercent: (json['overall_progress_percent'] as num).toDouble(),
    );
  }
}

class ProgressUpdateRequestModel {
  final String userId;
  final String language;
  final String unit;
  final int subtopicIndex;
  final String subtopicName;
  final int score;
  final String level;

  const ProgressUpdateRequestModel({
    required this.userId,
    required this.language,
    required this.unit,
    required this.subtopicIndex,
    required this.subtopicName,
    required this.score,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'language': language,
        'unit': unit,
        'subtopic_index': subtopicIndex,
        'subtopic_name': subtopicName,
        'score': score,
        'level': level,
      };
}