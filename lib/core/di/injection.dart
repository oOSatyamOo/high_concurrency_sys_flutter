import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/aether/data/datasources/auth_remote_data_source.dart';

import '../../features/aether/data/datasources/chat_remote_data_source.dart';
import '../../features/aether/data/datasources/pulse_data_source.dart';
import '../../features/aether/data/datasources/raid_remote_data_source.dart';
import '../../features/aether/data/repositories/chat_repository_impl.dart';
import '../../features/aether/data/repositories/pulse_repository_impl.dart';
import '../../features/aether/data/repositories/raid_repository_impl.dart';
import '../../features/aether/data/repositories/auth_repository_impl.dart';
import '../../features/aether/domain/repositories/auth_repository.dart';
import '../../features/aether/domain/repositories/chat_repository.dart';
import '../../features/aether/domain/usecases/auth_usecases.dart';
import '../../features/aether/domain/repositories/pulse_repository.dart';
import '../../features/aether/domain/repositories/raid_repository.dart';
import '../../features/aether/domain/usecases/get_world_boss_event.dart';
import '../../features/aether/domain/usecases/join_raid.dart';
import '../../features/aether/domain/usecases/send_message.dart';
import '../../features/aether/domain/usecases/watch_messages.dart';
import '../../features/aether/domain/usecases/watch_raid_slots.dart';
import '../../features/aether/presentation/cubit/auth_cubit.dart';
import '../../features/aether/presentation/cubit/chat_cubit.dart';
import '../../features/aether/presentation/cubit/raid_cubit.dart';
import '../../features/aether/presentation/cubit/world_boss_cubit.dart';
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
  sl.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  // ── Services ─────────────────────────────────────
  // @AETHER: RaidService is a singleton — multiple instances would create
  // duplicate snapshot listeners and inconsistent transaction isolation.
  sl.registerLazySingleton<RaidService>(
    () => RaidService(firestore: sl<FirebaseFirestore>()),
  );

  // ── Data Sources ─────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<FirebaseAuth>()),
  );
  sl.registerLazySingleton<RaidRemoteDataSource>(
    () => RaidRemoteDataSourceImpl(sl<RaidService>()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(sl<FirebaseFirestore>()),
  );
  sl.registerLazySingleton<PulseDataSource>(
    () => PulseDataSourceImpl(sl<FirebaseFirestore>()),
  );

  // ── Repositories ─────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
  );
  sl.registerLazySingleton<RaidRepository>(
    () => RaidRepositoryImpl(sl<RaidRemoteDataSource>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(sl<ChatRemoteDataSource>()),
  );
  sl.registerLazySingleton<PulseRepository>(
    () => PulseRepositoryImpl(sl<PulseDataSource>()),
  );

  // ── Use Cases ────────────────────────────────────
  sl.registerLazySingleton<SignInAnonymouslyUseCase>(
    () => SignInAnonymouslyUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<WatchAuthStateUseCase>(
    () => WatchAuthStateUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<JoinRaidUseCase>(
    () => JoinRaidUseCase(sl<RaidRepository>()),
  );
  sl.registerLazySingleton<WatchRaidSlotsUseCase>(
    () => WatchRaidSlotsUseCase(sl<RaidRepository>()),
  );
  sl.registerLazySingleton<SendMessageUseCase>(
    () => SendMessageUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<WatchMessagesUseCase>(
    () => WatchMessagesUseCase(sl<ChatRepository>()),
  );
  sl.registerLazySingleton<GetWorldBossEventUseCase>(
    () => GetWorldBossEventUseCase(sl<PulseRepository>()),
  );

  // ── Cubits ───────────────────────────────────────
  // @AETHER: Cubits registered as FACTORY.
  // They are tied to widget lifecycle and must be disposable.
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      watchAuthState: sl<WatchAuthStateUseCase>(),
      signInAnonymously: sl<SignInAnonymouslyUseCase>(),
      signOut: sl<SignOutUseCase>(),
    ),
  );
  sl.registerFactory<RaidCubit>(
    () => RaidCubit(
      watchRaidSlots: sl<WatchRaidSlotsUseCase>(),
      joinRaid: sl<JoinRaidUseCase>(),
    ),
  );
  sl.registerFactory<ChatCubit>(
    () => ChatCubit(
      watchMessages: sl<WatchMessagesUseCase>(),
      sendMessage: sl<SendMessageUseCase>(),
    ),
  );
  sl.registerFactory<WorldBossCubit>(
    () => WorldBossCubit(sl<GetWorldBossEventUseCase>()),
  );
}
