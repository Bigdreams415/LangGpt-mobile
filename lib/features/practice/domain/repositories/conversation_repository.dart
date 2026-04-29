import '../../data/models/conversation_model.dart';

abstract class ConversationRepository {
  Future<ConversationResponseModel> sendMessage(ConversationRequestModel request);
}
