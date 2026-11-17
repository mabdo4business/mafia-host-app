/// What happens when the day vote ends in a tie.
enum TieVoteRule { revote, noElimination, hostDecides }

/// House rules chosen by the host at setup. The unconfirmed rules are flags
/// here so they are never hard-coded in the resolvers.
final class GameSettings {
  const GameSettings({
    this.bombVictimCount = 2,
    this.doctorSaveBlocksJokerKill = true,
    this.doctorCanSaveBombVictims = false,
    this.blockedBombStillExplodes = true,
    this.chameleonCanPickMafiaRoles = false,
    this.revealRoleOnDeath = false,
    this.tieVoteRule = TieVoteRule.hostDecides,
  });

  /// How many victims the Bomb takes when it dies (2 or 3).
  final int bombVictimCount;

  /// The Doctor's save also protects against the Joker's kill.
  final bool doctorSaveBlocksJokerKill;

  /// That night's (unblocked) Doctor save protects against a Bomb explosion
  /// triggered during that night or the following day before the vote.
  final bool doctorCanSaveBombVictims;

  /// A Bomb blocked by the Potana on the night it dies still explodes.
  final bool blockedBombStillExplodes;

  /// A Chameleon may pick a Mafia-team role (and then plays for the Mafia).
  final bool chameleonCanPickMafiaRoles;

  /// Death events carry the dead player's role card.
  final bool revealRoleOnDeath;

  final TieVoteRule tieVoteRule;

  GameSettings copyWith({
    int? bombVictimCount,
    bool? doctorSaveBlocksJokerKill,
    bool? doctorCanSaveBombVictims,
    bool? blockedBombStillExplodes,
    bool? chameleonCanPickMafiaRoles,
    bool? revealRoleOnDeath,
    TieVoteRule? tieVoteRule,
  }) =>
      GameSettings(
        bombVictimCount: bombVictimCount ?? this.bombVictimCount,
        doctorSaveBlocksJokerKill: doctorSaveBlocksJokerKill ?? this.doctorSaveBlocksJokerKill,
        doctorCanSaveBombVictims: doctorCanSaveBombVictims ?? this.doctorCanSaveBombVictims,
        blockedBombStillExplodes: blockedBombStillExplodes ?? this.blockedBombStillExplodes,
        chameleonCanPickMafiaRoles: chameleonCanPickMafiaRoles ?? this.chameleonCanPickMafiaRoles,
        revealRoleOnDeath: revealRoleOnDeath ?? this.revealRoleOnDeath,
        tieVoteRule: tieVoteRule ?? this.tieVoteRule,
      );
}
