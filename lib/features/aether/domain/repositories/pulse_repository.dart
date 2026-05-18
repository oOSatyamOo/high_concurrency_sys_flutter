import '../entities/world_boss.dart';

// @AETHER: Abstract repository for World Boss / Global Pulse data.
// Returns a single WorldBoss entity — the countdown timer is
// computed client-side by the cubit, NOT via repeated Firestore reads.

/// {@template pulse_repository}
/// Contract for World Boss event data operations.
///
/// The repository provides the event metadata (name, endTime, duration).
/// Timer computation is the Cubit's responsibility (runs locally at 100ms).
/// {@endtemplate}
abstract class PulseRepository {
  /// Retrieves the currently active World Boss event.
  ///
  /// Returns `null` if no event is currently active.
  Future<WorldBoss?> getActiveWorldBoss();
}
