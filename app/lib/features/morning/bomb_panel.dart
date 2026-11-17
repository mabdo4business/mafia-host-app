import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/l10n.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';

/// A triggered Bomb picks its victims. Used after a night and after a vote.
class BombPanel extends ConsumerStatefulWidget {
  const BombPanel({super.key, required this.session, required this.bombId});

  final GameSession session;
  final String bombId;

  @override
  ConsumerState<BombPanel> createState() => _BombPanelState();
}

class _BombPanelState extends ConsumerState<BombPanel> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final state = widget.session.state;
    final required = state.bombVictimsRequired;
    final alive = state.alivePlayers;

    return Card(
      key: const Key('bombPanel'),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: theme.colorScheme.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.bombPick(state.player(widget.bombId).name, required),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in alive)
                  FilterChip(
                    key: Key('bombVictim_${p.id}'),
                    label: Text(p.name),
                    selected: _selected.contains(p.id),
                    onSelected: (on) => setState(() {
                      if (!on) {
                        _selected.remove(p.id);
                      } else if (_selected.length < required) {
                        _selected.add(p.id);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('detonate'),
              style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
              icon: const Icon(Icons.flare),
              label: Text(
                l.bombDetonate(context.number(_selected.length), context.number(required)),
              ),
              onPressed: _selected.length == required
                  ? () => ref
                        .read(activeGameProvider.notifier)
                        .apply(
                          BombInput(widget.bombId, [
                            for (final p in alive)
                              if (_selected.contains(p.id)) p.id,
                          ]),
                        )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
