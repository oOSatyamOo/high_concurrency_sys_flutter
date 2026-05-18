import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/color_palette.dart';
import '../cubit/auth_cubit.dart';
import 'aether_page.dart';

// @AETHER: AuthGate sits above the AetherPage.
// It listens to AuthCubit. If unauthenticated, it presents a futuristic "Enter" button.
// If authenticated, it displays the actual AetherPage.

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (BuildContext context, AuthState state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorPalette.statusError,
              ),
            );
          }
        },
        builder: (BuildContext context, AuthState state) {
          if (state is AuthInitial) {
            return const Center(
              child: CircularProgressIndicator(color: ColorPalette.neonCyan),
            );
          }

          if (state is Authenticated) {
            return AetherPage(user: state.user);
          }

          // Unauthenticated or Error state shows the login screen
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.vpn_key_rounded,
                  size: 80,
                  color: ColorPalette.neonPurple,
                ),
                const SizedBox(height: 24),
                Text(
                  'AETHER PROTOCOL',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Authentication Required',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: ColorPalette.textSecondary,
                      ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    context.read<AuthCubit>().signInAnonymously();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorPalette.neonCyan,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                  ),
                  child: const Text('INITIALIZE CONNECTION'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
