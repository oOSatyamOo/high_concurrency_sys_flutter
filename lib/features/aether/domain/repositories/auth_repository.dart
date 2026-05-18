import '../entities/aether_user.dart';

// @AETHER: Auth Repository abstraction.
// Includes the required Google Sign-In method for future implementation.

/// {@template auth_repository}
/// Contract for authentication operations.
/// {@endtemplate}
abstract class AuthRepository {
  /// Streams the current authentication state.
  /// Emits null when unauthenticated, and [AetherUser] when authenticated.
  Stream<AetherUser?> watchAuthState();

  /// Signs in anonymously.
  Future<AetherUser> signInAnonymously();

  /// Signs in with Google credentials (saved for future).
  Future<AetherUser> signInWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();
}
