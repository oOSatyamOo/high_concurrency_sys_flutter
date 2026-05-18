import '../entities/raid.dart';
import '../repositories/raid_repository.dart';
import 'usecase.dart';

/// {@template watch_raid_slots_usecase}
/// Use case for observing the real-time state of the active raid.
///
/// Emits a new [Raid] entity whenever participants change.
/// Used to drive the UI slot counter and "Join Raid" button state.
/// {@endtemplate}
class WatchRaidSlotsUseCase implements StreamUseCase<Raid, NoParams> {
  const WatchRaidSlotsUseCase(this._repository);

  final RaidRepository _repository;

  @override
  Stream<Raid> call(NoParams params) {
    return _repository.watchRaid();
  }
}
