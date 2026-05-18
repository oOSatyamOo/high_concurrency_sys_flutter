import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../repositories/raid_repository.dart';
import 'usecase.dart';

/// Parameters for [JoinRaidUseCase].
final class JoinRaidParams extends Equatable {
  const JoinRaidParams({required this.userId});

  final String userId;

  @override
  List<Object?> get props => <Object?>[userId];
}

/// {@template join_raid_usecase}
/// Use case for joining an active raid.
///
/// Returns `true` on success, `false` if full or already joined.
/// Throws a subclass of [Failure] (e.g., [FirestoreFailure]) on infrastructure errors.
/// {@endtemplate}
class JoinRaidUseCase implements UseCase<bool, JoinRaidParams> {
  const JoinRaidUseCase(this._repository);

  final RaidRepository _repository;

  @override
  Future<bool> call(JoinRaidParams params) async {
    return _repository.joinRaid(userId: params.userId);
  }
}
