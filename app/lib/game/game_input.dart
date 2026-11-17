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

/// The day vote: voter id → target id.
final class VoteInput extends GameInput {
  const VoteInput(this.votes, {this.tieBreakerId});
  final Map<String, String?> votes;
  final String? tieBreakerId;
}

/// The host moved on (morning → day, or day result → next night).
final class AdvanceInput extends GameInput {
  const AdvanceInput();
}
