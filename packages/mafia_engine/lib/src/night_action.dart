import 'roles.dart';
import 'value_equality.dart';

/// An action a player takes at night. All actions for a night are collected
/// first, then resolved together by `resolveNight`.
sealed class NightAction extends ValueEquality {
  const NightAction(this.actorId);

  final String actorId;

  /// The players this action names, in the order given.
  List<String> get targetIds;
}

/// An action on one player.
sealed class TargetedAction extends NightAction {
  const TargetedAction(super.actorId, this.targetId);

  final String targetId;

  @override
  List<String> get targetIds => [targetId];

  @override
  List<Object?> get props => [actorId, targetId];
}

/// An action on two different players.
sealed class PairAction extends NightAction {
  const PairAction(super.actorId, this.firstId, this.secondId);

  final String firstId;
  final String secondId;

  @override
  List<String> get targetIds => [firstId, secondId];

  @override
  List<Object?> get props => [actorId, firstId, secondId];
}

/// A Mafia Team member shows a number. The Godfather's choice is final; with
/// no Godfather choice, every member who shows one must show the same.
final class MafiaKill extends TargetedAction {
  const MafiaKill(super.actorId, super.targetId);
}

/// The Joker's kill (also the Shapeshifter on a Joker night, and a
/// Chameleon who chose Joker).
final class JokerKill extends TargetedAction {
  const JokerKill(super.actorId, super.targetId);
}

final class DoctorSave extends TargetedAction {
  const DoctorSave(super.actorId, super.targetId);
}

final class DetectiveCheck extends TargetedAction {
  const DetectiveCheck(super.actorId, super.targetId);
}

/// From night 2: the target's ability has no effect tonight.
final class PutanaBlock extends TargetedAction {
  const PutanaBlock(super.actorId, super.targetId);
}

/// The target (a Mafia Team player) reads as Civilian to the Detective.
final class LawyerProtect extends TargetedAction {
  const LawyerProtect(super.actorId, super.targetId);
}

/// The target may not speak or vote the next day.
final class SilencerSilence extends TargetedAction {
  const SilencerSilence(super.actorId, super.targetId);
}

/// The Switchman, shot at, sends the bullet to [targetId] instead. With
/// `switchmanRedirectsEach`, one per bullet, matched in resolution order
/// (see `GameState.bulletsAt`).
final class SwitchmanRedirect extends TargetedAction {
  const SwitchmanRedirect(super.actorId, super.targetId);
}

/// Night 2 only: links two players' souls.
final class WitchLink extends PairAction {
  const WitchLink(super.actorId, super.firstId, super.secondId);
}

/// Night 2 only: the Bomb's charges on two players.
final class BombPlant extends PairAction {
  const BombPlant(super.actorId, super.firstId, super.secondId);
}

/// Night 3 only: the Chameleon keeps [role] for the rest of the game.
final class ChameleonChoose extends NightAction {
  const ChameleonChoose(super.actorId, this.role);

  final Role role;

  @override
  List<String> get targetIds => const [];

  @override
  List<Object?> get props => [actorId, role];
}
