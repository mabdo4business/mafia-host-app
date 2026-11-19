import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/data/game_repository.dart';
import 'package:mafia_host/game/game_input.dart';
import 'package:mafia_host/game/game_session.dart';

import 'helpers.dart';

/// Plays and stores a finished game.
Future<void> finishGame(GameRepository repo, List<Player> players, List<GameInput> inputs) async {
  final setup = GameSetup(players: players, settings: const GameSettings());
  final id = await repo.createGame(setup);
  final session = GameSession.replay(id, setup, inputs);
  expect(session.stage, GameStage.gameOver);
  await repo.save(session);
}

void main() {
  test('player records and game nights come from finished games', () async {
    final repo = GameRepository(memoryDb());
    // Civilians win: the town votes out the Godfather (Sara).
    await finishGame(
      repo,
      [p('a', Role.godfather), p('b', Role.doctor), p('c', Role.civilian), p('d', Role.civilian)],
      const [
        NightInput([]),
        AdvanceInput(),
        TallyVoteInput({'a': 3}),
      ],
    );
    // Mafia win: the Godfather (B this time) kills one of two civilians.
    await finishGame(
      repo,
      [p('b', Role.godfather), p('a', Role.civilian), p('c', Role.civilian)],
      const [
        NightInput([MafiaKill('b', 'c')]),
      ],
    );
    // An abandoned game counts for nothing.
    await repo.createGame(
      GameSetup(players: [p('x', Role.civilian)], settings: const GameSettings()),
    );

    final records = {for (final r in await repo.playerRecords()) r.name: r};
    expect(records.keys, containsAll(['A', 'B', 'C', 'D']));
    expect(records['B']!.games, 2);
    expect(records['B']!.wins, 2, reason: 'won as Doctor, then as Godfather');
    expect(records['A']!.wins, 0);
    expect(records['C']!.wins, 1);
    expect(records['B']!.roles, {Role.doctor: 1, Role.godfather: 1});
    expect(records['D']!.favoriteRole, Role.civilian);
    expect(records['B']!.winRate, 100);

    final ranked = await repo.playerRecords();
    expect(ranked.first.name, 'B', reason: 'most wins first');

    final nights = await repo.gameNights();
    expect(nights, hasLength(1), reason: 'both games were played today');
    expect(nights.single.games, hasLength(2));
    expect(nights.single.players, ['A', 'B', 'C', 'D']);
  });
}
