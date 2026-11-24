import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/game_flow_screen.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../game/role_mix.dart';
import '../../ui/ui.dart';

/// Cards mode: the host has handed out physical cards. On night 1 each card
/// wakes in turn and the host taps who holds it; everyone left over holds a
/// Civilian card. A check screen lists every card, then night 1 begins.
class AssignCardsScreen extends ConsumerStatefulWidget {
  const AssignCardsScreen({
    super.key,
    required this.names,
    required this.mix,
    required this.settings,
    this.initialStep = 0,
    this.initialCards = const {},
  });

  final List<String> names;
  final Map<Role, int> mix;
  final GameSettings settings;

  /// Previews: start on a step (the role count = the check screen) with
  /// cards already recorded (seat index → role).
  final int initialStep;
  final Map<int, Role> initialCards;

  @override
  ConsumerState<AssignCardsScreen> createState() => _AssignCardsScreenState();
}

class _AssignCardsScreenState extends ConsumerState<AssignCardsScreen> {
  late final List<Role> _roles = cardWakeOrder(widget.mix);
  late int _step = widget.initialStep.clamp(0, _roles.length);
  late final Map<int, Role> _cards = {...widget.initialCards};
  bool _starting = false;

  bool get _checking => _step >= _roles.length;

  int _count(Role role) => widget.mix[role] ?? 0;

  List<int> _holders(Role role) => [
    for (var i = 0; i < widget.names.length; i++)
      if (_cards[i] == role) i,
  ];

  void _toggle(int seat, Role role) => setState(() {
    if (_cards[seat] == role) {
      _cards.remove(seat);
      return;
    }
    final holders = _holders(role);
    if (holders.length >= _count(role)) {
      // A single card moves to the newly tapped player; with several,
      // the host untaps one first.
      if (_count(role) != 1) return;
      _cards.remove(holders.single);
    }
    _cards[seat] = role;
  });

  void _next() => setState(() => _step++);

  Future<void> _start() async {
    setState(() => _starting = true);
    final setup = GameSetup(
      settings: widget.settings,
      players: playersFromCards(widget.names, _cards),
    );
    await ref.read(activeGameProvider.notifier).start(setup);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute<void>(builder: (_) => const GameFlowScreen()),
      (route) => route.isFirst,
    );
  }

  String _cardName(int seat) => context.l10n.role(_cards[seat]!);

  Color _accent(Role role) =>
      role.team == Team.mafia ? context.mafia.mafia : context.mafia.civilian;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final accent = _checking ? c.civilian : _accent(_roles[_step]);
    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: PhaseScaffold(
        glow: Glow(color: c.tint(accent, 0.18), start: -100, end: null, top: -160, size: 420),
        body: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.lg),
          children: [
            Row(
              children: [
                IconCircleButton(
                  glyph: MafiaGlyphs.back,
                  semanticLabel: l.back,
                  onPressed: () => Navigator.maybePop(context),
                ),
                const SizedBox(width: Space.md),
                Expanded(child: Overline(l.cardsOverline, color: c.textMuted)),
              ],
            ),
            const SizedBox(height: 18),
            StepRail(steps: [for (final r in _roles) l.role(r), l.cardsReviewStep], current: _step),
            const SizedBox(height: 18),
            if (_checking) ..._check(context) else ..._wake(context, _roles[_step]),
          ],
        ),
        bottom: _checking
            ? PrimaryActionButton(
                key: const Key('cardsStart'),
                label: l.dealStartGame,
                onPressed: _starting ? null : _start,
              )
            : _wakeAction(context, _roles[_step]),
      ),
    );
  }

  List<Widget> _wake(BuildContext context, Role role) {
    final l = context.l10n;
    final accent = _accent(role);
    return [
      PromptCard(
        glyph: roleGlyph(role),
        title: l.cardsWake(l.role(role)),
        line: l.cardsLine,
        accent: accent,
        footer: Text(
          l.cardsPicked(_holders(role).length, _count(role)),
          key: const Key('cardsPicked'),
          style: context.type.bodySmall,
        ),
      ),
      const SizedBox(height: 18),
      PlayerTargetGrid(
        children: [
          for (final (i, name) in widget.names.indexed)
            if (_cards[i] case final other? when other != role)
              PlayerTile(
                key: Key('cardSeat_$i'),
                name: name.trim(),
                enabled: false,
                note: _cardName(i),
              )
            else
              PlayerTile(
                key: Key('cardSeat_$i'),
                name: name.trim(),
                accent: accent,
                selected: _cards[i] == role,
                onTap: () => _toggle(i, role),
              ),
        ],
      ),
    ];
  }

  Widget _wakeAction(BuildContext context, Role role) {
    final l = context.l10n;
    final last = _step == _roles.length - 1;
    final done = _holders(role).length == _count(role);
    final label = last ? l.cardsReviewCheck : l.cardsNextRole(l.role(_roles[_step + 1]));
    final button = PrimaryActionButton(
      key: const Key('cardsNext'),
      label: label,
      tone: role.team == Team.mafia ? ActionTone.danger : ActionTone.phase,
      trailing: MafiaGlyphs.arrow,
      onPressed: done ? _next : null,
    );
    if (_step == 0) return button;
    return Row(
      children: [
        IconCircleButton.large(
          glyph: MafiaGlyphs.back,
          semanticLabel: l.nightPreviousStep,
          onPressed: () => setState(() => _step--),
        ),
        const SizedBox(width: 10),
        Expanded(child: button),
      ],
    );
  }

  List<Widget> _check(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final civilians = [
      for (final (i, name) in widget.names.indexed)
        if (!_cards.containsKey(i)) name.trim(),
    ];

    Widget row({
      required Key key,
      required Role role,
      required String title,
      required List<String> names,
      VoidCallback? onTap,
    }) {
      final mafia = role.team == Team.mafia;
      return Padding(
        padding: const EdgeInsetsDirectional.only(bottom: 10),
        child: GlassCard(
          key: key,
          radius: Radii.tile,
          padding: const EdgeInsetsDirectional.all(14),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.tint(mafia ? c.mafia : c.civilian, 0.16),
                  borderRadius: BorderRadius.circular(Radii.iconBox),
                ),
                child: MafiaIcon(roleGlyph(role), color: mafia ? c.mafiaSoft : c.civilianSoft),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.type.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(l.names(names), style: context.type.bodySmall),
                  ],
                ),
              ),
              if (onTap != null) MafiaIcon(MafiaGlyphs.forward, size: 18, color: c.textMuted),
            ],
          ),
        ),
      );
    }

    return [
      Text(l.cardsReviewTitle, style: context.type.headlineMedium),
      const SizedBox(height: Space.sm),
      Text(l.cardsReviewHint, style: context.type.bodyMedium!.copyWith(color: c.textMuted)),
      const SizedBox(height: Space.lg),
      for (final (i, role) in _roles.indexed)
        row(
          key: Key('cardsCheck_${role.name}'),
          role: role,
          title: l.role(role),
          names: [for (final seat in _holders(role)) widget.names[seat].trim()],
          onTap: () => setState(() => _step = i),
        ),
      if (civilians.isNotEmpty)
        row(
          key: const Key('cardsCheck_civilian'),
          role: Role.civilian,
          title: l.teamCivilians,
          names: civilians,
        ),
    ];
  }
}
