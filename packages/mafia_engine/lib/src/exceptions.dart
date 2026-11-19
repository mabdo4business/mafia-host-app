/// Why an action or vote was rejected. The app maps these codes to
/// localized messages; the engine never produces user-facing text.
enum InvalidActionReason {
  wrongPhase,
  bombDetonationPending,
  unknownPlayer,
  actorDead,
  targetDead,
  actorLacksRole,
  duplicateAction,
  invalidTarget,
  doctorRepeatTarget,
  conflictingMafiaKill,
  wrongVictimCount,
  bombNotPending,
  tieBreakerNotTied,

  /// A tallied vote counts more votes than there are living players (or a
  /// negative count).
  tooManyVotes,
}

final class InvalidActionException implements Exception {
  const InvalidActionException(this.reason, {this.playerId});

  final InvalidActionReason reason;

  /// The player the problem relates to, if any.
  final String? playerId;

  @override
  String toString() => 'InvalidActionException(${reason.name}, $playerId)';
}

enum InvalidSetupReason {
  duplicatePlayerId,
  invalidBombVictimCount,
  chameleonRoleMissing,
  chameleonRoleNotAllowed,
  chameleonRoleOnNonChameleon,
}

final class InvalidSetupException implements Exception {
  const InvalidSetupException(this.reason, {this.playerId});

  final InvalidSetupReason reason;
  final String? playerId;

  @override
  String toString() => 'InvalidSetupException(${reason.name}, $playerId)';
}
