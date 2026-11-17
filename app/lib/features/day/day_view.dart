import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import 'discussion_timer.dart';

/// Discussion (optional timer) and the vote. For each candidate the host taps
/// the players who raised their hand.
class DayView extends ConsumerStatefulWidget {
  const DayView({super.key, required this.session});

  final GameSession session;

  @override
  ConsumerState<DayView> createState() => _DayViewState();
}

class _DayViewState extends ConsumerState<DayView> {
  /// voter id → candidate id
  final Map<String, String> _votes = {};

  void _submit(Map<String, String?> votes, {String? tieBreakerId}) =>
      ref.read(activeGameProvider.notifier).apply(VoteInput(votes, tieBreakerId: tieBreakerId));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final session = widget.session;
    final state = session.state;
    final alive = state.alivePlayers;
    final tie = session.pendingTie;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(16),
            children: [
              if (session.setup.discussionSeconds > 0)
                DiscussionTimer(seconds: session.setup.discussionSeconds),
              if (tie != null)
                _TieCard(
                  entry: tie,
                  state: state,
                  onDecide: (id) => _submit((tie.input as VoteInput).votes, tieBreakerId: id),
                ),
              SectionHeader(l.dayVoteTitle),
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                child: Text(l.dayVoteHint),
              ),
              const SizedBox(height: 8),
              for (final candidate in alive)
                _CandidateCard(
                  candidate: candidate,
                  voters: alive,
                  votes: _votes,
                  onToggle: (voterId, on) => setState(() {
                    if (on) {
                      _votes[voterId] = candidate.id;
                    } else {
                      _votes.remove(voterId);
                    }
                  }),
                ),
            ],
          ),
        ),
        BottomActions(
          children: [
            OutlinedButton(
              key: const Key('skipVote'),
              onPressed: () => _submit(const {}),
              child: Text(l.daySkipVote),
            ),
            FilledButton(
              key: const Key('countVotes'),
              onPressed: _votes.isEmpty ? null : () => _submit(Map.of(_votes)),
              child: Text(l.dayCountVotes),
            ),
          ],
        ),
      ],
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.voters,
    required this.votes,
    required this.onToggle,
  });

  final Player candidate;
  final List<Player> voters;
  final Map<String, String> votes;
  final void Function(String voterId, bool on) onToggle;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final count = votes.values.where((v) => v == candidate.id).length;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      key: Key('candidate_${candidate.id}'),
      child: ExpansionTile(
        shape: const Border(),
        leading: CircleAvatar(
          backgroundColor: count > 0 ? scheme.primary : scheme.surfaceContainerHighest,
          foregroundColor: count > 0 ? scheme.onPrimary : scheme.onSurfaceVariant,
          child: Text(context.number(count)),
        ),
        title: Text(candidate.name),
        subtitle: Text(l.voteCount(count)),
        childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
        expandedAlignment: AlignmentDirectional.centerStart,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final voter in voters)
                FilterChip(
                  key: Key('vote_${voter.id}_for_${candidate.id}'),
                  label: Text(voter.name),
                  selected: votes[voter.id] == candidate.id,
                  // A voter already counted for someone else is shown faded;
                  // tapping moves their vote here.
                  labelStyle: votes.containsKey(voter.id) && votes[voter.id] != candidate.id
                      ? TextStyle(color: scheme.outline)
                      : null,
                  onSelected: (on) => onToggle(voter.id, on),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TieCard extends StatelessWidget {
  const _TieCard({required this.entry, required this.state, required this.onDecide});

  final LogEntry entry;
  final GameState state;
  final ValueChanged<String> onDecide;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final tied = entry.events.whereType<VoteTied>().first.candidateIds;
    final names = l.names(tied.map((id) => state.player(id).name));
    final hostDecides = entry.events.any((e) => e is HostDecisionRequired);
    return Card(
      key: const Key('tieCard'),
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsetsDirectional.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              hostDecides ? l.dayTieHostDecides(names) : l.dayTieRevote(names),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
            if (hostDecides) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in tied)
                    FilledButton.tonal(
                      key: Key('tieBreak_$id'),
                      style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
                      onPressed: () => onDecide(id),
                      child: Text(state.player(id).name),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
