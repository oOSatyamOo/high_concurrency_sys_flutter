import 'package:aether_cost_opt/features/aether/presentation/widgets/engagement_chat_widget.dart';
import 'package:aether_cost_opt/features/aether/presentation/widgets/geo_raid_widget.dart';
import 'package:aether_cost_opt/features/aether/presentation/widgets/global_pulse_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/aether_user.dart';
import '../cubit/auth_cubit.dart';

// @AETHER: The main entry page combining all three critical systems.
// Single-screen layout as requested.

/// Main application screen containing all Aether systems.
class AetherPage extends StatelessWidget {
  const AetherPage({required this.user, super.key});
  
  final AetherUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AETHER'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // Using a Column for the main layout.
            // The Pulse and Raid widgets take up their natural size,
            // while the Chat widget expands to fill remaining space.
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const GlobalPulseWidget(),
                GeoRaidWidget(userId: user.id),
                Expanded(child: EngagementChatWidget(userId: user.id)),
              ],
            );
          },
        ),
      ),
    );
  }
}
