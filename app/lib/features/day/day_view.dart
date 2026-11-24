import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/game_input.dart';
import '../../game/game_menu.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

/// The day's parts, in order (GAME_RULES §2).
enum DayPart { freeChat, speeches, voting }

/// "Day 3 · Who is lying?": Free Chat (2:00) → each player's Speech (0:30,
/// +0:15 per Foul) in seat order → the vote → a re-vote between the tied
/// players. Silenced players skip all three. The host counts raised hands:
/// tap a player = one more vote.
class DayView extends ConsumerStatefulWidget {
  const DayView({
    super.key,
    required this.session,
    this.initialPart,
    this.initialSpeaker = 0,
    this.initialTally,
    this.random,
  });

  final GameSession session;

  /// Previews start on a part, a speaker, or with votes in.
  final DayPart? initialPart;
  final int initialSpeaker;
  final Map<String, int>? initialTally;

  /// Draws the lot when the re-vote ties under `randomAmongTied`.
  final Random? random;

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  late DayPart _part =
      widget.initialPart ??
      (widget.initialTally != null || widget.session.pendingTie != null
          ? DayPart.voting
          : DayPart.freeChat);
  late int _speaker = widget.initialSpeaker;

  /// The current speaker took a Foul and is on the extra 15 seconds.
  bool _onFoul = false;

  late final Map<String, int> _tally = {...?widget.initialTally};

  /// Tapped player ids, for "Undo last vote".
  final List<String> _history = [];

  GameState get _state => widget.session.state;
  int get _total => _tally.values.fold(0, (a, b) => a + b);
  int get _voters => _state.voterCount;

  /// Who speaks today: the living, unsilenced players in seat order.
  List<Player> get _speakers => [
    for (final p in _state.alivePlayers)
      if (!_state.isSilenced(p.id)) p,
  ];

  /// Who can be voted for: the tied players during a re-vote.
  List<Player> get _candidates {
    final tied = _state.revoteCandidates;
    return [
      for (final p in _state.alivePlayers)
        if (tied == null || tied.contains(p.id)) p,
    ];
  }

  void _vote(String id) {
    if (_total >= _voters) return;
    setState(() {
      _tally[id] = (_tally[id] ?? 0) + 1;
      _history.add(id);
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() {
      final id = _history.removeLast();
      _tally[id] = _tally[id]! - 1;
    });
  }

  void _submit(DayVoteInput input) => ref.read(activeGameProvider.notifier).apply(input);

  void _foul(Player p) {
    ref.read(activeGameProvider.notifier).apply(FoulInput(p.id));
    setState(() => _onFoul = true);
  }

  void _goToSpeaker(int i) => setState(() {
    _speaker = i;
    _onFoul = false;
  });

  /// One line under a player's name: silenced, fouls.
  String? _status(AppLocalizations l, Player p) {
    if (!p.isAlive) return l.statusEliminated;
    final fouls = _state.foulsOf(p.id);
    return [
      if (_state.isSilenced(p.id)) l.statusSilenced,
      if (fouls > 0) l.statusFouls(fouls),
    ].join(' · ').nullIfEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final session = widget.session;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Overline(l.stageDay(session.round), color: c.civilianSoft, wide: true),
              const SizedBox(height: Space.xs),
              Text(l.dayTitle, style: context.type.headlineMedium),
            ],
          ),
        ),
        GameMenuButton(session: session),
      ],
    );

    final (content, bottom) = switch (_part) {
      DayPart.freeChat => _freeChat(context),
      DayPart.speeches => _speeches(context),
      DayPart.voting => _voting(context),
    };

    return PhaseScaffold(
      transparent: true,
      bottomPadding: EdgeInsetsDirectional.fromSTEB(
        Space.page,
        Space.md,
        Space.page,
        MediaQuery.viewPaddingOf(context).bottom > 0
            ? (_part == DayPart.voting ? Space.lg : Space.bottomAction)
            : Space.lg,
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.lg),
        children: [
          header,
          const SizedBox(height: 22),
          SegmentedPill<DayPart>(
            key: const Key('dayTabs'),
            segments: [
              (DayPart.freeChat, l.dayFreeChat),
              (DayPart.speeches, l.daySpeeches),
              (DayPart.voting, l.dayVoting),
            ],
            selected: _part,
            onChanged: (v) => setState(() => _part = v),
          ),
          const SizedBox(height: 18),
          ...content,
        ],
      ),
      bottom: bottom,
    );
  }

  (List<Widget>, Widget) _freeChat(BuildContext context) {
    final l = context.l10n;
    final silenced = [
      for (final p in _state.alivePlayers)
        if (_state.isSilenced(p.id)) p.name,
    ];
    return (
      [
        GlassCard(
          radius: Radii.tile,
          child: TimedRow(
            key: const Key('freeChatTimer'),
            title: l.dayFreeChat,
            hint: l.dayFreeChatHint,
            timer: TalkTimer(seconds: _state.settings.freeChatSeconds),
          ),
        ),
        if (silenced.isNotEmpty) ...[
          const SizedBox(height: Space.md),
          Text(
            l.daySilencedToday(l.names(silenced)),
            key: const Key('silencedNote'),
            style: context.type.bodySmall,
          ),
        ],
        const SizedBox(height: Space.lg),
        _table(context),
      ],
      PrimaryActionButton(
        key: const Key('startSpeeches'),
        label: l.dayStartSpeeches,
        trailing: MafiaGlyphs.arrow,
        onPressed: () => setState(() {
          _part = DayPart.speeches;
          _goToSpeaker(0);
        }),
      ),
    );
  }

  /// Everyone in seat order with their state for the day.
  Widget _table(BuildContext context) {
    final l = context.l10n;
    return PlayerTargetGrid(
      children: [
        for (final p in _state.players)
          PlayerTile(
            key: Key('dayPlayer_${p.id}'),
            name: p.name,
            enabled: p.isAlive && !_state.isSilenced(p.id),
            struck: !p.isAlive,
            note: _status(l, p),
          ),
      ],
    );
  }

  (List<Widget>, Widget) _speeches(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final speakers = _speakers;
    if (speakers.isEmpty) {
      return ([Text(l.dayNoSpeakers, style: context.type.bodyMedium)], _startVotingButton(l));
    }
    final i = _speaker.clamp(0, speakers.length - 1);
    final current = speakers[i];
    final last = i == speakers.length - 1;
    final settings = _state.settings;
    final seconds = _onFoul ? settings.foulSeconds : settings.speechSeconds;

    return (
      [
        GlassCard(
          key: const Key('speechCard'),
          tintColor: c.primaryCta,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Overline(l.daySpeechCounter(i + 1, speakers.length), color: c.textMuted),
              const SizedBox(height: Space.sm),
              TimedRow(
                title: current.name,
                hint: _onFoul ? l.dayOnFoul : l.daySpeechHint,
                timer: TalkTimer(
                  key: ValueKey(('speech', current.id, _onFoul, _state.foulsOf(current.id))),
                  seconds: seconds,
                ),
              ),
              const SizedBox(height: Space.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.statusFouls(_state.foulsOf(current.id)),
                      key: const Key('foulCount'),
                      style: context.type.bodySmall,
                    ),
                  ),
                  GlassPillButton(
                    key: const Key('takeFoul'),
                    glyph: MafiaGlyphs.plus,
                    label: l.dayTakeFoul(settings.foulSeconds),
                    onPressed: () => _foul(current),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        Text(l.daySpeechOrder, style: context.type.bodySmall),
        const SizedBox(height: Space.md),
        PlayerTargetGrid(
          children: [
            for (final (j, p) in speakers.indexed)
              PlayerTile(
                key: Key('speaker_${p.id}'),
                name: p.name,
                accent: c.civilian,
                selected: j == i,
                struck: j < i,
                note: _status(l, p),
                onTap: () => _goToSpeaker(j),
              ),
          ],
        ),
      ],
      last
          ? _startVotingButton(l)
          : Row(
              children: [
                IconCircleButton.large(
                  glyph: MafiaGlyphs.back,
                  semanticLabel: l.dayPreviousSpeaker,
                  onPressed: i == 0 ? null : () => _goToSpeaker(i - 1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryActionButton(
                    key: const Key('nextSpeaker'),
                    label: l.dayNextSpeaker(speakers[i + 1].name),
                    trailing: MafiaGlyphs.arrow,
                    onPressed: () => _goToSpeaker(i + 1),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _startVotingButton(AppLocalizations l) => PrimaryActionButton(
    key: const Key('startVoting'),
    label: l.dayStartVoting,
    trailing: MafiaGlyphs.arrow,
    onPressed: () => setState(() => _part = DayPart.voting),
  );

  (List<Widget>, Widget) _voting(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final tie = widget.session.pendingTie;
    final candidates = _candidates;
    final top = _tally.values.fold(0, (a, b) => a > b ? a : b);
    final leaders = [
      for (final p in candidates)
        if (top > 0 && _tally[p.id] == top) p,
    ];
    final leader = leaders.length == 1 ? leaders.single : null;
    final silenced = [
      for (final p in _state.alivePlayers)
        if (_state.isSilenced(p.id)) p.name,
    ];

    final content = [
      if (tie != null) ...[
        _TieCard(
          entry: tie,
          state: _state,
          onDecide: (id) => _submit((tie.input as DayVoteInput).withTieBreaker(id)),
          onDraw: (tied) {
            final pick = tied[(widget.random ?? Random()).nextInt(tied.length)];
            _submit((tie.input as DayVoteInput).withTieBreaker(pick));
          },
        ),
        const SizedBox(height: Space.lg),
      ],
      Row(
        children: [
          Expanded(child: Text(l.dayTapToVote, style: context.type.bodySmall)),
          Text.rich(
            TextSpan(
              style: context.type.bodySmall,
              children: [
                TextSpan(
                  text: context.number(_total),
                  style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
                ),
                TextSpan(text: l.dayOfVoters(_voters)),
              ],
            ),
          ),
        ],
      ),
      if (silenced.isNotEmpty) ...[
        const SizedBox(height: Space.xs),
        Text(l.daySilencedNoVote(l.names(silenced)), style: context.type.bodySmall),
      ],
      const SizedBox(height: Space.md),
      for (final p in candidates) ...[
        VoteRow(
          key: Key('voteRow_${p.id}'),
          name: p.name,
          votes: _tally[p.id] ?? 0,
          total: _voters,
          leader: leader?.id == p.id,
          onTap: _total < _voters ? () => _vote(p.id) : null,
        ),
        const SizedBox(height: Space.sm),
      ],
    ];
    final tally = Map.of(_tally);
    final bottom = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_total == 0)
          PrimaryActionButton(
            key: const Key('skipVote'),
            label: l.daySkipVote,
            tone: ActionTone.neutral,
            onPressed: () => _submit(const TallyVoteInput({})),
          )
        else
          PrimaryActionButton(
            key: const Key('countVotes'),
            label: leader == null ? l.dayCountVotes : l.dayEliminate(leader.name),
            tone: leader == null ? ActionTone.phase : ActionTone.danger,
            onPressed: () => _submit(TallyVoteInput(tally)),
          ),
        const SizedBox(height: Space.sm),
        SizedBox(
          height: Sizes.iconButton,
          child: TextButton(
            key: const Key('undoVote'),
            onPressed: _history.isEmpty ? null : _undo,
            style: TextButton.styleFrom(foregroundColor: c.textMuted),
            child: Text(l.dayUndoVote),
          ),
        ),
      ],
    );
    return (content, bottom);
  }
}

extension on String {
  String? get nullIfEmpty => isEmpty ? null : this;
}

/// The vote tied: a re-vote between the tied players; if that ties too,
/// the host picks or draws lots (`secondTieRule`).
class _TieCard extends StatelessWidget {
  const _TieCard({
    required this.entry,
    required this.state,
    required this.onDecide,
    required this.onDraw,
  });

  final LogEntry entry;
  final GameState state;
  final ValueChanged<String> onDecide;
  final ValueChanged<List<String>> onDraw;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final tied = entry.events.whereType<VoteTied>().first.candidateIds;
    final names = l.names(tied.map((id) => state.player(id).name));
    final hostDecides = entry.events.any((e) => e is HostDecisionRequired);
    final drawLots = entry.events.any((e) => e is DrawLotsRequired);
    return GlassCard(
      key: const Key('tieCard'),
      tintColor: c.primaryCta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hostDecides
                ? l.dayTieHostDecides(names)
                : drawLots
                ? l.dayTieDrawLots(names)
                : l.dayTieRevote(names),
            style: context.type.bodyLarge,
          ),
          if (hostDecides) ...[
            const SizedBox(height: Space.md),
            PlayerTargetGrid(
              children: [
                for (final id in tied)
                  PlayerTile(
                    key: Key('tieBreak_$id'),
                    name: state.player(id).name,
                    accent: c.mafia,
                    onTap: () => onDecide(id),
                  ),
              ],
            ),
          ],
          if (drawLots) ...[
            const SizedBox(height: Space.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: GlassPillButton(
                key: const Key('drawLots'),
                glyph: MafiaGlyphs.shuffle,
                label: l.dayDrawLots,
                onPressed: () => onDraw(tied),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
