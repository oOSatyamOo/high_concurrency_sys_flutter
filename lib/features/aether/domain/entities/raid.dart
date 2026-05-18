import 'package:equatable/equatable.dart';

// @AETHER: Domain entity for a Raid instance.
// Encapsulates participant tracking and slot availability logic.
// Business rules (isFull, availableSlots) live here, not in the UI.

/// {@template raid}
/// Represents a raid instance with participant tracking.
///
/// Enforces business invariants:
/// - Maximum [maxSlots] participants.
/// - Unique participant IDs (no duplicates).
/// {@endtemplate}
final class Raid extends Equatable {
  /// Creates a [Raid] entity.
  ///
  /// {@macro raid}
  const Raid({
    required this.participants,
    required this.maxSlots,
  });

  /// Creates an empty raid with default max slots.
  const Raid.empty()
      : participants = const <String>[],
        maxSlots = 15;

  /// List of user IDs that have successfully joined the raid.
  final List<String> participants;

  /// Maximum number of participants allowed.
  final int maxSlots;

  /// Current number of participants.
  int get currentSlots => participants.length;

  /// Number of available slots remaining.
  int get availableSlots => maxSlots - currentSlots;

  /// Whether the raid is at full capacity.
  bool get isFull => currentSlots >= maxSlots;

  /// Whether a specific user has already joined.
  bool hasJoined(String userId) => participants.contains(userId);

  @override
  List<Object?> get props => <Object?>[participants, maxSlots];
}
