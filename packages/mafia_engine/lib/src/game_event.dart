import 'game_state.dart';
import 'roles.dart';
import 'value_equality.dart';

enum DeathCause { mafia, joker, bomb, vote }

enum DetectiveResult { mafia, civilian }

/// Something that happened while resolving a phase. The app turns these into
/// localized announcements.
sealed class GameEvent extends ValueEquality {
  const GameEvent();
}

/// The Potana blocked this player's power for the night.
final class PlayerBlocked extends GameEvent {
  const PlayerBlocked(this.playerId);
  final String playerId;
  @override
  List<Object?> get props => [playerId];
}

/// The Lawyer protected this Mafia member from the Detective tonight.
final class LawyerProtected extends GameEvent {
  const LawyerProtected(this.playerId);
  final String playerId;
  @override
  List<Object?> get props => [playerId];
}

/// The Doctor's save prevented this player's death.
final class PlayerSaved extends GameEvent {
  const PlayerSaved(this.playerId, this.savedFrom);
  final String playerId;
  final Set<DeathCause> savedFrom;
  @override
  List<Object?> get props => [playerId, savedFrom];
}

final class DetectiveResultRevealed extends GameEvent {
  const DetectiveResultRevealed(this.detectiveId, this.targetId, this.result);
  final String detectiveId;
  final String targetId;
  final DetectiveResult result;
  @override
  List<Object?> get props => [detectiveId, targetId, result];
}

final class PlayerDied extends GameEvent {
  const PlayerDied(this.playerId, this.causes, {this.revealedRole});
  final String playerId;
  final Set<DeathCause> causes;

  /// The dead player's card, only when `revealRoleOnDeath` is on.
  final Role? revealedRole;
  @override
  List<Object?> get props => [playerId, causes, revealedRole];
}

/// A Bomb died and must now pick its victims via `detonateBomb`.
final class BombTriggered extends GameEvent {
  const BombTriggered(this.bombId);
  final String bombId;
  @override
  List<Object?> get props => [bombId];
}

/// A Bomb died while blocked and `blockedBombStillExplodes` is off.
final class BombDefused extends GameEvent {
  const BombDefused(this.bombId);
  final String bombId;
  @override
  List<Object?> get props => [bombId];
}

final class VoteTied extends GameEvent {
  const VoteTied(this.candidateIds);
  final List<String> candidateIds;
  @override
  List<Object?> get props => [candidateIds];
}

final class RevoteRequired extends GameEvent {
  const RevoteRequired();
  @override
  List<Object?> get props => const [];
}

final class HostDecisionRequired extends GameEvent {
  const HostDecisionRequired();
  @override
  List<Object?> get props => const [];
}

final class NoElimination extends GameEvent {
  const NoElimination();
  @override
  List<Object?> get props => const [];
}

final class GameOver extends GameEvent {
  const GameOver(this.winner);
  final Team winner;
  @override
  List<Object?> get props => [winner];
}

/// The result of resolving a phase: the new state and what happened.
final class Resolution {
  const Resolution(this.state, this.events);
  final GameState state;
  final List<GameEvent> events;
}
