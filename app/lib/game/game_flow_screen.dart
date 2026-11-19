import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../common/screen_awake.dart';
import '../features/day/day_result_view.dart';
import '../features/day/day_view.dart';
import '../features/game_over/game_over_view.dart';
import '../features/morning/morning_view.dart';
import '../features/night/night_wizard.dart';
import '../ui/ui.dart';
import 'game_session.dart';
import 'providers.dart';

/// Hosts the running game and shows the screen for its current stage.
///
/// Owns the sky: the night and day palettes switch with an [AnimatedTheme]
/// (`Motion.phaseChange`) while [PhaseSky] sets the moon and raises the sun,
/// so every stage view draws on a shared, animated background.
class GameFlowScreen extends ConsumerWidget {
  const GameFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(activeGameProvider).value;
    if (session == null) return const Scaffold();
    // Keyed by log length so per-stage UI state resets after every input
    // (including undo).
    final key = ValueKey(session.log.length);
    return GameStageFrame(
      session: session,
      // The host reads from the phone all game (night prompts,
      // announcements, the vote, the final reveal); don't let it dim or lock.
      child: KeepScreenOn(
        enabled: true,
        child: switch (session.stage) {
          GameStage.night => NightWizard(key: key, session: session),
          GameStage.morning => MorningView(key: key, session: session),
          GameStage.day => DayView(key: key, session: session),
          GameStage.dayResult => DayResultView(key: key, session: session),
          GameStage.gameOver => GameOverView(key: key, session: session),
        },
      ),
    );
  }
}

/// The phase theme, background and sky for [session]'s stage, around
/// [child] (a stage view drawn with a transparent PhaseScaffold).
class GameStageFrame extends StatelessWidget {
  const GameStageFrame({super.key, required this.session, required this.child});

  final GameSession session;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final sky = switch (session.stage) {
      GameStage.night => SkyPhase.night,
      // The sun rises once a dead Bomb has picked its victims.
      GameStage.morning when session.state.pendingBombs.isNotEmpty => SkyPhase.day,
      GameStage.morning => SkyPhase.dawn,
      GameStage.day || GameStage.dayResult => SkyPhase.day,
      GameStage.gameOver => session.state.winner == Team.mafia ? SkyPhase.night : SkyPhase.day,
    };
    final theme = sky == SkyPhase.night ? AppTheme.night(locale) : AppTheme.day(locale);
    final still = MediaQuery.disableAnimationsOf(context);

    return AnimatedTheme(
      data: theme,
      duration: still ? Duration.zero : Motion.phaseChange,
      curve: Motion.ease,
      child: Builder(
        builder: (context) {
          final c = context.mafia;
          return Material(
            color: c.bg,
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: still ? Duration.zero : Motion.phaseChange,
                    curve: Motion.ease,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: sky == SkyPhase.day
                            ? [c.bg, c.bg, c.bg]
                            : [c.bgTop, Color.lerp(c.bgTop, c.bg, 0.55)!, c.bg],
                        stops: const [0, 0.38, 1],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(child: PhaseSky(phase: sky)),
                Positioned.fill(child: child),
              ],
            ),
          );
        },
      ),
    );
  }
}
