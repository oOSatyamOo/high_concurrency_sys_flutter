import 'package:equatable/equatable.dart';

// @AETHER: Base use case contracts following Clean Architecture.
// Two variants:
//   1. UseCase<T, P> — for one-shot Future operations (joinRaid, sendMessage)
//   2. StreamUseCase<T, P> — for real-time streams (watchRaidSlots, watchMessages)
//
// Using callable classes (operator()) so use cases read as verbs:
//   await joinRaidUseCase(JoinRaidParams(userId: '...'))

/// {@template use_case}
/// Contract for a one-shot asynchronous use case.
///
/// [Type] is the return type. [Params] is the input parameter type.
/// Use [NoParams] when the use case requires no input.
/// {@endtemplate}
abstract class UseCase<ReturnType, Params> {
  /// Executes the use case with the given [params].
  Future<ReturnType> call(Params params);
}

/// {@template stream_use_case}
/// Contract for a real-time streaming use case.
///
/// [Type] is the emitted data type. [Params] is the input parameter type.
/// Use [NoParams] when the use case requires no input.
/// {@endtemplate}
abstract class StreamUseCase<ReturnType, Params> {
  /// Returns a stream of [ReturnType] for the given [params].
  Stream<ReturnType> call(Params params);
}

/// Parameter class for use cases that require no input.
final class NoParams extends Equatable {
  /// Creates a [NoParams] instance.
  const NoParams();

  @override
  List<Object?> get props => <Object?>[];
}
