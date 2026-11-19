import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../ui/ui.dart';

/// The Chameleon picks the role they will play all game. The picked role
/// shows as a card preview; pops with the chosen [Role].
class ChameleonChoiceScreen extends StatefulWidget {
  const ChameleonChoiceScreen({super.key, required this.name, required this.choices, this.initial});

  final String name;
  final List<Role> choices;
  final Role? initial;

  @override
  State<ChameleonChoiceScreen> createState() => _ChameleonChoiceScreenState();
}

class _ChameleonChoiceScreenState extends State<ChameleonChoiceScreen> {
  late Role? _pick = widget.initial;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final pick = _pick;
    final accent = pick?.team == Team.mafia ? c.mafia : c.civilian;
    final chips = [
      for (final r in widget.choices)
        RoleChip(
          key: Key('chameleonPick_${r.name}'),
          glyph: roleGlyph(r),
          name: l.role(r),
          team: r.team,
          count: 1,
          showCount: false,
          selected: r == pick,
          onTap: () => setState(() => _pick = r),
        ),
    ];

    return PhaseScaffold(
      glow: Glow(color: c.tint(accent, pick == null ? 0.10 : 0.22), start: -100, end: null),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.xl),
        children: [
          Row(
            children: [
              IconCircleButton(
                glyph: MafiaGlyphs.back,
                semanticLabel: l.back,
                onPressed: () => Navigator.maybePop(context),
              ),
              const SizedBox(width: Space.md),
              Expanded(child: Text(l.chameleonChooseRole, style: context.type.headlineSmall)),
            ],
          ),
          const SizedBox(height: Space.lg),
          Text(
            l.chameleonIntro(widget.name),
            style: context.type.bodyMedium!.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.lg),
          for (var i = 0; i < chips.length; i += 2) ...[
            Row(
              children: [
                Expanded(child: chips[i]),
                const SizedBox(width: 10),
                Expanded(child: i + 1 < chips.length ? chips[i + 1] : const SizedBox()),
              ],
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: Space.md),
          Center(
            child: AnimatedSwitcher(
              duration: Motion.base,
              child: pick == null
                  ? SizedBox(
                      key: const ValueKey('none'),
                      height: 120,
                      child: Center(
                        child: Text(
                          l.chameleonPickHint,
                          style: context.type.bodyMedium!.copyWith(color: c.textMuted),
                        ),
                      ),
                    )
                  : FittedBox(
                      key: ValueKey(pick),
                      child: RoleCard(
                        revealed: true,
                        onTap: null,
                        team: pick.team,
                        teamLabel: pick.team == Team.mafia
                            ? l.teamLabelMafia
                            : l.teamLabelCivilians,
                        roleName: l.role(pick),
                        ability: l.ability(pick),
                        glyph: roleGlyph(pick),
                        backTitle: l.revealTapToReveal,
                        backHint: l.revealNoOneLooking,
                        semanticLabel: l.role(pick),
                      ),
                    ),
            ),
          ),
        ],
      ),
      bottom: PrimaryActionButton(
        key: const Key('chameleonConfirm'),
        label: pick == null ? l.chameleonPickHint : l.chameleonBecome(l.role(pick)),
        onPressed: pick == null ? null : () => Navigator.pop(context, pick),
      ),
    );
  }
}
