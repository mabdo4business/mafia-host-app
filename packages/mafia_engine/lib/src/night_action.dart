import 'value_equality.dart';

/// An action a player takes at night. All actions for a night are collected
/// first, then resolved together by `resolveNight`.
sealed class NightAction extends ValueEquality {
  const NightAction(this.actorId, this.targetId);

  final String actorId;
  final String targetId;

  @override
  List<Object?> get props => [actorId, targetId];
}

/// A Mafia-team player's kill. The Godfather's choice is final; if he is dead
/// (or does not act), the remaining Mafia must agree on one target.
final class MafiaKill extends NightAction {
  const MafiaKill(super.actorId, super.targetId);
}

final class JokerKill extends NightAction {
  const JokerKill(super.actorId, super.targetId);
}

final class DoctorSave extends NightAction {
  const DoctorSave(super.actorId, super.targetId);
}

final class DetectiveCheck extends NightAction {
  const DetectiveCheck(super.actorId, super.targetId);
}

final class PotanaBlock extends NightAction {
  const PotanaBlock(super.actorId, super.targetId);
}

final class LawyerProtect extends NightAction {
  const LawyerProtect(super.actorId, super.targetId);
}
