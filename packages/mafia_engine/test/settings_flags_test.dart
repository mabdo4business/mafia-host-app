import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// GAME_RULES §6: every open question, with its flag flipped from the
/// default. The defaults themselves are covered next to each rule.
void main() {
  GameState game(GameSettings settings) => newGame(settings: settings);

  test('Q1 godfatherAppearsCivilian: the Godfather reads as Civilian', () {
    final r = resolveNight(game(const GameSettings(godfatherAppearsCivilian: true)), [
      const DetectiveCheck('det', 'gf'),
    ]);
    expect(r.events, contains(const DetectiveResultRevealed('det', 'gf', DetectiveResult.civilian)));
  });

  group('Q2 putanaCanBlockMafia', () {
    test('default: she may block a Mafia Team player, whose ability then fails', () {
      final r = resolveNight(toNight(newGame(), 2), [
        const PutanaBlock('put', 'law'),
        const LawyerProtect('law', 'maf'),
        const DetectiveCheck('det', 'maf'),
      ]);
      expect(r.events, contains(const DetectiveResultRevealed('det', 'maf', DetectiveResult.mafia)));
    });

    test('off: Civilians Team players only', () {
      final s = toNight(game(const GameSettings(putanaCanBlockMafia: false)), 2);
      expect(
        () => resolveNight(s, [const PutanaBlock('put', 'law')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });
  });

  group('Q3 secondTieRule', () {
    GameState revote(SecondTieRule rule) => resolveDayVoteTally(
          resolveNight(game(GameSettings(secondTieRule: rule)), const []).state,
          {'c1': 2, 'c2': 2},
        ).state;

    test('hostDecides: the host picks one of the tied players', () {
      final s = revote(SecondTieRule.hostDecides);
      final r = resolveDayVoteTally(s, {'c1': 1, 'c2': 1});
      expect(r.events.last, const HostDecisionRequired(['c1', 'c2']));
      expect(r.state.phase, GamePhase.day);

      expect(
        () => resolveDayVoteTally(s, {'c1': 1, 'c2': 1}, tieBreakerId: 'c3'),
        throwsInvalid(InvalidActionReason.tieBreakerNotTied),
      );
      final decided = resolveDayVoteTally(s, {'c1': 1, 'c2': 1}, tieBreakerId: 'c2');
      expect(deaths(decided), ['c2']);
    });

    test('randomAmongTied: the app draws lots and passes the result in', () {
      final s = revote(SecondTieRule.randomAmongTied);
      final r = resolveDayVoteTally(s, {'c1': 1, 'c2': 1});
      expect(r.events.last, const DrawLotsRequired(['c1', 'c2']));
      expect(deaths(resolveDayVoteTally(s, {'c1': 1, 'c2': 1}, tieBreakerId: 'c1')), ['c1']);
    });

    test('a tie-breaker is ignored for a first tie (it always goes to a re-vote)', () {
      final s = resolveNight(game(const GameSettings(secondTieRule: SecondTieRule.hostDecides)),
          const []).state;
      final r = resolveDayVoteTally(s, {'c1': 2, 'c2': 2}, tieBreakerId: 'c1');
      expect(r.events.last, const RevoteRequired(['c1', 'c2']));
    });
  });

  test('Q4 chameleonMafiaJoinsMafiaTeam off: a Mafia Chameleon kills with them but stays Civilian',
      () {
    final s = nightThenSkipDay(
      toNight(game(const GameSettings(chameleonMafiaJoinsMafiaTeam: false)), 3),
      [const ChameleonChoose('cham', Role.mafia)],
    );
    expect(s.player('cham').team, Team.civilians);
    final r = resolveNight(s, [
      const MafiaKill('cham', 'c1'),
      const DetectiveCheck('det', 'cham'),
    ]);
    expect(deaths(r), ['c1']);
    expect(r.events, contains(const DetectiveResultRevealed('det', 'cham', DetectiveResult.civilian)));
  });

  test('Q5 detectiveChainOnVote: the voted-out Detective takes the two', () {
    var s = nightThenSkipDay(game(const GameSettings(detectiveChainOnVote: true)), [
      const DetectiveCheck('det', 'maf'),
    ]);
    s = nightThenSkipDay(s, [const DetectiveCheck('det', 'c1')]);
    s = resolveNight(s, [const DetectiveCheck('det', 'law')]).state;
    expect(deaths(voteOut(s, 'det')), ['det', 'maf', 'law']);
  });

  group('Q6 blockedChecksCount', () {
    GameState threeChecksOneBlocked(GameSettings settings) {
      var s = nightThenSkipDay(game(settings), [const DetectiveCheck('det', 'maf')]);
      s = nightThenSkipDay(s, [const PutanaBlock('put', 'det'), const DetectiveCheck('det', 'c1')]);
      return nightThenSkipDay(s, [const DetectiveCheck('det', 'law')]);
    }

    test('default: a blocked check does not count', () {
      final s = threeChecksOneBlocked(const GameSettings());
      expect(s.detectiveRecords['det']!.checks, 2);
      expect(deaths(resolveNight(s, [const MafiaKill('gf', 'det')])), ['det']);
    });

    test('on: a blocked check counts toward the three', () {
      final s = threeChecksOneBlocked(const GameSettings(blockedChecksCount: true));
      expect(s.detectiveRecords['det']!.checks, 3);
      expect(deaths(resolveNight(s, [const MafiaKill('gf', 'det')])), ['det', 'maf', 'law']);
    });

    test('a Lawyer-masked result counts as a check, not as a Mafia found', () {
      var s = nightThenSkipDay(newGame(), [
        const LawyerProtect('law', 'maf'),
        const DetectiveCheck('det', 'maf'),
      ]);
      expect(s.detectiveRecords['det'], const DetectiveRecord(checks: 1, mafiaFound: []));
    });
  });

  group('Q7 doctorBlocksChainDeaths', () {
    test('default: the Doctor only stops direct night kills', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'tnt'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(deaths(r), ['tnt', 'cham', 'c1']);
    });

    test('on: a saved player survives a chain death that night', () {
      final r = resolveNight(game(const GameSettings(doctorBlocksChainDeaths: true)), [
        const MafiaKill('gf', 'tnt'),
        const DoctorSave('doc', 'c1'),
      ]);
      expect(deaths(r), ['tnt', 'cham']);
      expect(r.events, contains(const PlayerSaved('c1', {DeathCause.tnt})));
    });
  });

  group('Q8 switchmanRedirectsEach', () {
    test('default: one redirect per bullet, in resolution order (Mafia first)', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'sw'),
        const JokerKill('joker', 'sw'),
        const SwitchmanRedirect('sw', 'maf'),
        const SwitchmanRedirect('sw', 'c1'),
      ]);
      expect(deaths(r), ['maf', 'c1']);
      expect(deathOf(r, 'maf').causes, {DeathCause.mafia});
      expect(deathOf(r, 'c1').causes, {DeathCause.joker});
    });

    test('default: a second bullet without a second redirect hits nobody', () {
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'sw'),
        const JokerKill('joker', 'sw'),
        const SwitchmanRedirect('sw', 'maf'),
      ]);
      expect(deaths(r), ['maf']);
    });

    test('default: no more redirects than bullets', () {
      expect(
        () => resolveNight(newGame(), [
          const MafiaKill('gf', 'sw'),
          const SwitchmanRedirect('sw', 'maf'),
          const SwitchmanRedirect('sw', 'c1'),
        ]),
        throwsInvalid(InvalidActionReason.duplicateAction),
      );
    });

    test('off: one redirect sends every bullet to that player', () {
      final s = game(const GameSettings(switchmanRedirectsEach: false));
      final r = resolveNight(s, [
        const MafiaKill('gf', 'sw'),
        const JokerKill('joker', 'sw'),
        const SwitchmanRedirect('sw', 'c1'),
      ]);
      expect(deaths(r), ['c1']);
      expect(deathOf(r, 'c1').causes, {DeathCause.mafia, DeathCause.joker});
      expect(
        () => resolveNight(s, [
          const MafiaKill('gf', 'sw'),
          const JokerKill('joker', 'sw'),
          const SwitchmanRedirect('sw', 'c1'),
          const SwitchmanRedirect('sw', 'c2'),
        ]),
        throwsInvalid(InvalidActionReason.duplicateAction),
      );
    });
  });

  test('Q9 doctorSavesRedirectedBullet off: the save does not stop a redirected bullet', () {
    final r = resolveNight(game(const GameSettings(doctorSavesRedirectedBullet: false)), [
      const MafiaKill('gf', 'sw'),
      const SwitchmanRedirect('sw', 'c1'),
      const DoctorSave('doc', 'c1'),
    ]);
    expect(deaths(r), ['c1']);
  });

  test('Q10 bombNoEffectBeforePlant off: dying on night 1 takes both neighbors or no one', () {
    final r = resolveNight(game(const GameSettings(bombNoEffectBeforePlant: false)), [
      const MafiaKill('gf', 'bomb'),
    ]);
    expect(r.state.pendingChoices, [
      const PendingChoice('bomb', ChoiceKind.bombTakesNeighbors, options: ['sil', 'shape'], atNight: true),
    ]);
    expect(deaths(resolveChoice(r.state, 'bomb', ['sil', 'shape'])), ['sil', 'shape']);
  });

  test('Q11 silenceLastsNextDay off: silenced for the day after as well', () {
    var s = resolveNight(game(const GameSettings(silenceLastsNextDay: false)), [
      const SilencerSilence('sil', 'c1'),
    ]).state;
    expect(s.isSilenced('c1'), isTrue);
    s = resolveNight(skipDay(s), const []).state;
    expect(s.isSilenced('c1'), isTrue);
    s = resolveNight(skipDay(s), const []).state;
    expect(s.isSilenced('c1'), isFalse);
  });

  group('Q12 witchCiviliansOnly', () {
    test('default: Civilians Team players only', () {
      expect(
        () => resolveNight(toNight(newGame(), 2), [const WitchLink('witch', 'c1', 'maf')]),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('off: any two players', () {
      final s = toNight(game(const GameSettings(witchCiviliansOnly: false)), 2);
      final r = resolveNight(s, [const WitchLink('witch', 'c1', 'maf')]);
      expect(r.state.witchLink, ('c1', 'maf'));
    });
  });

  test('Q13 mafiaWinsAtParity off: the Mafia Team must outnumber the Civilians Team', () {
    final players = table([
      ('gf', Role.godfather),
      ('maf', Role.mafia),
      ('c1', Role.civilian),
      ('c2', Role.civilian),
      ('c3', Role.civilian),
    ]);
    final parity = GameState.initial(players: players);
    expect(resolveNight(parity, [const MafiaKill('gf', 'c1')]).state.winner, Team.mafia);

    final outnumber = GameState.initial(
      players: players,
      settings: const GameSettings(mafiaWinsAtParity: false),
    );
    final r = resolveNight(outnumber, [const MafiaKill('gf', 'c1')]);
    expect(r.state.winner, isNull);
    expect(resolveNight(skipDay(r.state), [const MafiaKill('gf', 'c2')]).state.winner, Team.mafia);
  });

  test('Q14 revealRoleOnDeath: death events carry the card', () {
    final r = resolveNight(game(const GameSettings(revealRoleOnDeath: true)), [
      const MafiaKill('gf', 'det'),
    ]);
    expect(deathOf(r, 'det').revealedRole, Role.detective);
    expect(deathOf(resolveNight(newGame(), [const MafiaKill('gf', 'det')]), 'det').revealedRole, isNull);
  });
}
