import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_remote_datasource.dart';
import '../models/translation_model.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  TranslationRepositoryImpl._();
  static final TranslationRepositoryImpl instance =
      TranslationRepositoryImpl._();

  final _datasource = TranslationRemoteDataSource.instance;

  @override
  Future<TranslationResponseModel> translate(
    TranslationRequestModel request,
  ) async {
    return _datasource.translate(request: request);
  }
}
