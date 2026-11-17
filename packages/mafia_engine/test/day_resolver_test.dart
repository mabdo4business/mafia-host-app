import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  GameState dayState({
    GameSettings settings = const GameSettings(),
    List<Player>? players,
  }) =>
      resolveNight(newGame(settings: settings, players: players), const []).state;

  group('Day vote', () {
    test('the player with the most votes is eliminated and night 2 begins', () {
      final r = resolveDayVote(dayState(), {'c1': 'maf', 'c2': 'maf', 'c3': 'c4'});
      expect(r.events, [
        const PlayerDied('maf', {DeathCause.vote})
      ]);
      expect(isAlive(r.state, 'maf'), isFalse);
      expect(r.state.phase, GamePhase.night);
      expect(r.state.nightNumber, 2);
    });

    test('abstentions are ignored', () {
      final r = resolveDayVote(dayState(), {'c1': 'maf', 'c2': null, 'c3': null});
      expect(isAlive(r.state, 'maf'), isFalse);
    });

    test('no votes → no elimination', () {
      final r = resolveDayVote(dayState(), const {});
      expect(r.events, [const NoElimination()]);
      expect(r.state.alivePlayers, hasLength(12));
      expect(r.state.phase, GamePhase.night);
      expect(r.state.nightNumber, 2);
    });

    test('dead players cannot vote', () {
      final s = resolveNight(newGame(), [const MafiaKill('gf', 'c1')]).state;
      expect(
        () => resolveDayVote(s, {'c1': 'maf'}),
        throwsInvalid(InvalidActionReason.actorDead),
      );
    });

    test('cannot vote for a dead player', () {
      final s = resolveNight(newGame(), [const MafiaKill('gf', 'c1')]).state;
      expect(
        () => resolveDayVote(s, {'c2': 'c1'}),
        throwsInvalid(InvalidActionReason.targetDead),
      );
    });

    test('unknown voter', () {
      expect(
        () => resolveDayVote(dayState(), {'ghost': 'maf'}),
        throwsInvalid(InvalidActionReason.unknownPlayer),
      );
    });

    test('cannot vote at night', () {
      expect(
        () => resolveDayVote(newGame(), const {}),
        throwsInvalid(InvalidActionReason.wrongPhase),
      );
    });

    test('revealRoleOnDeath includes the role', () {
      final r = resolveDayVote(
        dayState(settings: const GameSettings(revealRoleOnDeath: true)),
        {'c1': 'gf'},
      );
      expect(r.events, [
        const PlayerDied('gf', {DeathCause.vote}, revealedRole: Role.godfather)
      ]);
    });
  });

  group('Tie votes', () {
    const tiedVotes = {'c1': 'maf', 'c2': 'c3'};

    test('hostDecides without a decision asks the host and keeps the state', () {
      final s = dayState();
      final r = resolveDayVote(s, tiedVotes);
      expect(r.events, [
        const VoteTied(['maf', 'c3']),
        const HostDecisionRequired()
      ]);
      expect(identical(r.state, s), isTrue);
    });

    test('hostDecides with a tie-breaker eliminates that candidate', () {
      final r = resolveDayVote(dayState(), tiedVotes, tieBreakerId: 'maf');
      expect(r.events, [
        const VoteTied(['maf', 'c3']),
        const PlayerDied('maf', {DeathCause.vote}),
      ]);
      expect(r.state.phase, GamePhase.night);
    });

    test('the tie-breaker must be one of the tied candidates', () {
      expect(
        () => resolveDayVote(dayState(), tiedVotes, tieBreakerId: 'c4'),
        throwsInvalid(InvalidActionReason.tieBreakerNotTied),
      );
    });

    test('revote asks for a new vote and keeps the state', () {
      final s = dayState(settings: const GameSettings(tieVoteRule: TieVoteRule.revote));
      final r = resolveDayVote(s, tiedVotes);
      expect(r.events, [
        const VoteTied(['maf', 'c3']),
        const RevoteRequired()
      ]);
      expect(identical(r.state, s), isTrue);

      final again = resolveDayVote(r.state, {'c1': 'maf', 'c2': 'maf'});
      expect(isAlive(again.state, 'maf'), isFalse);
    });

    test('noElimination ends the day with nobody out', () {
      final r = resolveDayVote(
        dayState(settings: const GameSettings(tieVoteRule: TieVoteRule.noElimination)),
        tiedVotes,
      );
      expect(r.events, [
        const VoteTied(['maf', 'c3']),
        const NoElimination()
      ]);
      expect(r.state.alivePlayers, hasLength(12));
      expect(r.state.phase, GamePhase.night);
    });
  });

  group('Day win checks', () {
    test('voting out the last Mafia member → Civilians win', () {
      final r = resolveDayVote(
        dayState(players: [
          p('gf', Role.godfather),
          p('c1', Role.civilian),
          p('c2', Role.civilian),
          p('c3', Role.civilian)
        ]),
        {'c1': 'gf'},
      );
      expect(r.events.last, const GameOver(Team.civilians));
      expect(r.state.phase, GamePhase.gameOver);
      expect(
        () => resolveDayVote(r.state, const {}),
        throwsInvalid(InvalidActionReason.wrongPhase),
      );
      expect(
        () => resolveNight(r.state, const []),
        throwsInvalid(InvalidActionReason.wrongPhase),
      );
    });

    test('voting out a civilian so Mafia >= civilians → Mafia win', () {
      final r = resolveDayVote(
        dayState(players: [
          p('gf', Role.godfather),
          p('maf', Role.mafia),
          p('c1', Role.civilian),
          p('c2', Role.civilian),
          p('c3', Role.civilian),
        ]),
        {'gf': 'c1', 'maf': 'c1'},
      );
      expect(r.state.winner, Team.mafia);
    });
  });
}
