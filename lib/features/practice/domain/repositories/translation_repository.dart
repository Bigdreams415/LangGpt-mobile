import '../../data/models/translation_model.dart';

abstract class TranslationRepository {
  Future<TranslationResponseModel> translate(TranslationRequestModel request);
}
