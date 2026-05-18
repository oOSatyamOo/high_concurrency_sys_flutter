import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';
import '../models/chat_message_model.dart';

/// Implementation of [ChatRepository] that delegates to [ChatRemoteDataSource].
class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;

  @override
  Stream<List<ChatMessage>> watchMessages() {
    // The data source returns List<ChatMessageModel> which extends ChatMessage,
    // so we can safely cast or just let polymorphism handle it.
    // We map it to ensure the return type matches the domain layer signature exactly.
    return _remoteDataSource.watchMessages().map(
          (List<ChatMessageModel> models) => models.cast<ChatMessage>(),
        );
  }

  @override
  Future<void> sendMessage({
    required String userId,
    required String username,
    required String content,
  }) {
    final ChatMessageModel model = ChatMessageModel(
      id: '', // Empty ID signifies a new message (data source generates UUID)
      userId: userId,
      username: username,
      content: content,
      timestamp: DateTime.now(), // Fallback for optimistic UI if needed
    );
    return _remoteDataSource.sendMessage(model);
  }
}
