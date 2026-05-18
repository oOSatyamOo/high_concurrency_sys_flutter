import 'package:cloud_firestore/cloud_firestore.dart';

// @AETHER: RaidService is the CRITICAL concurrency component of the system.
// It uses Firestore Transactions (optimistic concurrency control) to guarantee
// exactly 15 successful joins out of N concurrent requests.
//
// WHY TRANSACTIONS OVER BATCH WRITES:
// - Batch writes are atomic but don't support conditional logic (read-then-write).
// - FieldValue.arrayUnion doesn't enforce max-length constraints.
// - Transactions provide read-modify-write atomicity with automatic retry on
//   contention (up to 25 retries), making them the only correct primitive here.
//
// CONTENTION MODEL:
// Under 50 concurrent requests, Firestore serializes conflicting transactions.
// Each retry re-reads the document, sees the updated participant list, and either
// succeeds (if < 15) or returns false (if >= 15). This is O(1) per attempt with
// O(k) retries where k is the contention factor.
//
// @AETHER:CONTINUATION — This service is consumed by RaidRemoteDataSource in
// Phase 2. The data source wraps this in try/catch and maps to domain Failures.

/// {@template raid_service}
/// Atomic raid slot management using Firestore Transactions.
///
/// Guarantees exactly [maxParticipants] successful joins under any level of
/// concurrent load. Thread-safe by virtue of Firestore's server-side
/// transaction serialization.
/// {@endtemplate}
class RaidService {
  /// Creates a [RaidService] backed by the provided [FirebaseFirestore] instance.
  ///
  /// {@macro raid_service}
  // @AETHER: Constructor injection for testability. In tests, we inject
  // FakeFirebaseFirestore; in production, FirebaseFirestore.instance.
  RaidService({required FirebaseFirestore firestore}) : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Maximum number of participants allowed in a single raid.
  static const int maxParticipants = 15;

  /// The Firestore collection where raid documents are stored.
  static const String _raidCollection = 'raids';

  /// The document ID for the currently active raid.
  static const String _activeRaidDocument = 'current_raid';

  /// Attempts to join the active raid for the given [userId].
  ///
  /// Returns `true` if the user successfully claimed a slot, `false` if:
  /// - The raid is full (>= [maxParticipants] slots taken).
  /// - The user has already joined (idempotency guard).
  ///
  /// This method is safe to call concurrently from any number of clients.
  /// Firestore's transaction mechanism guarantees atomicity and consistency.
  ///
  /// Throws a [FirebaseException] only on unrecoverable infrastructure failures
  /// (network down, permission denied, etc.). Contention is handled internally
  /// via Firestore's automatic transaction retry.
  // @AETHER: This is the atomic read-modify-write that guarantees exactly 15
  // successful joins. The transaction reads the current state, validates
  // constraints, and writes — all atomically. On contention, Firestore
  // re-runs the entire callback with fresh data.
  Future<bool> joinRaid({required String userId}) async {
    final DocumentReference<Map<String, dynamic>> raidDocRef =
        _firestore.collection(_raidCollection).doc(_activeRaidDocument);

    return _firestore.runTransaction<bool>((Transaction transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get(raidDocRef);

      if (!snapshot.exists) {
        // @AETHER: First joiner initializes the raid document atomically.
        // The transaction guarantees only one initialization succeeds;
        // all other concurrent initializers will retry and see the doc.
        transaction.set(raidDocRef, <String, Object>{
          'participants': <String>[userId],
          'max_slots': maxParticipants,
          'created_at': FieldValue.serverTimestamp(),
        });
        return true;
      }

      final Map<String, Object?> data = snapshot.data()!;
      final List<String> participants =
          List<String>.from(data['participants']! as List<Object?>);

      // @AETHER: Idempotency guard — prevents the same user from consuming
      // multiple slots. This is critical under retry scenarios where a client
      // might re-send after a timeout even though the first attempt succeeded.
      if (participants.contains(userId)) {
        return false;
      }

      // @AETHER: Capacity check — the core invariant. If 15 users have already
      // joined, all subsequent transactions see length >= 15 and return false.
      if (participants.length >= maxParticipants) {
        return false;
      }

      participants.add(userId);
      transaction.update(raidDocRef, <String, Object>{
        'participants': participants,
      });
      return true;
    });
  }

  /// Returns a real-time stream of the current raid's participant list.
  ///
  /// Emits a new list every time a user joins or leaves.
  /// Used by [WatchRaidSlotsUseCase] to drive the UI slot counter.
  // @AETHER:CONTINUATION — This stream is consumed by RaidCubit in Phase 2.
  Stream<List<String>> watchParticipants() {
    return _firestore
        .collection(_raidCollection)
        .doc(_activeRaidDocument)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (!snapshot.exists) {
        return <String>[];
      }
      final Map<String, Object?> data = snapshot.data()!;
      return List<String>.from(data['participants']! as List<Object?>);
    });
  }

  /// Resets the active raid by clearing all participants.
  ///
  /// Used primarily in testing to reset state between test runs.
  // @AETHER: Not exposed in production use cases — only called from tests
  // and admin tooling.
  Future<void> resetRaid() async {
    await _firestore
        .collection(_raidCollection)
        .doc(_activeRaidDocument)
        .set(<String, Object>{
      'participants': <String>[],
      'max_slots': maxParticipants,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
