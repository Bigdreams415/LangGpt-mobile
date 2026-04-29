class ConversationRequestModel {
  final String language;
  final String level;
  final String unit;
  final int subtopicIndex;
  final String? subtopicName;
  final String userMessage;
  final List<Map<String, String>> conversationHistory;

  const ConversationRequestModel({
    required this.language,
    required this.level,
    required this.unit,
    required this.subtopicIndex,
    this.subtopicName,
    required this.userMessage,
    required this.conversationHistory,
  });

  Map<String, dynamic> toJson() => {
        'language': language,
        'level': level,
        'unit': unit,
        'subtopic_index': subtopicIndex,
        if (subtopicName != null) 'subtopic_name': subtopicName,
        'user_message': userMessage,
        'conversation_history': conversationHistory,
      };
}

class ConversationResponseModel {
  final String reply;
  final String translation;
  final String? corrections;
  final List<String> vocabularyUsed;

  const ConversationResponseModel({
    required this.reply,
    required this.translation,
    this.corrections,
    required this.vocabularyUsed,
  });

  factory ConversationResponseModel.fromJson(Map<String, dynamic> json) {
    return ConversationResponseModel(
      reply: json['reply'] as String,
      translation: json['translation'] as String,
      corrections: json['corrections'] as String?,
      vocabularyUsed: (json['vocabulary_used'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
