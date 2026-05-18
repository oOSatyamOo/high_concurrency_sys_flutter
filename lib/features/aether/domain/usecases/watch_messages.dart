import '../entities/chat_message.dart';
import '../repositories/chat_repository.dart';
import 'usecase.dart';

/// {@template watch_messages_usecase}
/// Use case for observing real-time global chat messages.
///
/// Emits a list of the latest [ChatMessage] entities.
/// Designed to be cost-efficient (relies on repository to limit snapshot size).
/// {@endtemplate}
class WatchMessagesUseCase implements StreamUseCase<List<ChatMessage>, NoParams> {
  const WatchMessagesUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Stream<List<ChatMessage>> call(NoParams params) {
    return _repository.watchMessages();
  }
}
