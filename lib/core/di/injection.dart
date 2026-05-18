import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../../services/raid_service.dart';

// @AETHER: Service Locator pattern via GetIt for dependency injection.
// WHY GETIT OVER INJECTABLE/RIVERPOD DI:
// - Zero codegen = faster CI, no build_runner dependency.
// - Singleton registration is explicit — critical for services like RaidService
//   that MUST be single-instance to avoid duplicate Firestore listeners.
// - Lazy singletons defer construction until first access, reducing startup time.
//
// @AETHER:CONTINUATION — Phase 2 will register:
//   - Data sources (RaidRemoteDataSource, ChatRemoteDataSource, PulseDataSource)
//   - Repositories (RaidRepositoryImpl, ChatRepositoryImpl, PulseRepositoryImpl)
//   - Use cases (JoinRaid, WatchRaidSlots, SendMessage, WatchMessages, GetWorldBossEvent)
//   - Cubits (RaidCubit, ChatCubit, WorldBossCubit)
// Register them below in the marked sections.

/// Global [GetIt] service locator instance.
///
/// Access via `sl<T>()` throughout the application.
/// All registrations happen in [configureDependencies].
final GetIt sl = GetIt.instance;

/// Configures all dependency injection bindings.
///
/// Must be called exactly once before [runApp] in `main.dart`.
/// Registration order: External → Services → DataSources → Repositories →
/// UseCases → Cubits (dependency chain, bottom-up).
void configureDependencies() {
  // ── External Dependencies ────────────────────────
  // @AETHER: FirebaseFirestore registered as lazy singleton.
  // Lazy because Firebase.initializeApp() must complete before access.
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // ── Services ─────────────────────────────────────
  // @AETHER: RaidService is a singleton — multiple instances would create
  // duplicate snapshot listeners and inconsistent transaction isolation.
  sl.registerLazySingleton<RaidService>(
    () => RaidService(firestore: sl<FirebaseFirestore>()),
  );

  // ── Data Sources ─────────────────────────────────
  // @AETHER:CONTINUATION — Register data sources here in Phase 2.
  // sl.registerLazySingleton<RaidRemoteDataSource>(...);
  // sl.registerLazySingleton<ChatRemoteDataSource>(...);
  // sl.registerLazySingleton<PulseDataSource>(...);

  // ── Repositories ─────────────────────────────────
  // @AETHER:CONTINUATION — Register repository implementations here in Phase 2.
  // sl.registerLazySingleton<RaidRepository>(...);
  // sl.registerLazySingleton<ChatRepository>(...);
  // sl.registerLazySingleton<PulseRepository>(...);

  // ── Use Cases ────────────────────────────────────
  // @AETHER:CONTINUATION — Register use cases here in Phase 2.
  // sl.registerLazySingleton<JoinRaidUseCase>(...);
  // sl.registerLazySingleton<WatchRaidSlotsUseCase>(...);
  // sl.registerLazySingleton<SendMessageUseCase>(...);
  // sl.registerLazySingleton<WatchMessagesUseCase>(...);
  // sl.registerLazySingleton<GetWorldBossEventUseCase>(...);

  // ── Cubits ───────────────────────────────────────
  // @AETHER:CONTINUATION — Register cubits as FACTORY (not singleton).
  // Cubits are tied to widget lifecycle and must be disposable.
  // sl.registerFactory<RaidCubit>(...);
  // sl.registerFactory<ChatCubit>(...);
  // sl.registerFactory<WorldBossCubit>(...);
}
