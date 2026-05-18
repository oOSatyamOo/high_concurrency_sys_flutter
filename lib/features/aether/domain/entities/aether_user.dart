import 'package:equatable/equatable.dart';

// @AETHER: Domain entity for an authenticated user.
// Kept separate from Firebase User to adhere to Clean Architecture.

/// {@template aether_user}
/// Represents an authenticated user in the system.
/// {@endtemplate}
class AetherUser extends Equatable {
  const AetherUser({
    required this.id,
    this.email,
    this.displayName,
    required this.isAnonymous,
  });

  /// The unique identifier (UID).
  final String id;
  
  /// The user's email address (null if anonymous).
  final String? email;
  
  /// The user's display name (null if anonymous or not set).
  final String? displayName;
  
  /// Whether the user is signed in anonymously.
  final bool isAnonymous;

  @override
  List<Object?> get props => <Object?>[id, email, displayName, isAnonymous];
}
