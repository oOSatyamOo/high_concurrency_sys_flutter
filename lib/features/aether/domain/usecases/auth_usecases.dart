import '../entities/aether_user.dart';
import '../repositories/auth_repository.dart';
import 'usecase.dart';

class SignInAnonymouslyUseCase implements UseCase<AetherUser, NoParams> {
  const SignInAnonymouslyUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<AetherUser> call(NoParams params) {
    return _repository.signInAnonymously();
  }
}

class SignInWithGoogleUseCase implements UseCase<AetherUser, NoParams> {
  const SignInWithGoogleUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<AetherUser> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}

class SignOutUseCase implements UseCase<void, NoParams> {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) {
    return _repository.signOut();
  }
}

class WatchAuthStateUseCase implements StreamUseCase<AetherUser?, NoParams> {
  const WatchAuthStateUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Stream<AetherUser?> call(NoParams params) {
    return _repository.watchAuthState();
  }
}
