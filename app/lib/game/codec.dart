import 'package:mafia_engine/mafia_engine.dart';

import 'game_input.dart';

/// JSON (de)serialization for what the database stores.

/// The rules a stored game was played under. Games from before
/// docs/GAME_RULES.md (no version) can't be replayed by today's engine.
const rulesVersion = 2;

bool isCurrentRules(Map<String, Object?> settingsJson) => settingsJson['rules'] == rulesVersion;

Map<String, Object?> settingsToJson(GameSettings s) => {
  'rules': rulesVersion,
  'godfatherAppearsCivilian': s.godfatherAppearsCivilian,
  'putanaCanBlockMafia': s.putanaCanBlockMafia,
  'secondTieRule': s.secondTieRule.name,
  'chameleonMafiaJoinsMafiaTeam': s.chameleonMafiaJoinsMafiaTeam,
  'detectiveChainOnVote': s.detectiveChainOnVote,
  'blockedChecksCount': s.blockedChecksCount,
  'doctorBlocksChainDeaths': s.doctorBlocksChainDeaths,
  'switchmanRedirectsEach': s.switchmanRedirectsEach,
  'doctorSavesRedirectedBullet': s.doctorSavesRedirectedBullet,
  'bombNoEffectBeforePlant': s.bombNoEffectBeforePlant,
  'silenceLastsNextDay': s.silenceLastsNextDay,
  'witchCiviliansOnly': s.witchCiviliansOnly,
  'mafiaWinsAtParity': s.mafiaWinsAtParity,
  'revealRoleOnDeath': s.revealRoleOnDeath,
  'mafiaDiscussionSeconds': s.mafiaDiscussionSeconds,
  'freeChatSeconds': s.freeChatSeconds,
  'speechSeconds': s.speechSeconds,
  'foulSeconds': s.foulSeconds,
};

GameSettings settingsFromJson(Map<String, Object?> j) {
  const d = GameSettings();
  bool flag(String key, bool fallback) => j[key] as bool? ?? fallback;
  int seconds(String key, int fallback) => j[key] as int? ?? fallback;
  return GameSettings(
    godfatherAppearsCivilian: flag('godfatherAppearsCivilian', d.godfatherAppearsCivilian),
    putanaCanBlockMafia: flag('putanaCanBlockMafia', d.putanaCanBlockMafia),
    secondTieRule: SecondTieRule.values.asNameMap()[j['secondTieRule']] ?? d.secondTieRule,
    chameleonMafiaJoinsMafiaTeam: flag(
      'chameleonMafiaJoinsMafiaTeam',
      d.chameleonMafiaJoinsMafiaTeam,
    ),
    detectiveChainOnVote: flag('detectiveChainOnVote', d.detectiveChainOnVote),
    blockedChecksCount: flag('blockedChecksCount', d.blockedChecksCount),
    doctorBlocksChainDeaths: flag('doctorBlocksChainDeaths', d.doctorBlocksChainDeaths),
    switchmanRedirectsEach: flag('switchmanRedirectsEach', d.switchmanRedirectsEach),
    doctorSavesRedirectedBullet: flag('doctorSavesRedirectedBullet', d.doctorSavesRedirectedBullet),
    bombNoEffectBeforePlant: flag('bombNoEffectBeforePlant', d.bombNoEffectBeforePlant),
    silenceLastsNextDay: flag('silenceLastsNextDay', d.silenceLastsNextDay),
    witchCiviliansOnly: flag('witchCiviliansOnly', d.witchCiviliansOnly),
    mafiaWinsAtParity: flag('mafiaWinsAtParity', d.mafiaWinsAtParity),
    revealRoleOnDeath: flag('revealRoleOnDeath', d.revealRoleOnDeath),
    mafiaDiscussionSeconds: seconds('mafiaDiscussionSeconds', d.mafiaDiscussionSeconds),
    freeChatSeconds: seconds('freeChatSeconds', d.freeChatSeconds),
    speechSeconds: seconds('speechSeconds', d.speechSeconds),
    foulSeconds: seconds('foulSeconds', d.foulSeconds),
  );
}

/// A stored role name. Games from before the rename stored "potana".
Role roleFromName(String name) => name == 'potana' ? Role.putana : Role.values.byName(name);

Map<String, Object?> inputToJson(GameInput input) => switch (input) {
  NightInput(:final actions) => {
    'type': 'night',
    'actions': [for (final a in actions) _actionToJson(a)],
  },
  ChoiceInput(:final playerId, :final victimIds) => {
    'type': 'choice',
    'player': playerId,
    'victims': victimIds,
  },
  VoteInput(:final votes, :final tieBreakerId) => {
    'type': 'vote',
    'votes': votes,
    'tieBreakerId': tieBreakerId,
  },
  TallyVoteInput(:final tally, :final tieBreakerId) => {
    'type': 'tally',
    'tally': tally,
    'tieBreakerId': tieBreakerId,
  },
  FoulInput(:final playerId) => {'type': 'foul', 'player': playerId},
  RemoveInput(:final playerId) => {'type': 'remove', 'player': playerId},
  AdvanceInput() => {'type': 'advance'},
};

GameInput inputFromJson(Map<String, Object?> j) => switch (j['type']) {
  'night' => NightInput([
    for (final a in (j['actions'] as List).cast<Map<String, Object?>>()) _actionFromJson(a),
  ]),
  'choice' => ChoiceInput(j['player'] as String, (j['victims'] as List).cast<String>()),
  'vote' => VoteInput(
    (j['votes'] as Map).cast<String, String?>(),
    tieBreakerId: j['tieBreakerId'] as String?,
  ),
  'tally' => TallyVoteInput(
    (j['tally'] as Map).cast<String, int>(),
    tieBreakerId: j['tieBreakerId'] as String?,
  ),
  'foul' => FoulInput(j['player'] as String),
  'remove' => RemoveInput(j['player'] as String),
  'advance' => const AdvanceInput(),
  final t => throw FormatException('Unknown input type: $t'),
};

Map<String, Object?> _actionToJson(NightAction a) => {
  'type': switch (a) {
    MafiaKill() => 'mafiaKill',
    JokerKill() => 'jokerKill',
    DoctorSave() => 'doctorSave',
    DetectiveCheck() => 'detectiveCheck',
    PutanaBlock() => 'putanaBlock',
    LawyerProtect() => 'lawyerProtect',
    SilencerSilence() => 'silence',
    SwitchmanRedirect() => 'redirect',
    WitchLink() => 'witchLink',
    BombPlant() => 'bombPlant',
    ChameleonChoose() => 'chameleonChoose',
  },
  'actor': a.actorId,
  if (a.targetIds.isNotEmpty) 'targets': a.targetIds,
  if (a case ChameleonChoose(:final role)) 'role': role.name,
};

NightAction _actionFromJson(Map<String, Object?> j) {
  final actor = j['actor'] as String;
  final t = (j['targets'] as List?)?.cast<String>() ?? const [];
  return switch (j['type']) {
    'mafiaKill' => MafiaKill(actor, t[0]),
    'jokerKill' => JokerKill(actor, t[0]),
    'doctorSave' => DoctorSave(actor, t[0]),
    'detectiveCheck' => DetectiveCheck(actor, t[0]),
    'putanaBlock' => PutanaBlock(actor, t[0]),
    'lawyerProtect' => LawyerProtect(actor, t[0]),
    'silence' => SilencerSilence(actor, t[0]),
    'redirect' => SwitchmanRedirect(actor, t[0]),
    'witchLink' => WitchLink(actor, t[0], t[1]),
    'bombPlant' => BombPlant(actor, t[0], t[1]),
    'chameleonChoose' => ChameleonChoose(actor, Role.values.byName(j['role'] as String)),
    final type => throw FormatException('Unknown action type: $type'),
  };
}
