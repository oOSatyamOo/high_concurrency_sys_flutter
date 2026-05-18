import '../../domain/entities/aether_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Stream<AetherUser?> watchAuthState() {
    return _remoteDataSource.watchAuthState();
  }

  @override
  Future<AetherUser> signInAnonymously() {
    return _remoteDataSource.signInAnonymously();
  }

  @override
  Future<AetherUser> signInWithGoogle() {
    return _remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }
}
