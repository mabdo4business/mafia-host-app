import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/describe.dart';
import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import 'bomb_panel.dart';

/// The morning after a night: read-aloud announcement, Bomb victims if the
/// Bomb died, and a host-only summary (actions, blocks, saves, Detective).
class MorningView extends ConsumerWidget {
  const MorningView({super.key, required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final describe = Describer(l, session.state);
    final round = session.latestRound;
    final pending = session.state.pendingBombs;
    final hostNotes = describe.hostNotes(round);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(16),
            children: [
              AnnouncementCard(lines: describe.announcement(round)),
              if (pending.isNotEmpty)
                BombPanel(key: ValueKey(pending.first), session: session, bombId: pending.first),
              if (hostNotes.isNotEmpty) HostOnlyCard(lines: hostNotes),
            ],
          ),
        ),
        BottomActions(
          children: [
            FilledButton.icon(
              key: const Key('startDay'),
              icon: const Icon(Icons.wb_sunny_outlined),
              label: Text(l.morningStartDay),
              onPressed: pending.isEmpty
                  ? () => ref.read(activeGameProvider.notifier).apply(const AdvanceInput())
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
