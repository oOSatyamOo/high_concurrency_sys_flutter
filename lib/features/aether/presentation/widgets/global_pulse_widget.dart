import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/color_palette.dart';
import '../cubit/world_boss_cubit.dart';

// @AETHER: The GlobalPulseWidget is wrapped in a RepaintBoundary.
// Since it updates every 100ms, isolating it prevents the rest of the
// widget tree (especially the chat list) from re-rendering and janking.

/// Displays the World Boss countdown timer updating at 100ms intervals.
class GlobalPulseWidget extends StatelessWidget {
  const GlobalPulseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        // The card itself gives the border and background
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder<WorldBossCubit, WorldBossState>(
            builder: (BuildContext context, WorldBossState state) {
              if (state is WorldBossInitial) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is WorldBossNoneActive) {
                return const Center(
                  child: Text(
                    'No World Boss Currently Active',
                    style: TextStyle(
                      color: ColorPalette.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              if (state is WorldBossActive) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'WORLD BOSS EVENT',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.boss.name,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 24),
                    _buildCountdown(context, state.remaining),
                    const SizedBox(height: 24),
                    LinearProgressIndicator(
                      value: state.progress,
                      minHeight: 8,
                      backgroundColor: ColorPalette.abyssCore,
                      color: ColorPalette.metallicGold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCountdown(BuildContext context, Duration remaining) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(remaining.inHours);
    final String minutes = twoDigits(remaining.inMinutes.remainder(60));
    final String seconds = twoDigits(remaining.inSeconds.remainder(60));
    final String tenths = (remaining.inMilliseconds.remainder(1000) ~/ 100)
        .toString();

    final TextStyle textStyle = Theme.of(context).textTheme.displayLarge!
        .copyWith(
          color: ColorPalette.metallicGold,
          // fontFeatures: const <import('dart:ui').FontFeature>[
          //   import('dart:ui').FontFeature.tabularFigures(),
          // ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text('$hours:$minutes:$seconds', style: textStyle),
        Text(
          '.$tenths',
          style: textStyle.copyWith(
            fontSize: 24,
            color: ColorPalette.metallicGold.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
