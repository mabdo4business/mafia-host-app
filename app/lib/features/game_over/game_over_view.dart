import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../../common/describe.dart';
import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../game_log/game_log_screen.dart';
import '../setup/setup_screen.dart';

/// Winner, what happened last, and every player's role.
class GameOverView extends ConsumerWidget {
  const GameOverView({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final winner = session.state.winner!;
    final color = teamColor(context, winner);
    final describe = Describer(l, session.state);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(16),
            children: [
              Card(
                key: const Key('winnerCard'),
                color: color.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: color, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 56, color: color),
                      const SizedBox(height: 8),
                      Text(
                        winner == Team.mafia ? l.winMafia : l.winCivilians,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnnouncementCard(lines: describe.announcement(session.latestRound)),
              SectionHeader(l.gameOverAllRoles),
              for (final p in session.state.players)
                Card(
                  child: ListTile(
                    leading: Icon(
                      p.isAlive ? Icons.favorite : Icons.close,
                      color: p.isAlive ? teamColor(context, p.team) : theme.colorScheme.outline,
                    ),
                    title: Text(
                      p.name,
                      style: p.isAlive ? null : TextStyle(color: theme.colorScheme.outline),
                    ),
                    subtitle: Text(p.isAlive ? l.statusAlive : l.statusDead),
                    trailing: RoleChip(p),
                  ),
                ),
            ],
          ),
        ),
        BottomActions(
          children: [
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const GameLogScreen()),
              ),
              child: Text(l.logTitle),
            ),
            FilledButton(
              key: const Key('playAgain'),
              onPressed: () {
                ref.read(activeGameProvider.notifier).close();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const SetupScreen()),
                );
              },
              child: Text(l.gameOverPlayAgain),
            ),
          ],
        ),
      ],
    );
  }
}
