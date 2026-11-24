import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';

/// A death that takes others, settled by the host before play goes on:
/// the voted-out Godfather takes one player or no one; a Bomb voted out on
/// day 1 (before planting) takes both neighbors or no one.
class ChoicePicker extends ConsumerStatefulWidget {
  const ChoicePicker({super.key, required this.session, required this.choice});

  final GameSession session;
  final PendingChoice choice;

  @override
  ConsumerState<ChoicePicker> createState() => _ChoicePickerState();
}

class _ChoicePickerState extends ConsumerState<ChoicePicker> {
  final List<String> _picked = [];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final state = widget.session.state;
    final owner = state.player(widget.choice.playerId);
    final godfather = widget.choice.kind == ChoiceKind.godfatherTakesOne;
    final accent = godfather ? c.mafia : c.bomb;
    final options = godfather
        ? [
            for (final p in state.alivePlayers)
              if (p.id != owner.id) p.id,
          ]
        : [
            for (final id in widget.choice.options)
              if (state.player(id).isAlive) id,
          ];
    String nameOf(String id) => state.player(id).name;

    void tap(String id) => setState(() {
      if (godfather) {
        final had = _picked.contains(id);
        _picked.clear();
        if (!had) _picked.add(id);
      } else {
        // Both neighbors go together, or no one.
        final all = _picked.isNotEmpty;
        _picked
          ..clear()
          ..addAll(all ? const [] : options);
      }
    });

    return PhaseScaffold(
      key: const Key('choicePanel'),
      transparent: true,
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.xl, Space.page, Space.lg),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.tint(accent, 0.16),
                borderRadius: BorderRadius.circular(Radii.iconBoxLg),
              ),
              child: MafiaIcon(
                godfather ? MafiaGlyphs.godfather : MafiaGlyphs.bomb,
                size: 26,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          Text(
            godfather ? l.choiceWasGodfather(owner.name) : l.bombWasTheBomb(owner.name),
            style: context.type.headlineMedium,
          ),
          const SizedBox(height: Space.sm),
          Text(
            godfather ? l.choiceGodfatherHint : l.choiceBombNeighborsHint,
            style: context.type.bodyMedium!.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.xl),
          PlayerTargetGrid(
            children: [
              for (final id in options)
                PlayerTile(
                  key: Key('choiceVictim_$id'),
                  name: nameOf(id),
                  accent: accent,
                  selected: _picked.contains(id),
                  onTap: () => tap(id),
                ),
            ],
          ),
        ],
      ),
      bottom: PrimaryActionButton(
        key: const Key('choiceConfirm'),
        label: _picked.isEmpty ? l.choiceTakeNoOne : l.choiceTake(l.names(_picked.map(nameOf))),
        tone: _picked.isEmpty
            ? ActionTone.neutral
            : (godfather ? ActionTone.danger : ActionTone.bomb),
        onPressed: () =>
            ref.read(activeGameProvider.notifier).apply(ChoiceInput(owner.id, List.of(_picked))),
      ),
    );
  }
}
