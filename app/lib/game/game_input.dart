import 'package:mafia_engine/mafia_engine.dart';

/// Something the host entered. A game is its setup plus the ordered list of
/// inputs; replaying them through the engine rebuilds the exact state.
sealed class GameInput {
  const GameInput();
}

/// Every action collected by the night wizard.
final class NightInput extends GameInput {
  const NightInput(this.actions);
  final List<NightAction> actions;
}

/// A triggered Bomb's chosen victims.
final class BombInput extends GameInput {
  const BombInput(this.bombId, this.victimIds);
  final String bombId;
  final List<String> victimIds;
}

/// A day vote, recorded per voter or as a count per candidate.
sealed class DayVoteInput extends GameInput {
  const DayVoteInput({this.tieBreakerId});

  /// The host's pick when the vote tied (tie rule `hostDecides`).
  final String? tieBreakerId;

  /// The same vote with the host's tie-breaker.
  DayVoteInput withTieBreaker(String id);
}

/// The day vote: voter id → target id.
final class VoteInput extends DayVoteInput {
  const VoteInput(this.votes, {super.tieBreakerId});
  final Map<String, String?> votes;

  @override
  VoteInput withTieBreaker(String id) => VoteInput(votes, tieBreakerId: id);
}

/// The day vote as counted raised hands: target id → number of votes.
final class TallyVoteInput extends DayVoteInput {
  const TallyVoteInput(this.tally, {super.tieBreakerId});
  final Map<String, int> tally;

  @override
  TallyVoteInput withTieBreaker(String id) => TallyVoteInput(tally, tieBreakerId: id);
}

/// The host moved on (morning → day, or day result → next night).
final class AdvanceInput extends GameInput {
  const AdvanceInput();
}
