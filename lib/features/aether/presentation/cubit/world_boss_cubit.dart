import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/constants.dart';
import '../../domain/entities/world_boss.dart';
import '../../domain/usecases/get_world_boss_event.dart';
import '../../domain/usecases/usecase.dart';

// ── State ────────────────────────────────────────────────────────────────────

/// State of the [WorldBossCubit].
sealed class WorldBossState extends Equatable {
  const WorldBossState();
  
  @override
  List<Object?> get props => <Object?>[];
}

/// Initial state before fetching the boss.
final class WorldBossInitial extends WorldBossState {}

/// When no boss event is currently active.
final class WorldBossNoneActive extends WorldBossState {}

/// When a boss is active. Emits every 100ms.
final class WorldBossActive extends WorldBossState {
  const WorldBossActive({
    required this.boss,
    required this.remaining,
    required this.progress,
  });

  final WorldBoss boss;
  final Duration remaining;
  final double progress;

  @override
  List<Object?> get props => <Object?>[boss, remaining, progress];
}

// ── Cubit ────────────────────────────────────────────────────────────────────

/// {@template world_boss_cubit}
/// Manages the state of the active World Boss event.
///
/// Responsible for the 100ms UI ticker. Runs entirely client-side after the
/// initial fetch to avoid high Firestore read costs.
/// {@endtemplate}
class WorldBossCubit extends Cubit<WorldBossState> {
  WorldBossCubit(this._getWorldBossEvent) : super(WorldBossInitial()) {
    _fetchBoss();
  }

  final GetWorldBossEventUseCase _getWorldBossEvent;
  Timer? _timer;

  Future<void> _fetchBoss() async {
    final WorldBoss? boss = await _getWorldBossEvent(const NoParams());

    if (boss == null || boss.isExpired) {
      emit(WorldBossNoneActive());
      return;
    }

    _startPulse(boss);
  }

  void _startPulse(WorldBoss boss) {
    _timer?.cancel();
    
    // Initial emit
    _emitTick(boss);

    // @AETHER: 100ms periodic timer runs locally.
    // Cubit.emit is synchronous and fast, ideal for this high-frequency update.
    _timer = Timer.periodic(AetherConstants.pulseTickInterval, (_) {
      _emitTick(boss);
    });
  }

  void _emitTick(WorldBoss boss) {
    if (boss.isExpired) {
      _timer?.cancel();
      emit(WorldBossNoneActive());
      return;
    }

    emit(WorldBossActive(
      boss: boss,
      remaining: boss.remaining,
      progress: boss.progress,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
