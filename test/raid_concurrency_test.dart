import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aether_cost_opt/services/raid_service.dart';

// @AETHER: Concurrency test for RaidService.
// This test validates the CORE INVARIANT: exactly 15 successful joins
// out of 50 concurrent requests using Firestore transactions.
//
// WHY fake_cloud_firestore:
// - FakeFirebaseFirestore implements runTransaction with proper
//   optimistic concurrency control simulation.
// - In-memory = fast, deterministic, no network flakiness.
// - Supports all Firestore operations used by RaidService.
//
// TEST STRATEGY:
// We fire 50 concurrent joinRaid() calls with unique userIds.
// The transaction guarantees atomic read-modify-write, so exactly
// 15 should succeed (return true) and 35 should fail (return false).

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RaidService raidService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    raidService = RaidService(firestore: fakeFirestore);
  });

  group('RaidService Concurrency', () {
    test(
      'exactly 15 out of 50 concurrent joinRaid requests should succeed',
      () async {
        // @AETHER: Generate 50 unique user IDs to simulate concurrent players.
        const int totalRequests = 50;
        final List<String> userIds = List<String>.generate(
          totalRequests,
          (int index) => 'user_$index',
        );

        // @AETHER: Fire all 50 requests concurrently using Future.wait.
        // This simulates a thundering herd of players hitting "Join Raid"
        // at the same instant.
        final List<bool> results = await Future.wait(
          userIds.map(
            (String userId) => raidService.joinRaid(userId: userId),
          ),
        );

        // Count successful joins.
        final int successCount = results.where((bool result) => result).length;
        final int failureCount =
            results.where((bool result) => !result).length;

        // @AETHER: The core invariant — exactly 15 succeed, 35 fail.
        expect(
          successCount,
          equals(RaidService.maxParticipants),
          reason:
              'Exactly ${RaidService.maxParticipants} users should join. '
              'Got $successCount successes and $failureCount failures.',
        );
        expect(
          failureCount,
          equals(totalRequests - RaidService.maxParticipants),
          reason:
              'Exactly ${totalRequests - RaidService.maxParticipants} users '
              'should be rejected.',
        );

        // @AETHER: Verify the actual document state in Firestore.
        // This ensures the transaction wrote correctly, not just returned
        // the right booleans.
        final snapshot = await fakeFirestore
            .collection('raids')
            .doc('current_raid')
            .get();

        expect(snapshot.exists, isTrue, reason: 'Raid document must exist.');

        final Map<String, Object?> data = snapshot.data()!;
        final List<String> participants =
            List<String>.from(data['participants']! as List<Object?>);

        expect(
          participants.length,
          equals(RaidService.maxParticipants),
          reason:
              'Firestore document should contain exactly '
              '${RaidService.maxParticipants} participants.',
        );

        // @AETHER: Verify no duplicate participants (idempotency check).
        expect(
          participants.toSet().length,
          equals(participants.length),
          reason: 'No duplicate participants should exist.',
        );
      },
    );

    test('same user cannot join twice (idempotency)', () async {
      // First join should succeed.
      final bool firstJoin = await raidService.joinRaid(userId: 'duplicate_user');
      expect(firstJoin, isTrue);

      // Second join with same userId should fail.
      final bool secondJoin =
          await raidService.joinRaid(userId: 'duplicate_user');
      expect(secondJoin, isFalse);

      // Verify only one entry in participants.
      final snapshot = await fakeFirestore
          .collection('raids')
          .doc('current_raid')
          .get();
      final Map<String, Object?> data = snapshot.data()!;
      final List<String> participants =
          List<String>.from(data['participants']! as List<Object?>);

      final int duplicateCount =
          participants.where((String id) => id == 'duplicate_user').length;
      expect(
        duplicateCount,
        equals(1),
        reason: 'User should appear exactly once despite double join attempt.',
      );
    });

    test('joinRaid returns false when raid is full', () async {
      // Fill up all 15 slots.
      for (int i = 0; i < RaidService.maxParticipants; i++) {
        final bool result =
            await raidService.joinRaid(userId: 'filler_$i');
        expect(result, isTrue, reason: 'Slot $i should be available.');
      }

      // 16th user should be rejected.
      final bool overflow =
          await raidService.joinRaid(userId: 'overflow_user');
      expect(
        overflow,
        isFalse,
        reason: 'User should be rejected when raid is at max capacity.',
      );
    });

    test('first joiner initializes raid document', () async {
      // Document should not exist before first join.
      final beforeSnapshot = await fakeFirestore
          .collection('raids')
          .doc('current_raid')
          .get();
      expect(beforeSnapshot.exists, isFalse);

      // First join should succeed and create the document.
      final bool result =
          await raidService.joinRaid(userId: 'pioneer_user');
      expect(result, isTrue);

      // Document should now exist with proper structure.
      final afterSnapshot = await fakeFirestore
          .collection('raids')
          .doc('current_raid')
          .get();
      expect(afterSnapshot.exists, isTrue);

      final Map<String, Object?> data = afterSnapshot.data()!;
      expect(data['max_slots'], equals(RaidService.maxParticipants));
      expect(data['participants'], contains('pioneer_user'));
    });

    test('watchParticipants emits updated list on join', () async {
      // Start listening before any joins.
      final Stream<List<String>> stream = raidService.watchParticipants();

      // Join a user.
      await raidService.joinRaid(userId: 'watcher_test_user');

      // @AETHER: Verify the stream emits the updated participant list.
      await expectLater(
        stream,
        emits(contains('watcher_test_user')),
      );
    });

    test('resetRaid clears all participants', () async {
      // Join some users.
      await raidService.joinRaid(userId: 'reset_user_1');
      await raidService.joinRaid(userId: 'reset_user_2');

      // Reset the raid.
      await raidService.resetRaid();

      // Verify raid is empty.
      final snapshot = await fakeFirestore
          .collection('raids')
          .doc('current_raid')
          .get();
      final Map<String, Object?> data = snapshot.data()!;
      final List<String> participants =
          List<String>.from(data['participants']! as List<Object?>);

      expect(
        participants,
        isEmpty,
        reason: 'Participants should be empty after reset.',
      );
    });
  });
}
