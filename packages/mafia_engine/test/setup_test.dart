import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Roles (GAME_RULES §1)', () {
    // §1.1 is titled "6 roles" but lists five; these are the five it lists.
    test('Mafia Team roles', () {
      expect(
        Role.values.where((r) => r.team == Team.mafia),
        unorderedEquals([Role.godfather, Role.mafia, Role.putana, Role.lawyer, Role.witch]),
      );
    });

    test('Civilians Team roles (ten)', () {
      expect(
        Role.values.where((r) => r.team == Team.civilians),
        unorderedEquals([
          Role.detective,
          Role.doctor,
          Role.joker,
          Role.switchman,
          Role.silencer,
          Role.bomb,
          Role.shapeshifter,
          Role.chameleon,
          Role.tnt,
          Role.civilian,
        ]),
      );
    });

    test('the Chameleon picks from five roles', () {
      expect(chameleonChoices, [Role.mafia, Role.detective, Role.doctor, Role.joker, Role.switchman]);
    });

    test('the Shapeshifter rotates Detective → Doctor → Joker', () {
      expect([for (var n = 1; n <= 7; n++) shapeshifterRoleFor(n)], [
        Role.detective,
        Role.doctor,
        Role.joker,
        Role.detective,
        Role.doctor,
        Role.joker,
        Role.detective,
      ]);
    });
  });

  group('GameSettings defaults (GAME_RULES §4, §6)', () {
    test('every open question uses the documented default', () {
      const s = GameSettings();
      expect(s.godfatherAppearsCivilian, isFalse, reason: 'Q1');
      expect(s.putanaCanBlockMafia, isTrue, reason: 'Q2');
      expect(s.secondTieRule, SecondTieRule.noElimination, reason: 'Q3');
      expect(s.chameleonMafiaJoinsMafiaTeam, isTrue, reason: 'Q4');
      expect(s.detectiveChainOnVote, isFalse, reason: 'Q5');
      expect(s.blockedChecksCount, isFalse, reason: 'Q6');
      expect(s.doctorBlocksChainDeaths, isFalse, reason: 'Q7');
      expect(s.switchmanRedirectsEach, isTrue, reason: 'Q8');
      expect(s.doctorSavesRedirectedBullet, isTrue, reason: 'Q9');
      expect(s.bombNoEffectBeforePlant, isTrue, reason: 'Q10');
      expect(s.silenceLastsNextDay, isTrue, reason: 'Q11');
      expect(s.witchCiviliansOnly, isTrue, reason: 'Q12');
      expect(s.mafiaWinsAtParity, isTrue, reason: 'Q13');
      expect(s.revealRoleOnDeath, isFalse, reason: 'Q14');
    });

    test('timers', () {
      const s = GameSettings();
      expect(s.mafiaDiscussionSeconds, 20);
      expect(s.freeChatSeconds, 120);
      expect(s.speechSeconds, 30);
      expect(s.foulSeconds, 15);
    });

    test('copyWith changes only the given fields', () {
      final s = const GameSettings().copyWith(
        secondTieRule: SecondTieRule.hostDecides,
        speechSeconds: 45,
      );
      expect(s.secondTieRule, SecondTieRule.hostDecides);
      expect(s.speechSeconds, 45);
      expect(s.freeChatSeconds, 120);
      expect(s.witchCiviliansOnly, isTrue);
      expect(s, isNot(const GameSettings()));
      expect(const GameSettings().copyWith(), const GameSettings());
    });
  });

  group('GameState.initial', () {
    test('starts at night 1 with everyone alive', () {
      final s = newGame();
      expect(s.phase, GamePhase.night);
      expect(s.nightNumber, 1);
      expect(s.winner, isNull);
      expect(s.pendingChoices, isEmpty);
      expect(s.players.every((p) => p.isAlive), isTrue);
    });

    test('rejects duplicate player ids', () {
      expect(
        () => GameState.initial(players: [p('a', Role.civilian), p('a', Role.mafia)]),
        throwsSetup(InvalidSetupReason.duplicatePlayerId),
      );
    });

    test('a Chameleon starts without a role; it picks on night 3', () {
      expect(
        () => GameState.initial(players: [
          const Player(id: 'x', name: 'x', role: Role.chameleon, chameleonRole: Role.doctor),
        ]),
        throwsSetup(InvalidSetupReason.chameleonRolePreset),
      );
    });

    test('unknown players are rejected', () {
      expect(() => newGame().player('nobody'), throwsInvalid(InvalidActionReason.unknownPlayer));
    });
  });

  group('Seats', () {
    test('seat order is the player list order', () {
      final s = newGame();
      expect(s.seatOf('gf'), 0);
      expect(s.seatOf('c4'), 17);
    });

    test('neighbors wrap around the circular table', () {
      final s = newGame();
      expect(s.neighborsOf('tnt'), ['cham', 'c1']);
      expect(s.neighborsOf('gf'), ['c4', 'maf']);
      expect(s.neighborsOf('c4'), ['c3', 'gf']);
    });

    test('empty seats are skipped: the nearest living players are the neighbors', () {
      final s = nightThenSkipDay(newGame(), [const MafiaKill('gf', 'cham')]);
      expect(s.neighborsOf('tnt'), ['shape', 'c1']);
    });

    test('with two players left, both neighbors are the same player', () {
      final s = GameState.initial(players: table([('a', Role.tnt), ('b', Role.civilian)]));
      expect(s.neighborsOf('a'), ['b']);
    });
  });

  group('Player', () {
    test('value equality', () {
      expect(p('a', Role.civilian), p('a', Role.civilian));
      expect(p('a', Role.civilian), isNot(p('a', Role.doctor)));
      expect(p('a', Role.civilian).hashCode, p('a', Role.civilian).hashCode);
    });

    test('a Chameleon who picked a role plays it', () {
      const c = Player(id: 'c', name: 'c', role: Role.chameleon, chameleonRole: Role.doctor);
      expect(c.effectiveRole, Role.doctor);
      expect(p('c', Role.chameleon).effectiveRole, Role.chameleon);
    });
  });
}
