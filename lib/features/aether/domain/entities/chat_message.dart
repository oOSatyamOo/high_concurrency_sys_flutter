import 'package:equatable/equatable.dart';

// @AETHER: Domain entity for a chat message.
// Immutable, no Firestore dependency. Timestamp is non-nullable
// because every persisted message must have a server timestamp.

/// {@template chat_message}
/// Represents a single message in the global engagement chat.
///
/// Messages are append-only and immutable once created.
/// {@endtemplate}
class ChatMessage extends Equatable {
  /// Creates a [ChatMessage] entity.
  ///
  /// {@macro chat_message}
  const ChatMessage({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  /// Unique identifier for this message.
  final String id;

  /// The user ID of the sender.
  final String userId;

  /// Display name of the sender.
  final String username;

  /// Message text content.
  final String content;

  /// Server-assigned timestamp for consistent ordering.
  final DateTime timestamp;

  @override
  List<Object?> get props => <Object?>[id, userId, username, content, timestamp];
}
