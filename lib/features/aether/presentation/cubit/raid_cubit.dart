import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/raid.dart';
import '../../domain/usecases/join_raid.dart';
import '../../domain/usecases/usecase.dart';
import '../../domain/usecases/watch_raid_slots.dart';

// ── State ────────────────────────────────────────────────────────────────────

/// State of the [RaidCubit].
sealed class RaidState extends Equatable {
  const RaidState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Initial loading state.
final class RaidInitial extends RaidState {}

/// Active raid state, updated real-time as participants join.
final class RaidActive extends RaidState {
  const RaidActive({
    required this.raid,
    this.isJoining = false,
    this.joinError,
  });

  final Raid raid;
  final bool isJoining;
  final String? joinError;

  @override
  List<Object?> get props => <Object?>[raid, isJoining, joinError];

  RaidActive copyWith({
    Raid? raid,
    bool? isJoining,
    String? joinError,
  }) {
    return RaidActive(
      raid: raid ?? this.raid,
      isJoining: isJoining ?? this.isJoining,
      // Note: Passing null for joinError will NOT clear it in this simple copyWith.
      // To clear it, we'd need a wrapped nullable type. For simplicity, we just
      // set it to empty string if we want to clear.
      joinError: joinError ?? this.joinError,
    );
  }
}

/// Error state if the initial load fails.
final class RaidError extends RaidState {
  const RaidError(this.message);
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

// ── Cubit ────────────────────────────────────────────────────────────────────

/// {@template raid_cubit}
/// Manages the state of the active Raid.
///
/// Listens to real-time participant changes and handles the "Join Raid" action.
/// {@endtemplate}
class RaidCubit extends Cubit<RaidState> {
  RaidCubit({
    required WatchRaidSlotsUseCase watchRaidSlots,
    required JoinRaidUseCase joinRaid,
  })  : _watchRaidSlots = watchRaidSlots,
        _joinRaid = joinRaid,
        super(RaidInitial()) {
    _startWatching();
  }

  final WatchRaidSlotsUseCase _watchRaidSlots;
  final JoinRaidUseCase _joinRaid;
  StreamSubscription<Raid>? _subscription;

  void _startWatching() {
    _subscription = _watchRaidSlots(const NoParams()).listen(
      (Raid raid) {
        if (state is RaidActive) {
          emit((state as RaidActive).copyWith(raid: raid));
        } else {
          emit(RaidActive(raid: raid));
        }
      },
      onError: (Object error) {
        emit(RaidError(error.toString()));
      },
    );
  }

  Future<void> joinRaid(String userId) async {
    final RaidState currentState = state;
    if (currentState is! RaidActive) return;
    if (currentState.isJoining || currentState.raid.isFull) return;

    // Optimistic UI - show joining indicator
    emit(currentState.copyWith(isJoining: true, joinError: ''));

    try {
      final bool success = await _joinRaid(JoinRaidParams(userId: userId));
      if (!success) {
        // If false, it means it's either full or already joined.
        emit((state as RaidActive).copyWith(
          isJoining: false,
          joinError: 'Raid is full or already joined.',
        ));
      } else {
        // Real-time stream will update the slots. Just turn off joining flag.
        emit((state as RaidActive).copyWith(isJoining: false));
      }
    } on Failure catch (e) {
      emit((state as RaidActive).copyWith(
        isJoining: false,
        joinError: e.message,
      ));
    } catch (e) {
      emit((state as RaidActive).copyWith(
        isJoining: false,
        joinError: 'Failed to join raid.',
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
