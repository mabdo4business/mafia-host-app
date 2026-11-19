import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';

/// A dead Bomb picks the players who go down with them. Shown in the
/// current phase (after a night or after a vote), in the Bomb's orange.
class BombPicker extends ConsumerStatefulWidget {
  const BombPicker({super.key, required this.session, required this.bombId});

  final GameSession session;
  final String bombId;

  @override
  ConsumerState<BombPicker> createState() => _BombPickerState();
}

class _BombPickerState extends ConsumerState<BombPicker> {
  final List<String> _picked = [];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final state = widget.session.state;
    final required = state.bombVictimsRequired;
    final full = _picked.length == required;

    return PhaseScaffold(
      key: const Key('bombPanel'),
      transparent: true,
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.xl, Space.page, Space.lg),
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.tint(c.bomb, 0.16),
                  borderRadius: BorderRadius.circular(Radii.iconBoxLg),
                ),
                child: MafiaIcon(MafiaGlyphs.bomb, size: 26, color: c.bomb),
              ),
              const Spacer(),
              Container(
                key: const Key('bombCounter'),
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 14, vertical: Space.sm),
                decoration: BoxDecoration(
                  color: full ? c.bomb : c.tint(c.bomb, 0.16),
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Text(
                  l.bombCounter(context.number(_picked.length), context.number(required)),
                  textDirection: TextDirection.ltr,
                  style: context.type.labelMedium!.copyWith(
                    color: full ? c.onAccent(c.bomb) : c.bomb,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          Text(
            l.bombWasTheBomb(state.player(widget.bombId).name),
            style: context.type.headlineMedium,
          ),
          const SizedBox(height: Space.sm),
          Text(
            l.bombChoose(required),
            style: context.type.bodyMedium!.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.xl),
          PlayerTargetGrid(
            children: [
              for (final p in state.alivePlayers)
                PlayerTile(
                  key: Key('bombVictim_${p.id}'),
                  name: p.name,
                  accent: c.bomb,
                  selected: _picked.contains(p.id),
                  enabled: _picked.contains(p.id) || !full,
                  onTap: () => setState(() {
                    if (!_picked.remove(p.id) && !full) _picked.add(p.id);
                  }),
                ),
            ],
          ),
        ],
      ),
      bottom: PrimaryActionButton(
        key: const Key('detonate'),
        label: full ? l.bombDetonateShort : l.bombChoose(required - _picked.length),
        tone: ActionTone.bomb,
        trailing: MafiaGlyphs.bomb,
        onPressed: full
            ? () => ref
                  .read(activeGameProvider.notifier)
                  .apply(
                    BombInput(widget.bombId, [
                      for (final p in state.alivePlayers)
                        if (_picked.contains(p.id)) p.id,
                    ]),
                  )
            : null,
      ),
    );
  }
}
