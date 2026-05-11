import '../../../lessons/data/models/lesson_model.dart';
import '../../../progress/data/models/progress_model.dart';

abstract class ExploreRepository {
  Future<LessonsListResponseModel> getUnits({required String language});

  Future<LessonDetailModel> getUnitDetail({
    required String language,
    required String unitId,
  });

  Future<ProgressResponseModel> getUserProgress({
    required String userId,
    required String language,
  });
}
