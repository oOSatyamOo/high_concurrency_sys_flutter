import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';

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

      // @AETHER:CONTINUATION — Replace this home with AetherPage in Phase 2.
      // The AetherPage will contain three sections:
      //   1. GlobalPulseWidget (top) — World Boss countdown
      //   2. GeoRaidWidget (center) — Raid slots + Join button
      //   3. EngagementChatWidget (bottom) — Real-time chat
      home: const _AetherPlaceholder(),
    );
  }
}

/// Temporary placeholder widget until Phase 2 builds the full AetherPage.
///
/// Displays a confirmation that the core foundation is working.
class _AetherPlaceholder extends StatelessWidget {
  const _AetherPlaceholder();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.flash_on_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'AETHER',
              style: theme.textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'The Nervous System',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            Text(
              'Core Foundation Active',
              style: theme.textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}
