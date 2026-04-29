import '../../domain/repositories/conversation_repository.dart';
import '../datasources/conversation_remote_datasource.dart';
import '../models/conversation_model.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  ConversationRepositoryImpl._();
  static final ConversationRepositoryImpl instance =
      ConversationRepositoryImpl._();

  final _datasource = ConversationRemoteDataSource.instance;

  @override
  Future<ConversationResponseModel> sendMessage(
    ConversationRequestModel request,
  ) async {
    return _datasource.sendMessage(request: request);
  }
}
