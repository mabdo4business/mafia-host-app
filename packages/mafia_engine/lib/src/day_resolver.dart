import 'deaths.dart';
import 'exceptions.dart';
import 'game_event.dart';
import 'game_settings.dart';
import 'game_state.dart';

/// Resolves the day vote. [votes] maps voter id → target id (null = abstain).
/// The most-voted player is eliminated; ties follow `settings.tieVoteRule`.
///
/// For [TieVoteRule.revote] and for [TieVoteRule.hostDecides] without a
/// [tieBreakerId], the returned state is the unchanged input state and the
/// events say what the host must do next.
Resolution resolveDayVote(
  GameState state,
  Map<String, String?> votes, {
  String? tieBreakerId,
}) {
  if (state.phase != GamePhase.day) {
    throw const InvalidActionException(InvalidActionReason.wrongPhase);
  }
  if (state.pendingBombs.isNotEmpty) {
    throw const InvalidActionException(InvalidActionReason.bombDetonationPending);
  }

  final tally = <String, int>{};
  for (final MapEntry(key: voterId, value: targetId) in votes.entries) {
    if (!state.player(voterId).isAlive) {
      throw InvalidActionException(InvalidActionReason.actorDead, playerId: voterId);
    }
    if (targetId == null) continue;
    tally[targetId] = (tally[targetId] ?? 0) + 1;
  }
  return _resolveTally(state, tally, tieBreakerId);
}

/// Resolves the day vote from a count per candidate (target id → votes),
/// for hosts who count raised hands without recording who voted. Ties and
/// eliminations work exactly as in [resolveDayVote].
Resolution resolveDayVoteTally(
  GameState state,
  Map<String, int> tally, {
  String? tieBreakerId,
}) {
  if (state.phase != GamePhase.day) {
    throw const InvalidActionException(InvalidActionReason.wrongPhase);
  }
  if (state.pendingBombs.isNotEmpty) {
    throw const InvalidActionException(InvalidActionReason.bombDetonationPending);
  }
  final total = tally.values.fold(0, (a, b) => a + b);
  if (tally.values.any((n) => n < 0) || total > state.alivePlayers.length) {
    throw const InvalidActionException(InvalidActionReason.tooManyVotes);
  }
  return _resolveTally(state, {
    for (final MapEntry(:key, :value) in tally.entries)
      if (value > 0) key: value,
  }, tieBreakerId);
}

Resolution _resolveTally(GameState state, Map<String, int> tally, String? tieBreakerId) {
  for (final targetId in tally.keys) {
    if (!state.player(targetId).isAlive) {
      throw InvalidActionException(InvalidActionReason.targetDead, playerId: targetId);
    }
  }

  final events = <GameEvent>[];
  String? eliminated;
  if (tally.isEmpty) {
    events.add(const NoElimination());
  } else {
    final top = tally.values.reduce((a, b) => a > b ? a : b);
    final candidates = inSeatingOrder(state, tally.keys.where((id) => tally[id] == top));
    if (candidates.length == 1) {
      eliminated = candidates.single;
    } else {
      if (state.settings.tieVoteRule == TieVoteRule.hostDecides &&
          tieBreakerId != null &&
          !candidates.contains(tieBreakerId)) {
        throw InvalidActionException(
          InvalidActionReason.tieBreakerNotTied,
          playerId: tieBreakerId,
        );
      }
      events.add(VoteTied(List.unmodifiable(candidates)));
      switch (state.settings.tieVoteRule) {
        case TieVoteRule.revote:
          events.add(const RevoteRequired());
          return Resolution(state, List.unmodifiable(events));
        case TieVoteRule.noElimination:
          events.add(const NoElimination());
        case TieVoteRule.hostDecides:
          if (tieBreakerId == null) {
            events.add(const HostDecisionRequired());
            return Resolution(state, List.unmodifiable(events));
          }
          eliminated = tieBreakerId;
      }
    }
  }

  var next = state.copyWith(
    phase: GamePhase.night,
    nightNumber: state.nightNumber + 1,
    lastNight: null,
  );
  if (eliminated != null) {
    next = applyDeaths(
        next,
        {
          eliminated: {DeathCause.vote}
        },
        events);
  }
  next = settle(next, events);
  return Resolution(next, List.unmodifiable(events));
}
