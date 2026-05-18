import '../entities/chat_message.dart';

// @AETHER: Abstract repository for chat operations.
// Stream-based for real-time updates. Send is fire-and-forget
// (Firestore handles persistence; we don't await confirmation in UI).

/// {@template chat_repository}
/// Contract for chat data operations.
///
/// Implementations must optimize for Firestore read costs by
/// limiting snapshot listeners and using cursor-based pagination.
/// {@endtemplate}
abstract class ChatRepository {
  /// Returns a real-time stream of the latest chat messages.
  ///
  /// Implementations should limit to a reasonable number (e.g., 50)
  /// and use `limitToLast` for cost efficiency.
  Stream<List<ChatMessage>> watchMessages();

  /// Sends a new message to the global chat.
  ///
  /// [userId] and [username] identify the sender.
  /// [content] is the message text.
  Future<void> sendMessage({
    required String userId,
    required String username,
    required String content,
  });
}
