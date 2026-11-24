import 'value_equality.dart';

/// Q3: what happens when the re-vote ties again.
enum SecondTieRule { noElimination, hostDecides, randomAmongTied }

/// House rules chosen at setup. Each open question in docs/GAME_RULES.md §6
/// is a flag here with the documented default, so no resolver hard-codes
/// one; plus the day and night timers (§4).
final class GameSettings extends ValueEquality {
  const GameSettings({
    this.godfatherAppearsCivilian = false,
    this.putanaCanBlockMafia = true,
    this.secondTieRule = SecondTieRule.noElimination,
    this.chameleonMafiaJoinsMafiaTeam = true,
    this.detectiveChainOnVote = false,
    this.blockedChecksCount = false,
    this.doctorBlocksChainDeaths = false,
    this.switchmanRedirectsEach = true,
    this.doctorSavesRedirectedBullet = true,
    this.bombNoEffectBeforePlant = true,
    this.silenceLastsNextDay = true,
    this.witchCiviliansOnly = true,
    this.mafiaWinsAtParity = true,
    this.revealRoleOnDeath = false,
    this.mafiaDiscussionSeconds = 20,
    this.freeChatSeconds = 120,
    this.speechSeconds = 30,
    this.foulSeconds = 15,
  });

  /// Q1: the Detective sees the Godfather as Civilian.
  final bool godfatherAppearsCivilian;

  /// Q2 (and Q15): Putana may block Mafia Team players too.
  final bool putanaCanBlockMafia;

  /// Q3.
  final SecondTieRule secondTieRule;

  /// Q4: a Chameleon who chooses Mafia switches to the Mafia Team (win
  /// condition, Detective result). Off: kills with the Mafia, stays Civilian.
  final bool chameleonMafiaJoinsMafiaTeam;

  /// Q5: the Detective chain also triggers when the Detective dies by day.
  final bool detectiveChainOnVote;

  /// Q6: a check blocked by Putana still counts toward the three.
  final bool blockedChecksCount;

  /// Q7: that night's Doctor save also stops chain deaths (Witch link, Bomb,
  /// TNT, Detective chain) during the night.
  final bool doctorBlocksChainDeaths;

  /// Q8: one redirect per bullet aimed at the Switchman. Off: a single
  /// redirect sends every bullet to that player.
  final bool switchmanRedirectsEach;

  /// Q9: the Doctor's save protects against a redirected bullet.
  final bool doctorSavesRedirectedBullet;

  /// Q10: a Bomb who dies on night 1 (before planting) has no effect. Off:
  /// it takes both neighbors or no one, as when voted out on day 1.
  final bool bombNoEffectBeforePlant;

  /// Q11: the silence lasts the next day only. Off: the day after, too.
  final bool silenceLastsNextDay;

  /// Q12: the Witch links Civilians Team players only.
  final bool witchCiviliansOnly;

  /// Q13: Mafia win once the Mafia Team is at least the Civilians Team
  /// alive. Off: only once it outnumbers them.
  final bool mafiaWinsAtParity;

  /// Q14: death events carry the dead player's card.
  final bool revealRoleOnDeath;

  final int mafiaDiscussionSeconds;
  final int freeChatSeconds;
  final int speechSeconds;
  final int foulSeconds;

  GameSettings copyWith({
    bool? godfatherAppearsCivilian,
    bool? putanaCanBlockMafia,
    SecondTieRule? secondTieRule,
    bool? chameleonMafiaJoinsMafiaTeam,
    bool? detectiveChainOnVote,
    bool? blockedChecksCount,
    bool? doctorBlocksChainDeaths,
    bool? switchmanRedirectsEach,
    bool? doctorSavesRedirectedBullet,
    bool? bombNoEffectBeforePlant,
    bool? silenceLastsNextDay,
    bool? witchCiviliansOnly,
    bool? mafiaWinsAtParity,
    bool? revealRoleOnDeath,
    int? mafiaDiscussionSeconds,
    int? freeChatSeconds,
    int? speechSeconds,
    int? foulSeconds,
  }) =>
      GameSettings(
        godfatherAppearsCivilian: godfatherAppearsCivilian ?? this.godfatherAppearsCivilian,
        putanaCanBlockMafia: putanaCanBlockMafia ?? this.putanaCanBlockMafia,
        secondTieRule: secondTieRule ?? this.secondTieRule,
        chameleonMafiaJoinsMafiaTeam:
            chameleonMafiaJoinsMafiaTeam ?? this.chameleonMafiaJoinsMafiaTeam,
        detectiveChainOnVote: detectiveChainOnVote ?? this.detectiveChainOnVote,
        blockedChecksCount: blockedChecksCount ?? this.blockedChecksCount,
        doctorBlocksChainDeaths: doctorBlocksChainDeaths ?? this.doctorBlocksChainDeaths,
        switchmanRedirectsEach: switchmanRedirectsEach ?? this.switchmanRedirectsEach,
        doctorSavesRedirectedBullet:
            doctorSavesRedirectedBullet ?? this.doctorSavesRedirectedBullet,
        bombNoEffectBeforePlant: bombNoEffectBeforePlant ?? this.bombNoEffectBeforePlant,
        silenceLastsNextDay: silenceLastsNextDay ?? this.silenceLastsNextDay,
        witchCiviliansOnly: witchCiviliansOnly ?? this.witchCiviliansOnly,
        mafiaWinsAtParity: mafiaWinsAtParity ?? this.mafiaWinsAtParity,
        revealRoleOnDeath: revealRoleOnDeath ?? this.revealRoleOnDeath,
        mafiaDiscussionSeconds: mafiaDiscussionSeconds ?? this.mafiaDiscussionSeconds,
        freeChatSeconds: freeChatSeconds ?? this.freeChatSeconds,
        speechSeconds: speechSeconds ?? this.speechSeconds,
        foulSeconds: foulSeconds ?? this.foulSeconds,
      );

  @override
  List<Object?> get props => [
        godfatherAppearsCivilian,
        putanaCanBlockMafia,
        secondTieRule,
        chameleonMafiaJoinsMafiaTeam,
        detectiveChainOnVote,
        blockedChecksCount,
        doctorBlocksChainDeaths,
        switchmanRedirectsEach,
        doctorSavesRedirectedBullet,
        bombNoEffectBeforePlant,
        silenceLastsNextDay,
        witchCiviliansOnly,
        mafiaWinsAtParity,
        revealRoleOnDeath,
        mafiaDiscussionSeconds,
        freeChatSeconds,
        speechSeconds,
        foulSeconds,
      ];
}
