import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/constants.dart';
import '../models/chat_message_model.dart';

// @AETHER: Chat Data Source optimized for read costs.
// Uses `limitToLast` so subsequent snapshot events only cost 1 read
// for the new document, rather than re-reading the entire collection.

/// {@template chat_remote_data_source}
/// Remote data source for Chat operations.
/// {@endtemplate}
abstract class ChatRemoteDataSource {
  /// Streams chat messages.
  Stream<List<ChatMessageModel>> watchMessages();

  /// Sends a chat message.
  Future<void> sendMessage(ChatMessageModel message);
}

/// Implementation of [ChatRemoteDataSource] using Firestore.
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  ChatRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  @override
  Stream<List<ChatMessageModel>> watchMessages() {
    return _firestore
        .collection(AetherConstants.chatCollection)
        .orderBy('timestamp')
        // @AETHER: CRITICAL COST OPTIMIZATION
        // limits initial load, and only new docs trigger subsequent reads.
        .limitToLast(AetherConstants.chatMessageLimit)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> doc) =>
              ChatMessageModel.fromFirestore(doc))
          .toList();
    }).handleError((Object error) {
      if (error is FirebaseException) {
        throw FirestoreFailure(message: error.message ?? 'Chat stream error');
      }
      throw UnexpectedFailure(message: error.toString());
    });
  }

  @override
  Future<void> sendMessage(ChatMessageModel message) async {
    try {
      // Use the UUID provided by the model or generate one if not provided
      final String docId = message.id.isEmpty ? _uuid.v4() : message.id;
      
      await _firestore
          .collection(AetherConstants.chatCollection)
          .doc(docId)
          .set(message.toFirestore());
    } on FirebaseException catch (e) {
      throw FirestoreFailure(message: e.message ?? 'Failed to send message');
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
