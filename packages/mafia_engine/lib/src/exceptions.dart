/// Why an action or vote was rejected. The app maps these codes to
/// localized messages; the engine never produces user-facing text.
enum InvalidActionReason {
  wrongPhase,

  /// A death choice (Godfather, day-1 Bomb) must be settled first.
  choicePending,

  /// `resolveChoice` for a player with nothing to choose.
  noChoicePending,
  unknownPlayer,
  actorDead,
  targetDead,
  actorLacksRole,
  duplicateAction,
  invalidTarget,

  /// The ability does not work tonight (Putana on night 1, Witch and Bomb
  /// off night 2, Chameleon off night 3 or after choosing).
  notTonight,

  /// A Switchman redirect on a night nobody shot at them.
  notTargeted,

  /// The Chameleon picked a role outside the five.
  roleNotAllowed,
  doctorRepeatTarget,

  /// Victims that don't fit the pending choice.
  invalidChoice,

  /// A re-vote for someone who was not tied.
  notACandidate,
  tieBreakerNotTied,

  /// A tally counts more votes than there are voters (or a negative count).
  tooManyVotes,

  /// Silenced players may not speak (Foul) or vote.
  playerSilenced,
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

  /// The Chameleon chooses on night 3, not at setup.
  chameleonRolePreset,
}

final class InvalidSetupException implements Exception {
  const InvalidSetupException(this.reason, {this.playerId});

  final InvalidSetupReason reason;
  final String? playerId;

  @override
  String toString() => 'InvalidSetupException(${reason.name}, $playerId)';
}
