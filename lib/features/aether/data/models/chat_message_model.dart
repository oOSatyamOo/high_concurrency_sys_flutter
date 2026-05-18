import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message.dart';

// @AETHER: Data transfer object (DTO) for ChatMessage.
// Handles Firestore serialization/deserialization.
// Keeps the domain layer free of external dependencies like Timestamp.

/// {@template chat_message_model}
/// Data model for [ChatMessage] handling Firestore serialization.
/// {@endtemplate}
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.content,
    required super.timestamp,
  });

  /// Creates a model from a Firestore document snapshot.
  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final Map<String, dynamic> data = snapshot.data()!;
    return ChatMessageModel(
      id: snapshot.id,
      userId: data['user_id'] as String,
      username: data['username'] as String,
      content: data['content'] as String,
      // @AETHER: Fallback to local time only during optimistic updates
      // when server timestamp hasn't resolved yet.
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the model to a Firestore-compatible map.
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'user_id': userId,
      'username': username,
      'content': content,
      // @AETHER: Always use FieldValue.serverTimestamp() for writes
      // to ensure strictly ordered chat messages across all clients.
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
