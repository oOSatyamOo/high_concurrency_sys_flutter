import '../entities/world_boss.dart';
import '../repositories/pulse_repository.dart';
import 'usecase.dart';

/// {@template get_world_boss_event_usecase}
/// Use case for fetching the currently active World Boss event.
///
/// This is a one-shot fetch. The resulting [WorldBoss] entity contains
/// an [endTime] which the presentation layer uses to drive a local 100ms timer.
/// {@endtemplate}
class GetWorldBossEventUseCase implements UseCase<WorldBoss?, NoParams> {
  const GetWorldBossEventUseCase(this._repository);

  final PulseRepository _repository;

  @override
  Future<WorldBoss?> call(NoParams params) async {
    return _repository.getActiveWorldBoss();
  }
}
