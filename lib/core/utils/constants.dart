// @AETHER: App-wide constants. Centralized to prevent magic numbers/strings.
// All values are compile-time constants for zero runtime lookup cost.
//
// @AETHER:CONTINUATION — Add feature-specific constants here as needed.

/// {@template aether_constants}
/// Centralized application constants for Aether.
///
/// Organized by feature domain to maintain clarity as the system grows.
/// {@endtemplate}
abstract final class AetherConstants {
  // ── World Boss / Global Pulse ────────────────────
  /// Timer tick interval for the World Boss countdown display.
  /// 100ms provides smooth visual updates without excessive CPU usage.
  static const Duration pulseTickInterval = Duration(milliseconds: 100);

  /// Default World Boss event duration (minutes from spawn to despawn).
  static const Duration worldBossDuration = Duration(minutes: 30);

  // ── Raid ─────────────────────────────────────────
  /// Maximum participants per raid instance.
  static const int raidMaxSlots = 15;

  // ── Chat ─────────────────────────────────────────
  /// Maximum number of messages to fetch/display in the chat window.
  /// @AETHER: Limiting to 50 messages caps Firestore reads per listener
  /// attach. With limitToLast, only new messages trigger reads after
  /// initial load — keeping costs O(1) per new message, not O(n).
  static const int chatMessageLimit = 50;

  /// Maximum character length for a single chat message.
  static const int chatMaxMessageLength = 280;

  // ── Firestore Collections ────────────────────────
  /// Collection name for raid documents.
  static const String raidsCollection = 'events';

  /// Collection name for chat messages.
  static const String chatCollection = 'global_chat';

  /// Collection name for world boss events.
  static const String worldBossCollection = 'world_boss';

  /// Document ID for the currently active raid.
  static const String activeRaidDocument = 'dragon_raid';

  /// Document ID for the active world boss event.
  static const String activeWorldBossDocument = 'active_event';
}
