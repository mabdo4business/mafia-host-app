import 'package:mafia_engine/mafia_engine.dart';

import 'game_input.dart';

/// JSON (de)serialization for what the database stores.

Map<String, Object?> settingsToJson(GameSettings s, {required int discussionSeconds}) => {
  'bombVictimCount': s.bombVictimCount,
  'doctorSaveBlocksJokerKill': s.doctorSaveBlocksJokerKill,
  'doctorCanSaveBombVictims': s.doctorCanSaveBombVictims,
  'blockedBombStillExplodes': s.blockedBombStillExplodes,
  'chameleonCanPickMafiaRoles': s.chameleonCanPickMafiaRoles,
  'revealRoleOnDeath': s.revealRoleOnDeath,
  'tieVoteRule': s.tieVoteRule.name,
  'discussionSeconds': discussionSeconds,
};

GameSettings settingsFromJson(Map<String, Object?> j) {
  const d = GameSettings();
  return GameSettings(
    bombVictimCount: j['bombVictimCount'] as int? ?? d.bombVictimCount,
    doctorSaveBlocksJokerKill:
        j['doctorSaveBlocksJokerKill'] as bool? ?? d.doctorSaveBlocksJokerKill,
    doctorCanSaveBombVictims: j['doctorCanSaveBombVictims'] as bool? ?? d.doctorCanSaveBombVictims,
    blockedBombStillExplodes: j['blockedBombStillExplodes'] as bool? ?? d.blockedBombStillExplodes,
    chameleonCanPickMafiaRoles:
        j['chameleonCanPickMafiaRoles'] as bool? ?? d.chameleonCanPickMafiaRoles,
    revealRoleOnDeath: j['revealRoleOnDeath'] as bool? ?? d.revealRoleOnDeath,
    tieVoteRule: TieVoteRule.values.byName(j['tieVoteRule'] as String? ?? d.tieVoteRule.name),
  );
}

int discussionSecondsFromJson(Map<String, Object?> j) => j['discussionSeconds'] as int? ?? 0;

Map<String, Object?> inputToJson(GameInput input) => switch (input) {
  NightInput(:final actions) => {
    'type': 'night',
    'actions': [for (final a in actions) _actionToJson(a)],
  },
  BombInput(:final bombId, :final victimIds) => {
    'type': 'bomb',
    'bombId': bombId,
    'victims': victimIds,
  },
  VoteInput(:final votes, :final tieBreakerId) => {
    'type': 'vote',
    'votes': votes,
    'tieBreakerId': tieBreakerId,
  },
  AdvanceInput() => {'type': 'advance'},
};

GameInput inputFromJson(Map<String, Object?> j) => switch (j['type']) {
  'night' => NightInput([
    for (final a in (j['actions'] as List).cast<Map<String, Object?>>()) _actionFromJson(a),
  ]),
  'bomb' => BombInput(j['bombId'] as String, (j['victims'] as List).cast<String>()),
  'vote' => VoteInput(
    (j['votes'] as Map).cast<String, String?>(),
    tieBreakerId: j['tieBreakerId'] as String?,
  ),
  'advance' => const AdvanceInput(),
  final t => throw FormatException('Unknown input type: $t'),
};

Map<String, Object?> _actionToJson(NightAction a) => {
  'type': switch (a) {
    MafiaKill() => 'mafiaKill',
    JokerKill() => 'jokerKill',
    DoctorSave() => 'doctorSave',
    DetectiveCheck() => 'detectiveCheck',
    PotanaBlock() => 'potanaBlock',
    LawyerProtect() => 'lawyerProtect',
  },
  'actor': a.actorId,
  'target': a.targetId,
};

NightAction _actionFromJson(Map<String, Object?> j) {
  final actor = j['actor'] as String;
  final target = j['target'] as String;
  return switch (j['type']) {
    'mafiaKill' => MafiaKill(actor, target),
    'jokerKill' => JokerKill(actor, target),
    'doctorSave' => DoctorSave(actor, target),
    'detectiveCheck' => DetectiveCheck(actor, target),
    'potanaBlock' => PotanaBlock(actor, target),
    'lawyerProtect' => LawyerProtect(actor, target),
    final t => throw FormatException('Unknown action type: $t'),
  };
}
