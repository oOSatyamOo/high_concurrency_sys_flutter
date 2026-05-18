import '../entities/raid.dart';

// @AETHER: Abstract repository — Domain layer contract.
// Data layer provides the implementation. Presentation layer
// depends only on this abstraction (Dependency Inversion Principle).

/// {@template raid_repository}
/// Contract for raid data operations.
///
/// Implementations must guarantee atomic slot management
/// (exactly [Raid.maxSlots] concurrent joins).
/// {@endtemplate}
abstract class RaidRepository {
  /// Attempts to join the active raid for the given [userId].
  ///
  /// Returns `true` if the join was successful, `false` if the
  /// raid is full or the user has already joined.
  Future<bool> joinRaid({required String userId});

  /// Returns a real-time stream of the current [Raid] state.
  ///
  /// Emits a new [Raid] entity whenever participants change.
  Stream<Raid> watchRaid();
}
