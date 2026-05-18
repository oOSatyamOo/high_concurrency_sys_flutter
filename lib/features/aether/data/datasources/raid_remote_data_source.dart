import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/error/failures.dart';
import '../../../../services/raid_service.dart';
import '../../domain/entities/raid.dart';

// @AETHER: Data Source for Raid operations.
// Wraps the RaidService (which handles the complex transaction logic)
// and maps exceptions to Domain Failures.

/// {@template raid_remote_data_source}
/// Remote data source for Raid operations.
/// {@endtemplate}
abstract class RaidRemoteDataSource {
  /// Attempts to join the raid. Throws [FirestoreFailure] on network/DB errors.
  Future<bool> joinRaid({required String userId});

  /// Streams the current raid state.
  Stream<Raid> watchRaid();
}

/// Implementation of [RaidRemoteDataSource] using [RaidService].
class RaidRemoteDataSourceImpl implements RaidRemoteDataSource {
  const RaidRemoteDataSourceImpl(this._raidService);

  final RaidService _raidService;

  @override
  Future<bool> joinRaid({required String userId}) async {
    try {
      return await _raidService.joinRaid(userId: userId);
    } on FirebaseException catch (e) {
      throw FirestoreFailure(message: e.message ?? 'Unknown Firestore error');
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  @override
  Stream<Raid> watchRaid() {
    return _raidService.watchParticipants().map((List<String> participants) {
      return Raid(
        participants: participants,
        maxSlots: RaidService.maxParticipants,
      );
    }).handleError((Object error) {
      if (error is FirebaseException) {
        throw FirestoreFailure(
            message: error.message ?? 'Failed to stream raid');
      }
      throw UnexpectedFailure(message: error.toString());
    });
  }
}
