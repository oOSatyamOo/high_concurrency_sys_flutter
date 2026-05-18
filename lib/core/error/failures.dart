import 'package:equatable/equatable.dart';

// @AETHER: Sealed failure hierarchy using Equatable for value equality.
// Each failure type maps to a specific infrastructure or domain error.
// Use cases return Either<Failure, T> (or we throw and catch in Cubit).
//
// @AETHER:CONTINUATION — Add new failure subclasses here as features grow.
// Never use generic Exception or dynamic catch blocks.

/// {@template failure}
/// Base class for all domain-level failures in Aether.
///
/// Failures are distinguished from Exceptions: Exceptions are infrastructure
/// concerns (caught in the data layer), Failures are domain concepts
/// (returned to the presentation layer for user-facing error handling).
/// {@endtemplate}
sealed class Failure extends Equatable {
  /// Creates a [Failure] with an optional human-readable [message].
  const Failure({required this.message});

  /// A human-readable description of what went wrong.
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Failure originating from Firebase/Firestore operations.
final class FirestoreFailure extends Failure {
  const FirestoreFailure({required super.message});
}

/// Failure when a raid operation cannot be completed.
final class RaidFailure extends Failure {
  const RaidFailure({required super.message});
}

/// Failure when a chat operation cannot be completed.
final class ChatFailure extends Failure {
  const ChatFailure({required super.message});
}

/// Failure due to network connectivity issues.
final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Failure when an unexpected/unknown error occurs.
/// This is the catch-all — should be rare in a well-typed system.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}
