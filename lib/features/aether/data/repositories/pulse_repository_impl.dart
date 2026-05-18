import '../../domain/entities/world_boss.dart';
import '../../domain/repositories/pulse_repository.dart';
import '../datasources/pulse_data_source.dart';

/// Implementation of [PulseRepository] that delegates to [PulseDataSource].
class PulseRepositoryImpl implements PulseRepository {
  const PulseRepositoryImpl(this._dataSource);

  final PulseDataSource _dataSource;

  @override
  Future<WorldBoss?> getActiveWorldBoss() {
    return _dataSource.getActiveWorldBoss();
  }
}
