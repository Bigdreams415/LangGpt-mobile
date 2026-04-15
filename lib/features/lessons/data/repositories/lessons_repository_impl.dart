import '../../domain/repositories/lessons_repository.dart';
import '../datasources/lessons_remote_datasource.dart';
import '../models/lesson_model.dart';

class LessonsRepositoryImpl implements LessonsRepository {
  LessonsRepositoryImpl._();
  static final LessonsRepositoryImpl instance = LessonsRepositoryImpl._();

  final _remoteDataSource = LessonsRemoteDataSource.instance;

  @override
  Future<LessonsListResponseModel> getLessonsList({
    required String language,
    String? level,
    int limit = 20,
    int offset = 0,
  }) async {
    return await _remoteDataSource.getLessonsList(
      language: language,
      level: level,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<LessonDetailModel> getLessonDetail({
    required String language,
    required String topicId,
  }) async {
    return await _remoteDataSource.getLessonDetail(
      language: language,
      topicId: topicId,
    );
  }

  @override
  Future<LessonResponseModel> generateLesson({
    required String language,
    required String level,
    required String unit,
    required int subtopicIndex,
    String? subtopicName,
  }) async {
    return await _remoteDataSource.generateLesson(
      language: language,
      level: level,
      unit: unit,
      subtopicIndex: subtopicIndex,
      subtopicName: subtopicName,
    );
  }
}
