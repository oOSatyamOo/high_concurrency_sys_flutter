import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../core/theme/color_palette.dart';
import '../cubit/raid_cubit.dart';

// @AETHER: GeoRaidWidget displays available slots and Join action.
// Uses BlocBuilder to respond to the real-time slot counter.

/// Displays raid slots and the "Join Raid" action.
class GeoRaidWidget extends StatefulWidget {
  const GeoRaidWidget({required this.userId, super.key});
  
  final String userId;

  @override
  State<GeoRaidWidget> createState() => _GeoRaidWidgetState();
}

class _GeoRaidWidgetState extends State<GeoRaidWidget> {

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocConsumer<RaidCubit, RaidState>(
          listener: (BuildContext context, RaidState state) {
            if (state is RaidActive && state.joinError != null && state.joinError!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.joinError!),
                  backgroundColor: ColorPalette.statusError,
                ),
              );
            }
          },
          builder: (BuildContext context, RaidState state) {
            if (state is RaidInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RaidError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is RaidActive) {
              final int available = state.raid.availableSlots;
              final bool isFull = state.raid.isFull;
              final bool hasJoined = state.raid.hasJoined(widget.userId);
              final bool isJoining = state.isJoining;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'GEO-RAID INITIATED',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: ColorPalette.neonCyan,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Slots display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: <Widget>[
                      Text(
                        '${state.raid.currentSlots}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: isFull ? ColorPalette.statusError : ColorPalette.textPrimary,
                            ),
                      ),
                      Text(
                        ' / ${state.raid.maxSlots}',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: ColorPalette.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  
                  Text(
                    isFull ? 'RAID FULL' : '$available slots remaining',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isFull ? ColorPalette.statusError : ColorPalette.neonCyan,
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Join Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isFull || hasJoined || isJoining)
                          ? null
                          : () {
                              context.read<RaidCubit>().joinRaid(widget.userId);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasJoined 
                            ? ColorPalette.statusSuccess 
                            : ColorPalette.neonCyan,
                      ),
                      child: isJoining
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: ColorPalette.abyssCore)
                            )
                          : Text(
                              hasJoined ? 'SLOT SECURED' : 'JOIN RAID',
                            ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
