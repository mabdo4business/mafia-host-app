import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  GameState bombKilledAtNight({
    GameSettings settings = const GameSettings(),
    List<Player>? players,
    List<NightAction> extra = const [],
  }) =>
      resolveNight(
        newGame(settings: settings, players: players),
        [const MafiaKill('gf', 'bomb'), ...extra],
      ).state;

  group('Bomb trigger', () {
    test('a Bomb killed at night triggers and waits for victims', () {
      final r = resolveNight(newGame(), [const MafiaKill('gf', 'bomb')]);
      expect(r.events, [
        const PlayerDied('bomb', {DeathCause.mafia}),
        const BombTriggered('bomb'),
      ]);
      expect(r.state.pendingBombs, ['bomb']);
      expect(r.state.bombVictimsRequired, 2);
    });

    test('a Bomb voted out by day triggers', () {
      final day = resolveNight(newGame(), const []).state;
      final r = resolveDayVote(day, {'c1': 'bomb', 'c2': 'bomb'});
      expect(r.events, [
        const PlayerDied('bomb', {DeathCause.vote}),
        const BombTriggered('bomb'),
      ]);
      expect(r.state.pendingBombs, ['bomb']);
      expect(r.state.phase, GamePhase.night);
      expect(
        () => resolveNight(r.state, const []),
        throwsInvalid(InvalidActionReason.bombDetonationPending),
      );

      final after = detonateBomb(r.state, 'bomb', ['maf', 'c3']);
      expect(after.state.pendingBombs, isEmpty);
      expect(after.state.phase, GamePhase.night);
      expect(after.state.nightNumber, 2);
    });

    test('a blocked Bomb still explodes by default', () {
      final r = resolveNight(newGame(), [
        const PotanaBlock('pot', 'bomb'),
        const MafiaKill('gf', 'bomb'),
      ]);
      expect(r.events, contains(const BombTriggered('bomb')));
      expect(r.state.pendingBombs, ['bomb']);
    });

    test('a blocked Bomb is defused when blockedBombStillExplodes = false', () {
      final r = resolveNight(
        newGame(settings: const GameSettings(blockedBombStillExplodes: false)),
        [const PotanaBlock('pot', 'bomb'), const MafiaKill('gf', 'bomb')],
      );
      expect(r.events, [
        const PlayerBlocked('bomb'),
        const PlayerDied('bomb', {DeathCause.mafia}),
        const BombDefused('bomb'),
      ]);
      expect(r.state.pendingBombs, isEmpty);
    });

    test("a night block does not defuse a Bomb voted out the next day", () {
      final day = resolveNight(
        newGame(settings: const GameSettings(blockedBombStillExplodes: false)),
        [const PotanaBlock('pot', 'bomb')],
      ).state;
      final r = resolveDayVote(day, {'c1': 'bomb'});
      expect(r.events, contains(const BombTriggered('bomb')));
    });
  });

  group('Bomb detonation', () {
    test('kills the chosen victims immediately', () {
      final r = detonateBomb(bombKilledAtNight(), 'bomb', ['maf', 'c2']);
      expect(r.events, [
        const PlayerDied('maf', {DeathCause.bomb}),
        const PlayerDied('c2', {DeathCause.bomb}),
      ]);
      expect(isAlive(r.state, 'maf'), isFalse);
      expect(isAlive(r.state, 'c2'), isFalse);
      expect(r.state.pendingBombs, isEmpty);
    });

    test('the host can set 3 victims', () {
      final s = bombKilledAtNight(settings: const GameSettings(bombVictimCount: 3));
      expect(s.bombVictimsRequired, 3);
      expect(
        () => detonateBomb(s, 'bomb', ['c1', 'c2']),
        throwsInvalid(InvalidActionReason.wrongVictimCount),
      );
      final r = detonateBomb(s, 'bomb', ['c1', 'c2', 'c3']);
      expect(r.events.whereType<PlayerDied>(), hasLength(3));
    });

    test('rejects the wrong number of victims', () {
      final s = bombKilledAtNight();
      expect(
        () => detonateBomb(s, 'bomb', ['c1']),
        throwsInvalid(InvalidActionReason.wrongVictimCount),
      );
      expect(
        () => detonateBomb(s, 'bomb', ['c1', 'c2', 'c3']),
        throwsInvalid(InvalidActionReason.wrongVictimCount),
      );
    });

    test('rejects dead, unknown or duplicate victims', () {
      final s = bombKilledAtNight();
      expect(
        () => detonateBomb(s, 'bomb', ['bomb', 'c1']),
        throwsInvalid(InvalidActionReason.targetDead),
      );
      expect(
        () => detonateBomb(s, 'bomb', ['ghost', 'c1']),
        throwsInvalid(InvalidActionReason.unknownPlayer),
      );
      expect(
        () => detonateBomb(s, 'bomb', ['c1', 'c1']),
        throwsInvalid(InvalidActionReason.invalidTarget),
      );
    });

    test('only a pending Bomb can detonate', () {
      expect(
        () => detonateBomb(newGame(), 'bomb', ['c1', 'c2']),
        throwsInvalid(InvalidActionReason.bombNotPending),
      );
    });

    test('with fewer players alive than N, the Bomb takes everyone left', () {
      // Alive after the night: gf, c1, c2 → exactly 3.
      final s = bombKilledAtNight(
        settings: const GameSettings(bombVictimCount: 3),
        players: [
          p('gf', Role.godfather),
          p('bomb', Role.bomb),
          p('c1', Role.civilian),
          p('c2', Role.civilian)
        ],
      );
      expect(s.bombVictimsRequired, 3);

      // Alive after the night: gf, c1 → only 2.
      final small = bombKilledAtNight(
        settings: const GameSettings(bombVictimCount: 3),
        players: [p('gf', Role.godfather), p('bomb', Role.bomb), p('c1', Role.civilian)],
      );
      expect(small.bombVictimsRequired, 2);
      final r = detonateBomb(small, 'bomb', ['gf', 'c1']);
      expect(r.state.alivePlayers, isEmpty);
    });

    test('chain: a victim who is also a Bomb explodes too', () {
      final players = [...standardPlayers(), p('ch', Role.chameleon, as: Role.bomb)];
      final s = bombKilledAtNight(players: players);

      final first = detonateBomb(s, 'bomb', ['ch', 'c1']);
      expect(first.events, [
        const PlayerDied('c1', {DeathCause.bomb}),
        const PlayerDied('ch', {DeathCause.bomb}),
        const BombTriggered('ch'),
      ]);
      expect(first.state.pendingBombs, ['ch']);

      final second = detonateBomb(first.state, 'ch', ['maf', 'c2']);
      expect(isAlive(second.state, 'maf'), isFalse);
      expect(isAlive(second.state, 'c2'), isFalse);
      expect(second.state.pendingBombs, isEmpty);
    });

    test('the Doctor cannot save Bomb victims by default', () {
      final s = bombKilledAtNight(extra: [const DoctorSave('doc', 'c1')]);
      final r = detonateBomb(s, 'bomb', ['c1', 'c2']);
      expect(isAlive(r.state, 'c1'), isFalse);
    });

    test("doctorCanSaveBombVictims = true: that night's save protects a victim", () {
      final s = bombKilledAtNight(
        settings: const GameSettings(doctorCanSaveBombVictims: true),
        extra: [const DoctorSave('doc', 'c1')],
      );
      final r = detonateBomb(s, 'bomb', ['c1', 'c2']);
      expect(isAlive(r.state, 'c1'), isTrue);
      expect(isAlive(r.state, 'c2'), isFalse);
      expect(r.events, [
        const PlayerSaved('c1', {DeathCause.bomb}),
        const PlayerDied('c2', {DeathCause.bomb}),
      ]);
    });

    test('a blocked Doctor cannot save Bomb victims even when allowed', () {
      final s = bombKilledAtNight(
        settings: const GameSettings(doctorCanSaveBombVictims: true),
        extra: [const PotanaBlock('pot', 'doc'), const DoctorSave('doc', 'c1')],
      );
      final r = detonateBomb(s, 'bomb', ['c1', 'c2']);
      expect(isAlive(r.state, 'c1'), isFalse);
    });

    test("a night save does not carry over to a day-vote explosion", () {
      final day = resolveNight(
        newGame(settings: const GameSettings(doctorCanSaveBombVictims: true)),
        [const DoctorSave('doc', 'c1')],
      ).state;
      final voted = resolveDayVote(day, {'c2': 'bomb'}).state;
      final r = detonateBomb(voted, 'bomb', ['c1', 'c2']);
      expect(isAlive(r.state, 'c1'), isFalse);
    });

    test('the win check waits until the Bomb has exploded', () {
      final s = bombKilledAtNight(players: [
        p('gf', Role.godfather),
        p('maf', Role.mafia),
        p('bomb', Role.bomb),
        p('c1', Role.civilian),
        p('c2', Role.civilian),
      ]);
      // Mafia 2 vs civilians 2 would be a Mafia win — but the Bomb is pending.
      expect(s.winner, isNull);
      expect(s.phase, GamePhase.day);

      final r = detonateBomb(s, 'bomb', ['gf', 'maf']);
      expect(r.events.last, const GameOver(Team.civilians));
      expect(r.state.winner, Team.civilians);
      expect(r.state.phase, GamePhase.gameOver);
    });

    test('day vote is blocked while a Bomb is pending', () {
      expect(
        () => resolveDayVote(bombKilledAtNight(), {'c1': 'c2'}),
        throwsInvalid(InvalidActionReason.bombDetonationPending),
      );
    });
  });
}
