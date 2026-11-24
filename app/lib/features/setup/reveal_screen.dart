import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/game_flow_screen.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../game/role_mix.dart';
import '../../ui/ui.dart';

/// Pass-the-phone deal: each player in seating order taps the face-down card
/// to see their role, then hides it and passes the phone on. (A Chameleon
/// chooses on night 3.) After the last player, night 1 begins.
class RevealScreen extends ConsumerStatefulWidget {
  const RevealScreen({
    super.key,
    required this.names,
    required this.mix,
    required this.settings,
    this.random,
    this.dealt,
    this.initialIndex = 0,
    this.initiallyRevealed = false,
  });

  final List<String> names;
  final Map<Role, int> mix;
  final GameSettings settings;

  /// Injected in tests and previews for a predictable deal.
  final Random? random;

  /// A fixed deal instead of shuffling (previews).
  final List<Player>? dealt;

  /// Start partway through (previews).
  final int initialIndex;
  final bool initiallyRevealed;

  @override
  ConsumerState<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends ConsumerState<RevealScreen> {
  late final List<Player> _players =
      widget.dealt ?? dealRoles(widget.names, widget.mix, widget.random ?? Random.secure());
  late int _index = widget.initialIndex;
  late bool _revealed = widget.initiallyRevealed;
  bool _starting = false;

  Player get _player => _players[_index];
  bool get _isLast => _index == _players.length - 1;

  Future<void> _next() async {
    if (!_isLast) {
      setState(() {
        _index++;
        _revealed = false;
      });
      return;
    }
    setState(() => _starting = true);
    final setup = GameSetup(settings: widget.settings, players: _players);
    await ref.read(activeGameProvider.notifier).start(setup);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const GameFlowScreen()),
      (route) => route.isFirst,
    );
  }

  /// The Mafia's teammates ("Omar · Putana"), shown on Mafia cards.
  List<String> _family(Role played) {
    if (played.team != Team.mafia) return const [];
    final l = context.l10n;
    return [
      for (final p in _players)
        if (p.id != _player.id)
          if (p.role.team == Team.mafia) l.familyMember(p.name, l.role(p.role)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final p = _player;
    final shown = p.role;
    final teamColor = shown.team == Team.mafia ? c.mafia : c.civilian;

    return PhaseScaffold(
      glow: Glow(
        color: _revealed ? c.tint(teamColor, 0.30) : c.tint(c.civilian, 0.10),
        top: 200,
        size: 480,
        start: (MediaQuery.sizeOf(context).width - 480) / 2,
        fade: 0.65,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, 0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Overline(l.revealDealing, color: c.textMuted)),
                Text(l.revealProgress(_index + 1, _players.length), style: context.type.bodySmall),
              ],
            ),
            const SizedBox(height: 14),
            _Progress(
              count: _players.length,
              index: _index,
              current: _revealed ? teamColor : c.textMuted,
            ),
            const SizedBox(height: Space.xl),
            Text(l.revealHandTo, style: context.type.bodyMedium!.copyWith(color: c.textMuted)),
            const SizedBox(height: 6),
            Text(
              p.name,
              key: const Key('revealName'),
              textAlign: TextAlign.center,
              style: context.type.headlineLarge!.copyWith(fontSize: TextSizes.reveal),
            ),
            const SizedBox(height: 28),
            RoleCard(
              key: const Key('roleCard'),
              revealed: _revealed,
              onTap: () => setState(() => _revealed = !_revealed),
              team: shown.team,
              teamLabel: shown.team == Team.mafia ? l.teamLabelMafia : l.teamLabelCivilians,
              roleName: l.role(shown),
              ability: l.ability(shown),
              glyph: roleGlyph(shown),
              backTitle: l.revealTapToReveal,
              backHint: l.revealNoOneLooking,
              semanticLabel: _revealed ? l.hideRole : l.revealRole,
              familyLabel: l.revealYourFamily,
              family: _family(shown),
            ),
            const SizedBox(height: Space.lg),
          ],
        ),
      ),
      bottom: SizedBox(
        height: Sizes.primaryButton,
        child: AnimatedSwitcher(
          duration: Motion.base,
          child: !_revealed
              ? Center(
                  key: const ValueKey('hint'),
                  child: Text(
                    l.revealHint,
                    style: context.type.bodyMedium!.copyWith(color: c.textMuted),
                  ),
                )
              : PrimaryActionButton(
                  key: const Key('revealNext'),
                  label: _isLast ? l.dealStartGame : l.revealPassNext,
                  tone: _isLast ? ActionTone.phase : ActionTone.neutral,
                  onPressed: _starting ? null : _next,
                ),
        ),
      ),
    );
  }
}

/// One 4 px segment per player: done = light, current = team color once
/// revealed, upcoming = faint.
class _Progress extends StatelessWidget {
  const _Progress({required this.count, required this.index, required this.current});

  final int count, index;
  final Color current;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: Space.xs),
          Expanded(
            child: AnimatedContainer(
              duration: Motion.base,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i < index
                    ? c.text
                    : i == index
                    ? current
                    : c.veil(0.12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
