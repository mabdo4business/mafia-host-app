import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/l10n.dart';
import '../common/screen_awake.dart';
import '../common/widgets.dart';
import '../features/day/day_result_view.dart';
import '../features/day/day_view.dart';
import '../features/game_log/game_log_screen.dart';
import '../features/game_over/game_over_view.dart';
import '../features/morning/morning_view.dart';
import '../features/night/night_wizard.dart';
import 'game_session.dart';
import 'providers.dart';

/// Hosts the running game and shows the screen for its current stage.
class GameFlowScreen extends ConsumerWidget {
  const GameFlowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final session = ref.watch(activeGameProvider).value;
    if (session == null) return const Scaffold();
    final controller = ref.read(activeGameProvider.notifier);

    Future<void> undo() async {
      await controller.undo();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l.undoDone)));
      }
    }

    Future<void> endGame() async {
      if (!await confirm(
        context,
        title: l.endGameConfirmTitle,
        body: l.endGameConfirmBody,
        confirmLabel: l.menuEndGame,
      )) {
        return;
      }
      await controller.abandon();
      if (context.mounted) Navigator.popUntil(context, (route) => route.isFirst);
    }

    // Keyed by log length so per-stage UI state resets after every input
    // (including undo).
    final key = ValueKey(session.log.length);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.stageTitle(session)),
        actions: [
          IconButton(
            tooltip: l.logTitle,
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const GameLogScreen()),
            ),
          ),
          PopupMenuButton<VoidCallback>(
            onSelected: (action) => action(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: undo,
                enabled: session.canUndo,
                child: ListTile(leading: const Icon(Icons.undo), title: Text(l.menuUndo)),
              ),
              if (session.stage != GameStage.gameOver)
                PopupMenuItem(
                  value: endGame,
                  child: ListTile(
                    leading: const Icon(Icons.stop_circle_outlined),
                    title: Text(l.menuEndGame),
                  ),
                ),
            ],
          ),
        ],
      ),
      // The host reads from the phone all game (night prompts, announcements,
      // the vote, the final reveal); don't let it dim or lock.
      body: KeepScreenOn(
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
