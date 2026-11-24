// Debug-only: previews of every lib/ui component, shared by the /gallery
// route and the golden tests (test/ui/component_goldens_test.dart).
//
// Copy comes from the ARB files; only the sample player names are data.

import 'package:material_ui/material_ui.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../../common/l10n.dart';
import '../../ui/ui.dart';

/// One component preview.
class ComponentSample {
  const ComponentSample(this.id, this.build, {this.phase = Phase.night});

  /// File-safe id, also the golden file name.
  final String id;

  final WidgetBuilder build;

  /// The theme the component lives in.
  final Phase phase;
}

/// Sample table names, per language. A long name checks overflow.
List<String> sampleNames(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'ar'
    ? const [
        'ليلى',
        'عمر',
        'سارة',
        'خالد',
        'يوسف',
        'نور',
        'فيصل',
        'هدى',
        'علي',
        'مريم',
        'عبدالرحمن الشمري',
      ]
    : const [
        'Layla',
        'Omar',
        'Sara',
        'Khalid',
        'Yousef',
        'Noor',
        'Faisal',
        'Huda',
        'Ali',
        'Mariam',
        'Abdulrahman Al-Shammari',
      ];

Widget _gap([double h = Space.md]) => SizedBox(height: h);

final List<ComponentSample> componentCatalog = [
  ComponentSample('glass_card', (context) {
    final c = context.mafia;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(child: Text(context.l10n.setupPlayersSection, style: context.type.bodyLarge)),
        _gap(),
        GlassCard(
          tintColor: c.mafia,
          fillOpacity: 0.08,
          borderOpacity: 0.25,
          radius: Radii.hero,
          padding: const EdgeInsetsDirectional.all(Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TagPill(
                context.l10n.teamLabelMafia,
                color: c.mafia,
                textColor: c.mafiaSoft,
                dot: true,
              ),
              _gap(),
              AvatarStack(names: sampleNames(context).take(3).toList(), extra: 8),
            ],
          ),
        ),
      ],
    );
  }),
  ComponentSample('primary_action_button', (context) {
    final l = context.l10n;
    final name = sampleNames(context).first;
    return Column(
      children: [
        PrimaryActionButton(label: l.actionSave(name), onPressed: () {}),
        _gap(),
        PrimaryActionButton(
          label: l.setupShuffleDeal,
          tone: ActionTone.danger,
          trailing: MafiaGlyphs.shuffle,
          onPressed: () {},
        ),
        _gap(),
        PrimaryActionButton(label: l.revealPassNext, tone: ActionTone.neutral, onPressed: () {}),
        _gap(),
        PrimaryActionButton(
          label: l.choiceTake(sampleNames(context)[1]),
          tone: ActionTone.bomb,
          onPressed: () {},
        ),
        _gap(),
        PrimaryActionButton(label: l.nightPickToSave, onPressed: null),
      ],
    );
  }),
  ComponentSample('icon_circle_button', (context) {
    final l = context.l10n;
    return Row(
      children: [
        IconCircleButton(glyph: MafiaGlyphs.back, semanticLabel: l.back, onPressed: () {}),
        const SizedBox(width: Space.md),
        IconCircleButton(
          glyph: MafiaGlyphs.bell,
          semanticLabel: l.notifications,
          badge: true,
          onPressed: () {},
        ),
        const SizedBox(width: Space.md),
        IconCircleButton.large(glyph: MafiaGlyphs.back, semanticLabel: l.back, onPressed: () {}),
        const SizedBox(width: Space.md),
        IconCircleButton.large(
          glyph: MafiaGlyphs.speaker,
          semanticLabel: l.readAloud,
          filled: true,
          onPressed: () {},
        ),
      ],
    );
  }),
  ComponentSample('phase_header', (context) {
    final l = context.l10n;
    return Column(
      children: [
        PhaseHeader(
          phase: Phase.night,
          title: l.stageNight(3),
          actionLabel: l.logTitle,
          onAction: () {},
        ),
        _gap(Space.xl),
        PhaseHeader(
          phase: Phase.day,
          title: l.stageDay(3),
          actionLabel: l.logTitle,
          onAction: () {},
        ),
      ],
    );
  }),
  ComponentSample('step_rail', (context) {
    final l = context.l10n;
    return StepRail(steps: [for (final r in nightRoles) l.role(r)], current: 4);
  }),
  ComponentSample('prompt_card', (context) {
    final l = context.l10n;
    final c = context.mafia;
    return Column(
      children: [
        PromptCard(
          glyph: MafiaGlyphs.doctor,
          title: l.nightWakeTitleDoctor,
          line: l.nightLineDoctor,
        ),
        _gap(),
        PromptCard(
          glyph: MafiaGlyphs.mafia,
          title: l.nightWakeTitleMafia,
          line: l.nightLineMafia,
          accent: c.mafia,
          footer: Text(
            l.nightBlockedShort,
            style: context.type.bodySmall!.copyWith(color: c.mafiaSoft),
          ),
        ),
      ],
    );
  }),
  ComponentSample('player_tile', (context) {
    final l = context.l10n;
    final c = context.mafia;
    final n = sampleNames(context);
    return PlayerTargetGrid(
      children: [
        PlayerTile(name: n[0], onTap: () {}),
        PlayerTile(name: n[1], selected: true, onTap: () {}),
        PlayerTile(name: n[3], enabled: false, struck: true, note: l.statusEliminated),
        PlayerTile(name: n[5], enabled: false, note: l.nightDoctorTwoNights),
        PlayerTile(name: n[2], selected: true, accent: c.mafia, dots: 2, onTap: () {}),
        PlayerTile(name: n[10], onTap: () {}),
      ],
    );
  }),
  ComponentSample('player_target_grid', (context) => const _GridDemo()),
  ComponentSample('role_chip', (context) {
    final l = context.l10n;
    Widget chip(Role r, int count, {bool selected = false}) => RoleChip(
      glyph: roleGlyph(r),
      name: l.role(r),
      team: r.team,
      count: count,
      selected: selected,
      onTap: () {},
      onLongPress: () {},
    );
    return Column(
      children: [
        for (final row in [
          [chip(Role.godfather, 1), chip(Role.mafia, 0)],
          [chip(Role.doctor, 1), chip(Role.civilian, 3)],
          [chip(Role.detective, 1, selected: true), chip(Role.chameleon, 0)],
        ]) ...[
          Row(
            children: [
              Expanded(child: row[0]),
              const SizedBox(width: 10),
              Expanded(child: row[1]),
            ],
          ),
          _gap(10),
        ],
      ],
    );
  }),
  ComponentSample('team_balance_bar', (context) {
    final l = context.l10n;
    return Column(
      children: [
        TeamBalanceBar(mafia: 3, civilians: 8, note: l.setupBalancedFor(11)),
        _gap(Space.xl),
        TeamBalanceBar(
          mafia: 4,
          civilians: 4,
          note: l.setupProblemMafiaTooStrongShort,
          warning: true,
        ),
      ],
    );
  }),
  ComponentSample('segmented_pill', (context) => const _PillDemo()),
  ComponentSample(
    'role_card_back',
    (context) => Center(child: _card(context, Role.godfather, false)),
  ),
  ComponentSample(
    'role_card_mafia',
    (context) => Center(child: _card(context, Role.godfather, true)),
  ),
  ComponentSample(
    'role_card_civilian',
    (context) => Center(child: _card(context, Role.doctor, true)),
  ),
  ComponentSample('role_card_flip', (context) => const Center(child: _FlipDemo())),
  ComponentSample('announcement_item', phase: Phase.day, (context) {
    final l = context.l10n;
    final n = sampleNames(context);
    return Column(
      children: [
        AnnouncementItem(
          index: 1,
          kind: AnnouncementKind.death,
          headline: l.announceKilled(n[4]),
          detail: l.announceRoleSecret,
        ),
        _gap(10),
        AnnouncementItem(
          index: 2,
          kind: AnnouncementKind.bomb,
          headline: l.announceBomb(n[6]),
          detail: l.announceBombTakes(2),
          chips: [n[8], n[7]],
        ),
        _gap(10),
        AnnouncementItem(
          index: 3,
          kind: AnnouncementKind.save,
          headline: l.announceSomeoneSaved,
          detail: l.announceDontSayWho,
        ),
      ],
    );
  }),
  ComponentSample('host_only_note', phase: Phase.day, (context) {
    final l = context.l10n;
    final name = sampleNames(context)[1];
    return HostOnlyNote(text: l.hostOnlyDetective(name, l.resultCivilian), highlight: name);
  }),
  ComponentSample('vote_row', phase: Phase.day, (context) => const _VoteDemo()),
  ComponentSample('countdown_ring', phase: Phase.day, (context) {
    final l = context.l10n;
    return Row(
      children: [
        CountdownRing(
          remaining: const Duration(seconds: 102),
          total: const Duration(minutes: 3),
          label: l.timeLeft,
        ),
        const SizedBox(width: Space.xl),
        CountdownRing(
          remaining: Duration.zero,
          total: const Duration(minutes: 3),
          label: l.timeLeft,
        ),
      ],
    );
  }),
  ComponentSample('stat_tile', (context) {
    final l = context.l10n;
    final c = context.mafia;
    return Row(
      children: [
        Expanded(
          child: StatTile(value: context.number(48), label: l.statGames),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatTile(value: l.percent(46), label: l.statMafiaWins, tint: c.mafia),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: StatTile(value: l.percent(54), label: l.statCivilianWins, tint: c.civilian),
        ),
      ],
    );
  }),
];

/// The roles that act at night, in wake-up order.
const nightRoles = [
  Role.putana,
  Role.lawyer,
  Role.mafia,
  Role.witch,
  Role.joker,
  Role.silencer,
  Role.doctor,
  Role.shapeshifter,
  Role.detective,
  Role.bomb,
  Role.chameleon,
  Role.switchman,
];

Widget _card(BuildContext context, Role role, bool revealed, {VoidCallback? onTap}) {
  final l = context.l10n;
  final n = sampleNames(context);
  final mafia = role.team == Team.mafia;
  return RoleCard(
    revealed: revealed,
    onTap: onTap,
    team: role.team,
    teamLabel: mafia ? l.teamLabelMafia : l.teamLabelCivilians,
    roleName: l.role(role),
    ability: l.ability(role),
    glyph: roleGlyph(role),
    backTitle: l.revealTapToReveal,
    backHint: l.revealNoOneLooking,
    semanticLabel: revealed ? l.hideRole : l.revealRole,
    familyLabel: l.revealYourFamily,
    family: mafia
        ? [l.familyMember(n[1], l.rolePutana), l.familyMember(n[2], l.roleLawyer)]
        : const [],
  );
}

class _FlipDemo extends StatefulWidget {
  const _FlipDemo();

  @override
  State<_FlipDemo> createState() => _FlipDemoState();
}

class _FlipDemoState extends State<_FlipDemo> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) => _card(
    context,
    Role.godfather,
    _revealed,
    onTap: () => setState(() => _revealed = !_revealed),
  );
}

class _GridDemo extends StatefulWidget {
  const _GridDemo();

  @override
  State<_GridDemo> createState() => _GridDemoState();
}

class _GridDemoState extends State<_GridDemo> {
  int? _pick = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final names = sampleNames(context);
    return PlayerTargetGrid(
      children: [
        for (final (i, n) in names.indexed)
          PlayerTile(
            name: n,
            selected: _pick == i,
            enabled: i != 3 && i != 5,
            struck: i == 3,
            note: i == 3 ? l.statusEliminated : (i == 5 ? l.nightDoctorTwoNights : null),
            onTap: () => setState(() => _pick = i),
          ),
      ],
    );
  }
}

class _PillDemo extends StatefulWidget {
  const _PillDemo();

  @override
  State<_PillDemo> createState() => _PillDemoState();
}

class _PillDemoState extends State<_PillDemo> {
  bool _phones = false;
  int _bomb = 3;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedPill<bool>(
          segments: [(false, l.modeHostOnly), (true, l.modePlayersPhones)],
          selected: _phones,
          onChanged: (v) => setState(() => _phones = v),
        ),
        _gap(Space.lg),
        SegmentedPill<int>(
          dense: true,
          segments: [(2, context.number(2)), (3, context.number(3))],
          selected: _bomb,
          onChanged: (v) => setState(() => _bomb = v),
        ),
      ],
    );
  }
}

class _VoteDemo extends StatefulWidget {
  const _VoteDemo();

  @override
  State<_VoteDemo> createState() => _VoteDemoState();
}

class _VoteDemoState extends State<_VoteDemo> {
  final _votes = [3, 2, 1];

  @override
  Widget build(BuildContext context) {
    final names = sampleNames(context);
    final top = _votes.reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        for (final (i, v) in _votes.indexed) ...[
          VoteRow(
            name: names[i + 1],
            votes: v,
            total: 6,
            leader: v == top && _votes.where((x) => x == top).length == 1,
            onTap: () => setState(() => _votes[i]++),
          ),
          _gap(Space.sm),
        ],
      ],
    );
  }
}
