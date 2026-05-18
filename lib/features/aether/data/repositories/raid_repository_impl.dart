import '../../domain/entities/raid.dart';
import '../../domain/repositories/raid_repository.dart';
import '../datasources/raid_remote_data_source.dart';

/// Implementation of [RaidRepository] that delegates to [RaidRemoteDataSource].
class RaidRepositoryImpl implements RaidRepository {
  const RaidRepositoryImpl(this._remoteDataSource);

  final RaidRemoteDataSource _remoteDataSource;

  @override
  Future<bool> joinRaid({required String userId}) {
    return _remoteDataSource.joinRaid(userId: userId);
  }

  @override
  Stream<Raid> watchRaid() {
    return _remoteDataSource.watchRaid();
  }
}
