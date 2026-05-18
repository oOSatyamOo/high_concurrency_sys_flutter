import 'package:equatable/equatable.dart';

import '../repositories/chat_repository.dart';
import 'usecase.dart';

/// Parameters for [SendMessageUseCase].
final class SendMessageParams extends Equatable {
  const SendMessageParams({
    required this.userId,
    required this.username,
    required this.content,
  });

  final String userId;
  final String username;
  final String content;

  @override
  List<Object?> get props => <Object?>[userId, username, content];
}

/// {@template send_message_usecase}
/// Use case for sending a message to the global chat.
///
/// This is a fire-and-forget operation from the UI perspective.
/// The UI should update optimistically or rely on the real-time stream.
/// {@endtemplate}
class SendMessageUseCase implements UseCase<void, SendMessageParams> {
  const SendMessageUseCase(this._repository);

  final ChatRepository _repository;

  @override
  Future<void> call(SendMessageParams params) async {
    return _repository.sendMessage(
      userId: params.userId,
      username: params.username,
      content: params.content,
    );
  }
}
