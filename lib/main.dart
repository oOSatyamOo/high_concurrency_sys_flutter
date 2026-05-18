import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/aether/presentation/cubit/auth_cubit.dart';
import 'features/aether/presentation/cubit/chat_cubit.dart';
import 'features/aether/presentation/cubit/raid_cubit.dart';
import 'features/aether/presentation/cubit/world_boss_cubit.dart';
import 'features/aether/presentation/pages/auth_gate.dart';

// @AETHER: Entry point for the Aether application.
// Initialization order is critical:
//   1. WidgetsFlutterBinding.ensureInitialized() — required for async before runApp
//   2. Firebase.initializeApp() — must complete before any Firestore access
//   3. configureDependencies() — GetIt registrations depend on Firebase being ready
//   4. runApp() — only after all infrastructure is initialized
//
// @AETHER:CONTINUATION — Phase 2 will:
//   - Replace the placeholder Scaffold with AetherPage
//   - Wrap with MultiBlocProvider for RaidCubit, ChatCubit, WorldBossCubit
//   - Add ErrorWidget.builder for production error handling

/// Application entry point.
///
/// Initializes Firebase and dependency injection before launching the UI.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // @AETHER: Firebase must be initialized before GetIt registrations
  // because lazy singletons may access FirebaseFirestore.instance.
  await Firebase.initializeApp();

  configureDependencies();

  runApp(const AetherApp());
}

/// {@template aether_app}
/// Root widget for the Aether application.
///
/// Applies the global [AppTheme.darkTheme] and sets up the Material 3 scaffold.
/// {@endtemplate}
class AetherApp extends StatelessWidget {
  /// Creates the root [AetherApp] widget.
  ///
  /// {@macro aether_app}
  const AetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aether',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<AuthCubit>(
            create: (_) => sl<AuthCubit>(),
          ),
          BlocProvider<WorldBossCubit>(
            create: (_) => sl<WorldBossCubit>(),
          ),
          BlocProvider<RaidCubit>(
            create: (_) => sl<RaidCubit>(),
          ),
          BlocProvider<ChatCubit>(
            create: (_) => sl<ChatCubit>(),
          ),
        ],
        child: const AuthGate(),
      ),
    );
  }
}
