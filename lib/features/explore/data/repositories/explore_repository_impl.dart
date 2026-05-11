import '../../../lessons/data/datasources/lessons_remote_datasource.dart';
import '../../../lessons/data/models/lesson_model.dart';
import '../../../progress/data/datasources/progress_remote_datasource.dart';
import '../../../progress/data/models/progress_model.dart';
import '../../domain/repositories/explore_repository.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  ExploreRepositoryImpl._();
  static final ExploreRepositoryImpl instance = ExploreRepositoryImpl._();

  final _lessons = LessonsRemoteDataSource.instance;
  final _progress = ProgressRemoteDataSource.instance;

  @override
  Future<LessonsListResponseModel> getUnits({required String language}) {
    return _lessons.getLessonsList(language: language, limit: 100);
  }

  @override
  Future<LessonDetailModel> getUnitDetail({
    required String language,
    required String unitId,
  }) {
    return _lessons.getLessonDetail(language: language, topicId: unitId);
  }

  @override
  Future<ProgressResponseModel> getUserProgress({
    required String userId,
    required String language,
  }) {
    return _progress.getProgress(userId: userId, language: language);
  }
}
