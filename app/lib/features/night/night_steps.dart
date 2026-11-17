import 'package:mafia_engine/mafia_engine.dart';

/// Night wizard steps, in the engine's resolution order.
enum NightStepKind { potana, lawyer, mafia, joker, doctor, detective }

/// One "wake X, who do they pick?" prompt.
final class NightStep {
  const NightStep({
    required this.kind,
    required this.actorId,
    required this.targetIds,
    this.disabledTargetIds = const {},
  });

  final NightStepKind kind;

  /// For the Mafia step: the player with the final say (the Godfather, or the
  /// first living Mafia member if he is dead).
  final String actorId;

  /// Players the host can pick, in seating order.
  final List<String> targetIds;

  /// Shown but not pickable (the Doctor's save from last night).
  final Set<String> disabledTargetIds;

  NightAction actionFor(String targetId) => switch (kind) {
    NightStepKind.potana => PotanaBlock(actorId, targetId),
    NightStepKind.lawyer => LawyerProtect(actorId, targetId),
    NightStepKind.mafia => MafiaKill(actorId, targetId),
    NightStepKind.joker => JokerKill(actorId, targetId),
    NightStepKind.doctor => DoctorSave(actorId, targetId),
    NightStepKind.detective => DetectiveCheck(actorId, targetId),
  };
}

/// Builds tonight's steps. Roles not in the game, or dead, are skipped.
/// A role held by several players (e.g. a Chameleon) gets one step each.
List<NightStep> buildNightSteps(GameState state) {
  final alive = state.alivePlayers;
  List<String> ids(bool Function(Player) test) => [
    for (final p in alive)
      if (test(p)) p.id,
  ];
  Iterable<Player> holders(Role role) => alive.where((p) => p.effectiveRole == role);

  final mafiaTeam = alive.where((p) => p.team == Team.mafia).toList();
  final godfather = mafiaTeam.where((p) => p.effectiveRole == Role.godfather).firstOrNull;
  final decider = godfather ?? mafiaTeam.firstOrNull;

  return [
    for (final p in holders(Role.potana))
      NightStep(
        kind: NightStepKind.potana,
        actorId: p.id,
        targetIds: ids((t) => t.team == Team.civilians),
      ),
    for (final p in holders(Role.lawyer))
      NightStep(
        kind: NightStepKind.lawyer,
        actorId: p.id,
        targetIds: ids((t) => t.team == Team.mafia),
      ),
    if (decider != null)
      NightStep(
        kind: NightStepKind.mafia,
        actorId: decider.id,
        targetIds: ids((t) => t.team != Team.mafia),
      ),
    for (final p in holders(Role.joker))
      NightStep(kind: NightStepKind.joker, actorId: p.id, targetIds: ids((t) => t.id != p.id)),
    for (final p in holders(Role.doctor))
      NightStep(
        kind: NightStepKind.doctor,
        actorId: p.id,
        targetIds: ids((_) => true),
        disabledTargetIds: {?state.doctorLastTargets[p.id]},
      ),
    for (final p in holders(Role.detective))
      NightStep(kind: NightStepKind.detective, actorId: p.id, targetIds: ids((t) => t.id != p.id)),
  ];
}

/// What the Detective should be shown right now, given the actions picked in
/// the earlier steps. Null means the Detective is blocked: give no answer.
DetectiveResult? previewDetectiveResult(
  GameState state,
  List<NightAction> earlierActions,
  DetectiveCheck check,
) {
  final events = resolveNight(state, [...earlierActions, check]).events;
  for (final e in events) {
    if (e is DetectiveResultRevealed && e.detectiveId == check.actorId) return e.result;
  }
  return null;
}
