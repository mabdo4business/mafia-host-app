import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mafia_host/data/database.dart';
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
        ChoiceInput('a', []),
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

  test('games played under the old rules still count, but are not replayed', () async {
    final db = memoryDb();
    final repo = GameRepository(db);
    Future<int> legacy(GameStatus status, {String? winner}) async {
      final id = await db
          .into(db.games)
          .insert(
            GamesCompanion.insert(
              createdAt: DateTime(2026, 11, 1),
              settingsJson: '{"bombVictimCount":2,"tieVoteRule":"hostDecides"}',
              status: status,
              winner: Value(winner),
            ),
          );
      for (final (seat, (name, role, picked)) in const [
        ('Old A', 'potana', null),
        ('Old B', 'chameleon', 'godfather'),
        ('Old C', 'civilian', null),
      ].indexed) {
        await db
            .into(db.gamePlayers)
            .insert(
              GamePlayersCompanion.insert(
                gameId: id,
                seat: seat,
                playerId: 'p$seat',
                name: name,
                role: role,
                chameleonRole: Value(picked),
              ),
            );
      }
      // An old-format input today's engine can't replay.
      await db
          .into(db.gameInputs)
          .insert(
            GameInputsCompanion.insert(
              gameId: id,
              seq: 0,
              payloadJson:
                  '{"type":"night","actions":[{"type":"potanaBlock","actor":"p0","target":"p2"}]}',
            ),
          );
      return id;
    }

    await legacy(GameStatus.finished, winner: 'mafia');
    final records = {for (final r in await repo.playerRecords()) r.name: r};
    expect(records['Old A']!.wins, 1);
    expect(records['Old A']!.roles, {Role.putana: 1});
    expect(records['Old B']!.wins, 1, reason: 'a Chameleon who picked a Mafia role');
    expect(records['Old C']!.wins, 0);
    expect((await repo.recentGames()).single.nights, 1);

    // An unfinished old game can't be continued: it is set aside.
    await legacy(GameStatus.active);
    expect(await repo.loadActiveGame(), isNull);
    expect((await repo.tableStats()).games, 1);
  });
}
