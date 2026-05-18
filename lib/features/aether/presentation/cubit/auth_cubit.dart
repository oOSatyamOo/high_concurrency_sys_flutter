import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/aether_user.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/usecase.dart';

// ── State ────────────────────────────────────────────────────────────────────

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial state while determining if user is logged in.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when the user is successfully authenticated.
final class Authenticated extends AuthState {
  const Authenticated(this.user);
  final AetherUser user;

  @override
  List<Object?> get props => <Object?>[user];
}

/// State when the user is completely signed out.
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Error state if sign-in fails.
final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

// ── Cubit ────────────────────────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required WatchAuthStateUseCase watchAuthState,
    required SignInAnonymouslyUseCase signInAnonymously,
    required SignOutUseCase signOut,
  })  : _watchAuthState = watchAuthState,
        _signInAnonymously = signInAnonymously,
        _signOut = signOut,
        super(const AuthInitial()) {
    _startWatching();
  }

  final WatchAuthStateUseCase _watchAuthState;
  final SignInAnonymouslyUseCase _signInAnonymously;
  final SignOutUseCase _signOut;
  StreamSubscription<AetherUser?>? _subscription;

  void _startWatching() {
    _subscription = _watchAuthState(const NoParams()).listen(
      (AetherUser? user) {
        if (user == null) {
          emit(const Unauthenticated());
        } else {
          emit(Authenticated(user));
        }
      },
      onError: (Object error) {
        emit(AuthError(error.toString()));
      },
    );
  }

  Future<void> signInAnonymously() async {
    // Show loading state if we are currently unauthenticated
    if (state is Unauthenticated || state is AuthError) {
      emit(const AuthInitial());
    }
    try {
      await _signInAnonymously(const NoParams());
      // The stream will naturally emit Authenticated once this completes
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Failed to sign in anonymously.'));
    }
  }

  Future<void> signOut() async {
    try {
      await _signOut(const NoParams());
      // Stream will emit Unauthenticated
    } on Failure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Failed to sign out.'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
