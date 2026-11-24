import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

GameState day1([List<NightAction> actions = const []]) => resolveNight(newGame(), actions).state;

void main() {
  group('Vote', () {
    test('the most-voted player is eliminated and the next night begins', () {
      final r = resolveDayVote(day1(), {'c1': 'c2', 'c3': 'c2', 'c4': 'c1'});
      expect(deaths(r), ['c2']);
      expect(deathOf(r, 'c2').causes, {DeathCause.vote});
      expect(r.state.phase, GamePhase.night);
      expect(r.state.nightNumber, 2);
    });

    test('a counted tally works the same way', () {
      final r = resolveDayVoteTally(day1(), {'c1': 3, 'c2': 5});
      expect(deaths(r), ['c2']);
    });

    test('nobody voting eliminates nobody', () {
      final r = resolveDayVote(day1(), {'c1': null});
      expect(deaths(r), isEmpty);
      expect(r.events, [const NoElimination()]);
      expect(r.state.nightNumber, 2);
    });

    test('only by day, from living voters, for living players', () {
      expect(() => resolveDayVote(newGame(), const {}), throwsInvalid(InvalidActionReason.wrongPhase));
      final s = day1([const MafiaKill('gf', 'c1')]);
      expect(
        () => resolveDayVote(s, {'c1': 'c2'}),
        throwsInvalid(InvalidActionReason.actorDead),
      );
      expect(
        () => resolveDayVote(s, {'c2': 'c1'}),
        throwsInvalid(InvalidActionReason.targetDead),
      );
    });

    test('a tally cannot count more votes than there are voters', () {
      expect(
        () => resolveDayVoteTally(day1(), {'c1': 19}),
        throwsInvalid(InvalidActionReason.tooManyVotes),
      );
      expect(
        () => resolveDayVoteTally(day1(), {'c1': -1}),
        throwsInvalid(InvalidActionReason.tooManyVotes),
      );
    });
  });

  group('Equal votes: re-vote', () {
    test('a tie for the most votes calls a re-vote between the tied players', () {
      final r = resolveDayVoteTally(day1(), {'c1': 3, 'c2': 3, 'c3': 1});
      expect(r.events, [
        const VoteTied(['c1', 'c2']),
        const RevoteRequired(['c1', 'c2']),
      ]);
      expect(r.state.phase, GamePhase.day);
      expect(r.state.revoteCandidates, ['c1', 'c2']);
      expect(deaths(r), isEmpty);
    });

    test('the re-vote is only between the tied players', () {
      final s = resolveDayVoteTally(day1(), {'c1': 3, 'c2': 3}).state;
      expect(
        () => resolveDayVoteTally(s, {'c3': 1}),
        throwsInvalid(InvalidActionReason.notACandidate),
      );
      final r = resolveDayVoteTally(s, {'c1': 2, 'c2': 4});
      expect(deaths(r), ['c2']);
      expect(r.state.revoteCandidates, isNull);
      expect(r.state.phase, GamePhase.night);
    });

    test('Q3 default: a second tie eliminates nobody', () {
      final s = resolveDayVoteTally(day1(), {'c1': 3, 'c2': 3}).state;
      final r = resolveDayVoteTally(s, {'c1': 2, 'c2': 2});
      expect(r.events, [
        const VoteTied(['c1', 'c2']),
        const NoElimination(),
      ]);
      expect(r.state.phase, GamePhase.night);
    });
  });

  group('Silenced players', () {
    test('cannot vote', () {
      final s = day1([const SilencerSilence('sil', 'c1')]);
      expect(
        () => resolveDayVote(s, {'c1': 'c2'}),
        throwsInvalid(InvalidActionReason.playerSilenced),
      );
      expect(s.voterCount, 17);
      expect(
        () => resolveDayVoteTally(s, {'c2': 18}),
        throwsInvalid(InvalidActionReason.tooManyVotes),
      );
    });

    test('can still be voted out', () {
      final s = day1([const SilencerSilence('sil', 'c1')]);
      expect(deaths(resolveDayVote(s, {'c2': 'c1'})), ['c1']);
    });

    test('Q11 default: the silence lasts the next day only', () {
      final s = skipDay(day1([const SilencerSilence('sil', 'c1')]));
      expect(s.isSilenced('c1'), isFalse);
      expect(resolveNight(s, const []).state.isSilenced('c1'), isFalse);
    });
  });

  group('Fouls', () {
    test('a Foul is counted per player for the whole game', () {
      var s = takeFoul(day1(), 'c1');
      s = takeFoul(s, 'c1');
      s = takeFoul(resolveNight(skipDay(s), const []).state, 'c1');
      expect(s.foulsOf('c1'), 3);
      expect(s.foulsOf('c2'), 0);
    });

    test('only by day, only for living players who may speak', () {
      expect(() => takeFoul(newGame(), 'c1'), throwsInvalid(InvalidActionReason.wrongPhase));
      expect(
        () => takeFoul(day1([const MafiaKill('gf', 'c1')]), 'c1'),
        throwsInvalid(InvalidActionReason.actorDead),
      );
      expect(
        () => takeFoul(day1([const SilencerSilence('sil', 'c1')]), 'c1'),
        throwsInvalid(InvalidActionReason.playerSilenced),
      );
    });
  });

  group('Host removes a player', () {
    test('the player leaves the game', () {
      final r = removePlayer(day1(), 'c1');
      expect(deaths(r), ['c1']);
      expect(deathOf(r, 'c1').causes, {DeathCause.removed});
      expect(r.state.phase, GamePhase.day, reason: 'the day goes on');
    });

    test('a removed TNT still explodes ("eliminated any way")', () {
      expect(deaths(removePlayer(day1(), 'tnt')), ['tnt', 'cham', 'c1']);
    });

    test('a removed Godfather or Bomb takes no one', () {
      expect(removePlayer(day1(), 'gf').state.pendingChoices, isEmpty);
      expect(deaths(removePlayer(day1(), 'bomb')), ['bomb']);
    });

    test('can end the game', () {
      final s = GameState.initial(players: table([
        ('gf', Role.godfather),
        ('c1', Role.civilian),
        ('c2', Role.civilian),
      ]));
      final r = removePlayer(resolveNight(s, const []).state, 'gf');
      expect(r.events.last, const GameOver(Team.civilians));
    });
  });

  group('Win check (Q13 default)', () {
    GameState small() => GameState.initial(players: table([
          ('gf', Role.godfather),
          ('maf', Role.mafia),
          ('c1', Role.civilian),
          ('c2', Role.civilian),
          ('c3', Role.civilian),
          ('c4', Role.civilian),
        ]));

    test('Civilians win when the whole Mafia Team is gone', () {
      var r = resolveNight(small(), const []);
      r = voteOut(r.state, 'maf');
      r = resolveNight(r.state, const []);
      r = voteOut(r.state, 'gf');
      r = resolveChoice(r.state, 'gf', const []);
      expect(r.state.winner, Team.civilians);
      expect(r.events.last, const GameOver(Team.civilians));
    });

    test('Mafia win when the Mafia Team is at least the Civilians Team', () {
      final s = nightThenSkipDay(small(), [const MafiaKill('gf', 'c1')]);
      final r = resolveNight(s, [const MafiaKill('gf', 'c2')]);
      expect(r.state.winner, Team.mafia);
      expect(r.state.phase, GamePhase.gameOver);
    });

    test('nothing resolves after game over', () {
      final s = resolveNight(nightThenSkipDay(small(), [const MafiaKill('gf', 'c1')]), [
        const MafiaKill('gf', 'c2'),
      ]).state;
      expect(() => resolveNight(s, const []), throwsInvalid(InvalidActionReason.wrongPhase));
      expect(() => resolveDayVote(s, const {}), throwsInvalid(InvalidActionReason.wrongPhase));
    });
  });
}
