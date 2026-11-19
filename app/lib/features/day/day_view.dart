import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/game_input.dart';
import '../../game/game_menu.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';

/// "Day 3 · Who is lying?": discussion (with the optional timer) and the
/// vote. The host counts raised hands: tap a player = one more vote.
class DayView extends ConsumerStatefulWidget {
  const DayView({super.key, required this.session, this.initialTally});

  final GameSession session;

  /// Previews start with votes in.
  final Map<String, int>? initialTally;

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  late final Map<String, int> _tally = {...?widget.initialTally};

  /// Tapped player ids, for "Undo last vote".
  final List<String> _history = [];
  late bool _voting = widget.initialTally != null || widget.session.pendingTie != null;

  late int _remaining = widget.session.setup.discussionSeconds;
  Timer? _timer;

  int get _total => _tally.values.fold(0, (a, b) => a + b);
  int get _voters => widget.session.state.alivePlayers.length;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() => _timer = null);
      return;
    }
    if (_remaining <= 0) _remaining = widget.session.setup.discussionSeconds;
    setState(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _remaining--);
        if (_remaining <= 0) {
          t.cancel();
          setState(() => _timer = null);
          Haptics.heavy();
        }
      });
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _remaining = widget.session.setup.discussionSeconds;
    });
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

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final session = widget.session;
    final state = session.state;
    final seconds = session.setup.discussionSeconds;
    final tie = session.pendingTie;

    final top = _tally.values.fold(0, (a, b) => a > b ? a : b);
    final leaders = [
      for (final p in state.alivePlayers)
        if (top > 0 && _tally[p.id] == top) p,
    ];
    final leader = leaders.length == 1 ? leaders.single : null;

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
        if (seconds > 0) ...[
          const SizedBox(width: Space.md),
          CountdownRing(
            key: const Key('countdown'),
            remaining: Duration(seconds: _remaining.clamp(0, seconds)),
            total: Duration(seconds: seconds),
            label: _remaining <= 0
                ? l.timerDone
                : _timer == null
                ? l.timerPaused
                : l.timeLeft,
            semanticLabel: _timer == null ? l.timerStart : l.timerPause,
            onTap: _toggleTimer,
          ),
        ],
      ],
    );

    final List<Widget> content;
    final Widget bottom;
    if (!_voting) {
      content = [
        if (seconds > 0)
          GlassCard(
            radius: Radii.tile,
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: Space.lg,
              vertical: Space.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _remaining <= 0 ? l.timerDone : l.dayTimerHint,
                    style: context.type.bodySmall,
                  ),
                ),
                TextButton(
                  key: const Key('timerToggle'),
                  onPressed: _toggleTimer,
                  child: Text(_timer == null ? l.timerStart : l.timerPause),
                ),
                TextButton(
                  onPressed: _resetTimer,
                  style: TextButton.styleFrom(foregroundColor: c.textMuted),
                  child: Text(l.timerReset),
                ),
              ],
            ),
          ),
        if (seconds > 0) const SizedBox(height: Space.lg),
        Text(l.dayDiscussionHint, style: context.type.bodySmall),
        const SizedBox(height: Space.md),
        PlayerTargetGrid(
          children: [
            for (final p in state.players)
              PlayerTile(
                name: p.name,
                enabled: p.isAlive,
                struck: !p.isAlive,
                note: p.isAlive ? null : l.statusEliminated,
              ),
          ],
        ),
      ];
      bottom = PrimaryActionButton(
        key: const Key('startVoting'),
        label: l.dayStartVoting,
        trailing: MafiaGlyphs.arrow,
        onPressed: () => setState(() => _voting = true),
      );
    } else {
      content = [
        if (tie != null) ...[
          _TieCard(
            entry: tie,
            state: state,
            onDecide: (id) {
              _submit((tie.input as DayVoteInput).withTieBreaker(id));
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
        const SizedBox(height: Space.md),
        for (final p in state.alivePlayers) ...[
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
      bottom = Column(
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
    }

    return PhaseScaffold(
      transparent: true,
      bottomPadding: EdgeInsetsDirectional.fromSTEB(
        Space.page,
        Space.md,
        Space.page,
        MediaQuery.viewPaddingOf(context).bottom > 0
            ? (_voting ? Space.lg : Space.bottomAction)
            : Space.lg,
      ),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.lg),
        children: [
          header,
          const SizedBox(height: 22),
          SegmentedPill<bool>(
            key: const Key('dayTabs'),
            segments: [(false, l.dayDiscussion), (true, l.dayVoting)],
            selected: _voting,
            onChanged: (v) => setState(() => _voting = v),
          ),
          const SizedBox(height: 18),
          ...content,
        ],
      ),
      bottom: bottom,
    );
  }
}

/// The vote tied: the host picks who goes, or the table votes again.
class _TieCard extends StatelessWidget {
  const _TieCard({required this.entry, required this.state, required this.onDecide});

  final LogEntry entry;
  final GameState state;
  final ValueChanged<String> onDecide;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final tied = entry.events.whereType<VoteTied>().first.candidateIds;
    final names = l.names(tied.map((id) => state.player(id).name));
    final hostDecides = entry.events.any((e) => e is HostDecisionRequired);
    return GlassCard(
      key: const Key('tieCard'),
      tintColor: c.primaryCta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            hostDecides ? l.dayTieHostDecides(names) : l.dayTieRevote(names),
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
        ],
      ),
    );
  }
}
