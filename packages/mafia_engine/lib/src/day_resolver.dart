import 'deaths.dart';
import 'exceptions.dart';
import 'game_event.dart';
import 'game_settings.dart';
import 'game_state.dart';

/// Resolves the day vote (GAME_RULES §2). [votes] maps voter id → target id
/// (null = abstain). Silenced players may not vote.
///
/// The most-voted player is eliminated. A tie calls a re-vote between the
/// tied players ([RevoteRequired]; the state keeps them as
/// `revoteCandidates`). A tie in the re-vote follows `secondTieRule`; for
/// hostDecides and randomAmongTied, pass the pick as [tieBreakerId] (until
/// then the state is unchanged).
Resolution resolveDayVote(
  GameState state,
  Map<String, String?> votes, {
  String? tieBreakerId,
}) {
  _checkCanVote(state);
  final tally = <String, int>{};
  for (final MapEntry(key: voterId, value: targetId) in votes.entries) {
    if (!state.player(voterId).isAlive) throw invalid(InvalidActionReason.actorDead, voterId);
    if (state.isSilenced(voterId)) throw invalid(InvalidActionReason.playerSilenced, voterId);
    if (targetId == null) continue;
    tally[targetId] = (tally[targetId] ?? 0) + 1;
  }
  return _resolveTally(state, tally, tieBreakerId);
}

/// The day vote from a count of raised hands per candidate (target id →
/// votes), for hosts who don't record who voted. Otherwise exactly as
/// [resolveDayVote].
Resolution resolveDayVoteTally(
  GameState state,
  Map<String, int> tally, {
  String? tieBreakerId,
}) {
  _checkCanVote(state);
  final total = tally.values.fold(0, (a, b) => a + b);
  if (tally.values.any((n) => n < 0) || total > state.voterCount) {
    throw invalid(InvalidActionReason.tooManyVotes);
  }
  return _resolveTally(state, {
    for (final MapEntry(:key, :value) in tally.entries)
      if (value > 0) key: value,
  }, tieBreakerId);
}

void _checkCanVote(GameState state) {
  if (state.phase != GamePhase.day) throw invalid(InvalidActionReason.wrongPhase);
  if (state.pendingChoices.isNotEmpty) throw invalid(InvalidActionReason.choicePending);
}

Resolution _resolveTally(GameState state, Map<String, int> tally, String? tieBreakerId) {
  final candidates = state.revoteCandidates;
  for (final targetId in tally.keys) {
    if (!state.player(targetId).isAlive) throw invalid(InvalidActionReason.targetDead, targetId);
    if (candidates != null && !candidates.contains(targetId)) {
      throw invalid(InvalidActionReason.notACandidate, targetId);
    }
  }

  final events = <GameEvent>[];
  String? eliminated;
  if (tally.isEmpty) {
    events.add(const NoElimination());
  } else {
    final top = tally.values.reduce((a, b) => a > b ? a : b);
    final tied = inSeatOrder(state, tally.keys.where((id) => tally[id] == top));
    if (tied.length == 1) {
      eliminated = tied.single;
    } else {
      events.add(VoteTied(tied));
      if (candidates == null) {
        events.add(RevoteRequired(tied));
        return Resolution(state.copyWith(revoteCandidates: tied), List.unmodifiable(events));
      }
      final rule = state.settings.secondTieRule;
      if (rule == SecondTieRule.noElimination) {
        events.add(const NoElimination());
      } else if (tieBreakerId == null) {
        events.add(rule == SecondTieRule.hostDecides
            ? HostDecisionRequired(tied)
            : DrawLotsRequired(tied));
        return Resolution(state, List.unmodifiable(events));
      } else if (!tied.contains(tieBreakerId)) {
        throw invalid(InvalidActionReason.tieBreakerNotTied, tieBreakerId);
      } else {
        eliminated = tieBreakerId;
      }
    }
  }

  var next = state;
  if (eliminated != null) {
    next = applyDeaths(next, {eliminated: {DeathCause.vote}}, events, atNight: false);
  }
  next = next.copyWith(
    phase: GamePhase.night,
    nightNumber: state.nightNumber + 1,
    revoteCandidates: null,
  );
  next = settle(next, events);
  return Resolution(next, List.unmodifiable(events));
}
