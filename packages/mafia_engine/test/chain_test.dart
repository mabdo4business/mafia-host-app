import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// Night 2 with the Witch's link on c1 + c2 made.
GameState linked() =>
    nightThenSkipDay(toNight(newGame(), 2), [const WitchLink('witch', 'c1', 'c2')]);

/// Night 3 with the Bomb's charges on c1 + c2 planted.
GameState planted() =>
    nightThenSkipDay(toNight(newGame(), 2), [const BombPlant('bomb', 'c1', 'c2')]);

/// Night 4 with the Detective's chain armed: three checks, two Mafia found.
GameState armed() {
  var s = nightThenSkipDay(newGame(), [const DetectiveCheck('det', 'maf')]);
  s = nightThenSkipDay(s, [const DetectiveCheck('det', 'c1')]);
  return nightThenSkipDay(s, [const DetectiveCheck('det', 'law')]);
}

void main() {
  group('Witch link', () {
    test('a linked player killed at night takes the other with them', () {
      final r = resolveNight(linked(), [const MafiaKill('gf', 'c1')]);
      expect(deaths(r), ['c1', 'c2']);
      expect(deathOf(r, 'c2').causes, {DeathCause.witchLink});
      expect(deathOf(r, 'c2').causedBy, 'c1');
    });

    test('either side triggers it', () {
      final r = resolveNight(linked(), [const JokerKill('joker', 'c2')]);
      expect(deaths(r), ['c2', 'c1']);
    });

    test('voting does not trigger the link', () {
      final r = voteOut(resolveNight(linked(), const []).state, 'c1');
      expect(deaths(r), ['c1']);
      expect(isAlive(r.state, 'c2'), isTrue);
    });

    test('stays active after the Witch dies', () {
      var s = toNight(newGame(), 2);
      s = nightThenSkipDay(s, [
        const WitchLink('witch', 'c1', 'c2'),
        const JokerKill('joker', 'witch'),
      ]);
      expect(isAlive(s, 'witch'), isFalse);
      expect(deaths(resolveNight(s, [const MafiaKill('gf', 'c1')])), ['c1', 'c2']);
    });

    test('chain deaths at night trigger it too', () {
      final s = nightThenSkipDay(toNight(newGame(), 2), [
        const WitchLink('witch', 'c1', 'c3'),
      ]);
      // TNT's neighbor c1 dies at night, so c3 follows.
      final r = resolveNight(s, [const MafiaKill('gf', 'tnt')]);
      expect(deaths(r), ['tnt', 'cham', 'c1', 'c3']);
    });
  });

  group('Bomb', () {
    test('killed at night: the two planted players die too', () {
      final r = resolveNight(planted(), [const MafiaKill('gf', 'bomb')]);
      expect(deaths(r), ['bomb', 'c1', 'c2']);
      expect(deathOf(r, 'c1').causes, {DeathCause.bomb});
      expect(deathOf(r, 'c1').causedBy, 'bomb');
      expect(r.events, contains(const BombExploded('bomb')));
    });

    test('voted out: the two planted players die too', () {
      final r = voteOut(resolveNight(planted(), const []).state, 'bomb');
      expect(deaths(r), ['bomb', 'c1', 'c2']);
    });

    test('a planted player who is already dead is skipped', () {
      final s = nightThenSkipDay(planted(), [const MafiaKill('gf', 'c1')]);
      final r = resolveNight(s, [const JokerKill('joker', 'bomb')]);
      expect(deaths(r), ['bomb', 'c2']);
    });

    test('voted out on day 1: the host picks both neighbors or no one', () {
      final day1 = resolveNight(newGame(), const []).state;
      final r = voteOut(day1, 'bomb');
      expect(deaths(r), ['bomb']);
      const choice = PendingChoice('bomb', ChoiceKind.bombTakesNeighbors, options: ['sil', 'shape']);
      expect(r.state.pendingChoices, [choice]);
      expect(r.events, contains(const ChoiceRequired(choice)));

      final both = resolveChoice(r.state, 'bomb', ['sil', 'shape']);
      expect(deaths(both), ['sil', 'shape']);
      expect(deathOf(both, 'sil').causes, {DeathCause.bomb});
      expect(both.state.pendingChoices, isEmpty);

      expect(deaths(resolveChoice(r.state, 'bomb', const [])), isEmpty);
      expect(
        () => resolveChoice(r.state, 'bomb', ['sil']),
        throwsInvalid(InvalidActionReason.invalidChoice),
      );
      expect(
        () => resolveChoice(r.state, 'bomb', ['sil', 'c1']),
        throwsInvalid(InvalidActionReason.invalidChoice),
      );
    });

    test('Q10 default: dying on night 1, before planting, has no effect', () {
      final r = resolveNight(newGame(), [const MafiaKill('gf', 'bomb')]);
      expect(deaths(r), ['bomb']);
      expect(r.state.pendingChoices, isEmpty);
    });

    test('voted out after day 1 without having planted: no effect', () {
      final s = nightThenSkipDay(toNight(newGame(), 2), [
        const PutanaBlock('put', 'bomb'),
        const BombPlant('bomb', 'c1', 'c2'),
      ]);
      final r = voteOut(resolveNight(s, const []).state, 'bomb');
      expect(deaths(r), ['bomb']);
      expect(r.state.pendingChoices, isEmpty);
    });
  });

  group('TNT', () {
    test('killed at night: both neighbors die', () {
      final r = resolveNight(newGame(), [const MafiaKill('gf', 'tnt')]);
      expect(deaths(r), ['tnt', 'cham', 'c1']);
      expect(deathOf(r, 'cham').causes, {DeathCause.tnt});
      expect(deathOf(r, 'cham').causedBy, 'tnt');
    });

    test('voted out: both neighbors die', () {
      final r = voteOut(resolveNight(newGame(), const []).state, 'tnt');
      expect(deaths(r), ['tnt', 'cham', 'c1']);
    });

    test('neighbors wrap around the table and skip empty seats', () {
      final s = GameState.initial(players: table([
        ('tnt', Role.tnt),
        ('a', Role.civilian),
        ('gf', Role.godfather),
        ('b', Role.civilian),
        ('c', Role.civilian),
        ('d', Role.civilian),
      ]));
      final next = nightThenSkipDay(s, [const MafiaKill('gf', 'a')]);
      final r = resolveNight(next, [const MafiaKill('gf', 'tnt')]);
      expect(deaths(r), ['tnt', 'gf', 'd']);
    });

    test('neighbors are counted from the table before the explosion', () {
      // c1 and TNT die together; TNT takes cham and c1's seat is not refilled by c2.
      final r = resolveNight(newGame(), [
        const MafiaKill('gf', 'tnt'),
        const JokerKill('joker', 'c1'),
      ]);
      expect(deaths(r), ['tnt', 'c1', 'cham']);
      expect(isAlive(r.state, 'c2'), isTrue);
    });
  });

  group('Detective chain', () {
    test('three checks with two Mafia found arms the chain', () {
      var s = nightThenSkipDay(newGame(), [const DetectiveCheck('det', 'maf')]);
      s = nightThenSkipDay(s, [const DetectiveCheck('det', 'c1')]);
      final r = resolveNight(s, [const DetectiveCheck('det', 'law')]);
      expect(r.events, contains(const DetectiveChainArmed('det', ['maf', 'law'])));
      expect(r.state.detectiveRecords['det'], const DetectiveRecord(checks: 3, mafiaFound: ['maf', 'law']));
    });

    test('the Detective killed later takes the two identified Mafia', () {
      final r = resolveNight(armed(), [const MafiaKill('gf', 'det')]);
      expect(deaths(r), ['det', 'maf', 'law']);
      expect(deathOf(r, 'maf').causes, {DeathCause.detectiveChain});
      expect(deathOf(r, 'maf').causedBy, 'det');
    });

    test('two checks are not enough, even with two Mafia found', () {
      var s = nightThenSkipDay(newGame(), [const DetectiveCheck('det', 'maf')]);
      s = nightThenSkipDay(s, [const DetectiveCheck('det', 'law')]);
      expect(deaths(resolveNight(s, [const MafiaKill('gf', 'det')])), ['det']);
    });

    test('three checks with one Mafia found do not arm it', () {
      var s = nightThenSkipDay(newGame(), [const DetectiveCheck('det', 'maf')]);
      s = nightThenSkipDay(s, [const DetectiveCheck('det', 'c1')]);
      s = nightThenSkipDay(s, [const DetectiveCheck('det', 'c2')]);
      expect(deaths(resolveNight(s, [const MafiaKill('gf', 'det')])), ['det']);
    });

    test('Q5 default: being voted out does not trigger it', () {
      final r = voteOut(resolveNight(armed(), const []).state, 'det');
      expect(deaths(r), ['det']);
    });

    test('an identified Mafia player who already died is skipped', () {
      final s = nightThenSkipDay(armed(), [const JokerKill('joker', 'maf')]);
      expect(deaths(resolveNight(s, [const MafiaKill('gf', 'det')])), ['det', 'law']);
    });
  });

  group('Godfather voted out', () {
    test('takes one player of his choice with him', () {
      final r = voteOut(resolveNight(newGame(), const []).state, 'gf');
      const choice = PendingChoice('gf', ChoiceKind.godfatherTakesOne);
      expect(r.state.pendingChoices, [choice]);
      expect(r.events, contains(const ChoiceRequired(choice)));

      final took = resolveChoice(r.state, 'gf', ['c1']);
      expect(deaths(took), ['c1']);
      expect(deathOf(took, 'c1').causes, {DeathCause.godfather});
      expect(deathOf(took, 'c1').causedBy, 'gf');
    });

    test('or no one', () {
      final r = voteOut(resolveNight(newGame(), const []).state, 'gf');
      expect(deaths(resolveChoice(r.state, 'gf', const [])), isEmpty);
    });

    test('one player at most, alive, not himself', () {
      final s = voteOut(resolveNight(newGame(), const []).state, 'gf').state;
      for (final bad in [
        ['c1', 'c2'],
        ['gf'],
      ]) {
        expect(() => resolveChoice(s, 'gf', bad), throwsInvalid(InvalidActionReason.invalidChoice));
      }
    });

    test('killed at night he takes no one', () {
      final r = resolveNight(newGame(), [const JokerKill('joker', 'gf')]);
      expect(r.state.pendingChoices, isEmpty);
    });

    test('the next night waits for the choice', () {
      final s = voteOut(resolveNight(newGame(), const []).state, 'gf').state;
      expect(() => resolveNight(s, const []), throwsInvalid(InvalidActionReason.choicePending));
      expect(
        () => resolveChoice(s, 'c1', const []),
        throwsInvalid(InvalidActionReason.noChoicePending),
      );
    });
  });

  group('Chains in a loop until no new deaths', () {
    test('a Bomb charge on TNT sets off TNT', () {
      final s = nightThenSkipDay(toNight(newGame(), 2), [const BombPlant('bomb', 'tnt', 'c3')]);
      final r = resolveNight(s, [const MafiaKill('gf', 'bomb')]);
      expect(deaths(r), ['bomb', 'tnt', 'c3', 'cham', 'c1']);
      expect(deathOf(r, 'cham').causedBy, 'tnt');
    });

    test('the Godfather taking TNT sets off TNT', () {
      final s = voteOut(resolveNight(newGame(), const []).state, 'gf').state;
      expect(deaths(resolveChoice(s, 'gf', ['tnt'])), ['tnt', 'cham', 'c1']);
    });

    test('a chain death of the armed Detective at night sets off the Detective chain', () {
      final s = GameState.initial(players: table([
        ('gf', Role.godfather),
        ('maf', Role.mafia),
        ('law', Role.lawyer),
        ('det', Role.detective),
        ('tnt', Role.tnt),
        ('c1', Role.civilian),
        ('c2', Role.civilian),
        ('c3', Role.civilian),
        ('c4', Role.civilian),
        ('c5', Role.civilian),
      ]));
      var n = nightThenSkipDay(s, [const DetectiveCheck('det', 'maf')]);
      n = nightThenSkipDay(n, [const DetectiveCheck('det', 'c1')]);
      n = nightThenSkipDay(n, [const DetectiveCheck('det', 'law')]);
      final r = resolveNight(n, [const MafiaKill('gf', 'tnt')]);
      expect(deaths(r), ['tnt', 'det', 'c1', 'maf', 'law']);
    });

    test('the win check waits until every choice is made', () {
      final s = GameState.initial(players: table([
        ('gf', Role.godfather),
        ('c1', Role.civilian),
        ('c2', Role.civilian),
        ('c3', Role.civilian),
      ]));
      final r = voteOut(resolveNight(s, const []).state, 'gf');
      expect(r.events.whereType<GameOver>(), isEmpty);
      final done = resolveChoice(r.state, 'gf', ['c1']);
      expect(done.events, contains(const GameOver(Team.civilians)));
      expect(done.state.phase, GamePhase.gameOver);
    });
  });
}
