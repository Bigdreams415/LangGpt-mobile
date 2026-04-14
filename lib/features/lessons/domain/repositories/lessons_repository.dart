import '../../data/models/lesson_model.dart';

abstract class LessonsRepository {
  Future<LessonsListResponseModel> getLessonsList({
    required String language,
    String? level,
    int limit,
    int offset,
  });

  Future<LessonDetailModel> getLessonDetail({
    required String language,
    required String topicId,
  });
}