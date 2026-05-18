import 'package:equatable/equatable.dart';

// @AETHER: Domain entity for the World Boss event.
// Pure business object — no serialization, no Firestore dependency.
// The endTime drives the 100ms countdown in WorldBossCubit.

/// {@template world_boss}
/// Represents an active World Boss event in the Aether universe.
///
/// The [endTime] field is the countdown target — the moment the boss
/// despawns or the event concludes. The presentation layer computes
/// the remaining duration client-side at 100ms intervals.
/// {@endtemplate}
class WorldBoss extends Equatable {
  /// Creates a [WorldBoss] entity.
  ///
  /// {@macro world_boss}
  const WorldBoss({
    required this.id,
    required this.name,
    required this.endTime,
    required this.totalDuration,
  });

  /// Unique identifier for this world boss event.
  final String id;

  /// Display name of the world boss (e.g., "Voidlord Kha'Zeth").
  final String name;

  /// The UTC timestamp when this boss event ends.
  /// Countdown = [endTime] - DateTime.now().
  final DateTime endTime;

  /// Total duration of the event from spawn to despawn.
  /// Used to calculate progress percentage for UI indicators.
  final Duration totalDuration;

  /// Whether the event has expired (boss has despawned).
  bool get isExpired => DateTime.now().isAfter(endTime);

  /// Remaining duration until the boss despawns.
  /// Returns [Duration.zero] if expired.
  Duration get remaining {
    final Duration diff = endTime.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Progress fraction (0.0 = just spawned, 1.0 = despawned).
  double get progress {
    if (totalDuration.inMilliseconds == 0) return 1.0;
    final int elapsed =
        totalDuration.inMilliseconds - remaining.inMilliseconds;
    return (elapsed / totalDuration.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => <Object?>[id, name, endTime, totalDuration];
}
