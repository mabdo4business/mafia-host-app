import 'game_state.dart';
import 'roles.dart';
import 'value_equality.dart';

enum DeathCause {
  mafia,
  joker,
  vote,

  /// The other linked soul died at night.
  witchLink,

  /// A Bomb's planted charge, or its day-1 neighbors.
  bomb,

  /// Sat next to TNT.
  tnt,

  /// Identified by the Detective, who then died.
  detectiveChain,

  /// Taken by the voted-out Godfather.
  godfather,

  /// Removed from the table by the host.
  removed,
}

enum DetectiveResult { mafia, civilian }

/// Something that happened while resolving a phase. The app turns these into
/// localized announcements.
sealed class GameEvent extends ValueEquality {
  const GameEvent();
}

/// A one-player event.
sealed class PlayerEvent extends GameEvent {
  const PlayerEvent(this.playerId);
  final String playerId;
  @override
  List<Object?> get props => [playerId];
}

/// Events with no data.
sealed class SimpleEvent extends GameEvent {
  const SimpleEvent();
  @override
  List<Object?> get props => const [];
}

/// Events about a list of players (tied vote candidates).
sealed class CandidatesEvent extends GameEvent {
  const CandidatesEvent(this.candidateIds);
  final List<String> candidateIds;
  @override
  List<Object?> get props => [candidateIds];
}

/// Putana blocked this player's ability tonight.
final class PlayerBlocked extends PlayerEvent {
  const PlayerBlocked(super.playerId);
}

/// The Lawyer protected this Mafia Team player from the Detective tonight.
final class LawyerProtected extends PlayerEvent {
  const LawyerProtected(super.playerId);
}

/// This player is silenced for the coming day.
final class PlayerSilenced extends PlayerEvent {
  const PlayerSilenced(super.playerId);
}

/// An unblocked Switchman was shot at and sent the bullet nowhere.
final class BulletDodged extends PlayerEvent {
  const BulletDodged(super.playerId);
}

/// Putana is the last Mafia Team player and now kills as a regular Mafia.
final class PutanaPromoted extends PlayerEvent {
  const PutanaPromoted(super.playerId);
}

/// A Bomb died and its planted charges go off.
final class BombExploded extends PlayerEvent {
  const BombExploded(super.playerId);
}

final class SoulsLinked extends GameEvent {
  const SoulsLinked(this.firstId, this.secondId);
  final String firstId;
  final String secondId;
  @override
  List<Object?> get props => [firstId, secondId];
}

final class BombPlanted extends GameEvent {
  const BombPlanted(this.bombId, this.firstId, this.secondId);
  final String bombId;
  final String firstId;
  final String secondId;
  @override
  List<Object?> get props => [bombId, firstId, secondId];
}

final class ChameleonChose extends GameEvent {
  const ChameleonChose(this.playerId, this.role);
  final String playerId;
  final Role role;
  @override
  List<Object?> get props => [playerId, role];
}

/// The Mafia showed different numbers without the Godfather: no murder.
final class MafiaKillCancelled extends SimpleEvent {
  const MafiaKillCancelled();
}

/// A bullet aimed at the Switchman went to [targetId].
final class BulletRedirected extends GameEvent {
  const BulletRedirected(this.switchmanId, this.targetId);
  final String switchmanId;
  final String targetId;
  @override
  List<Object?> get props => [switchmanId, targetId];
}

/// The Doctor's save stopped these attacks on this player.
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

/// Three checks, two Mafia found: if the Detective dies, [mafiaIds] die too.
final class DetectiveChainArmed extends GameEvent {
  const DetectiveChainArmed(this.detectiveId, this.mafiaIds);
  final String detectiveId;
  final List<String> mafiaIds;
  @override
  List<Object?> get props => [detectiveId, mafiaIds];
}

final class PlayerDied extends GameEvent {
  const PlayerDied(this.playerId, this.causes, {this.causedBy, this.revealedRole});
  final String playerId;
  final Set<DeathCause> causes;

  /// For a chain death: the player whose death (or choice) took this one.
  final String? causedBy;

  /// The dead player's card, only when `revealRoleOnDeath` is on.
  final Role? revealedRole;
  @override
  List<Object?> get props => [playerId, causes, causedBy, revealedRole];
}

/// A death the host must settle with `resolveChoice` before play goes on.
final class ChoiceRequired extends GameEvent {
  const ChoiceRequired(this.choice);
  final PendingChoice choice;
  @override
  List<Object?> get props => [choice];
}

/// The highest vote count is shared.
final class VoteTied extends CandidatesEvent {
  const VoteTied(super.candidateIds);
}

/// First tie: the table votes again, between [candidateIds] only.
final class RevoteRequired extends CandidatesEvent {
  const RevoteRequired(super.candidateIds);
}

/// The re-vote tied (`SecondTieRule.hostDecides`): pass `tieBreakerId`.
final class HostDecisionRequired extends CandidatesEvent {
  const HostDecisionRequired(super.candidateIds);
}

/// The re-vote tied (`SecondTieRule.randomAmongTied`): the app draws one of
/// [candidateIds] and passes it as `tieBreakerId`, so a replay is exact.
final class DrawLotsRequired extends CandidatesEvent {
  const DrawLotsRequired(super.candidateIds);
}

final class NoElimination extends SimpleEvent {
  const NoElimination();
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
