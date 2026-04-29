class TranslationRequestModel {
  final String text;
  final String fromLanguage;
  final String toLanguage;

  const TranslationRequestModel({
    required this.text,
    required this.fromLanguage,
    required this.toLanguage,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'from_language': fromLanguage,
        'to_language': toLanguage,
      };
}

class TranslationResponseModel {
  final String original;
  final String translation;
  final String pronunciation;
  final String? breakdown;

  const TranslationResponseModel({
    required this.original,
    required this.translation,
    required this.pronunciation,
    this.breakdown,
  });

  factory TranslationResponseModel.fromJson(Map<String, dynamic> json) {
    return TranslationResponseModel(
      original: json['original'] as String,
      translation: json['translation'] as String,
      pronunciation: json['pronunciation'] as String,
      breakdown: json['breakdown'] as String?,
    );
  }
}
