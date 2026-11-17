import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  GameState table(
    List<Player> players, {
    Set<String> dead = const {},
    GameSettings settings = const GameSettings(),
  }) {
    final s = newGame(players: players, settings: settings);
    return s.copyWith(players: [
      for (final pl in s.players) dead.contains(pl.id) ? pl.copyWith(isAlive: false) : pl,
    ]);
  }

  test('no winner at the start of a normal game', () {
    expect(checkWinner(newGame()), isNull);
  });

  test('Civilians win when no Mafia is left', () {
    final s = table(
      [p('gf', Role.godfather), p('law', Role.lawyer), p('c1', Role.civilian)],
      dead: {'gf', 'law'},
    );
    expect(checkWinner(s), Team.civilians);
  });

  test('Mafia win when Mafia equals the civilian team', () {
    final s = table([p('gf', Role.godfather), p('c1', Role.civilian)]);
    expect(checkWinner(s), Team.mafia);
  });

  test('Mafia win when Mafia outnumber the civilian team', () {
    final s = table(
      [
        p('gf', Role.godfather),
        p('maf', Role.mafia),
        p('c1', Role.civilian),
        p('c2', Role.civilian)
      ],
      dead: {'c2'},
    );
    expect(checkWinner(s), Team.mafia);
  });

  test('no winner while Mafia are fewer than the civilian team', () {
    final s = table([p('gf', Role.godfather), p('c1', Role.civilian), p('c2', Role.civilian)]);
    expect(checkWinner(s), isNull);
  });

  test('Joker and Bomb count for the civilian team', () {
    final players = [
      p('gf', Role.godfather),
      p('maf', Role.mafia),
      p('joker', Role.joker),
      p('bomb', Role.bomb),
      p('c1', Role.civilian),
    ];
    expect(checkWinner(table(players)), isNull);
    expect(checkWinner(table(players, dead: {'c1'})), Team.mafia);
  });

  test('a Chameleon counts for the team of the role it plays', () {
    const allow = GameSettings(chameleonCanPickMafiaRoles: true);
    final asMafia = [
      p('gf', Role.godfather),
      p('ch', Role.chameleon, as: Role.mafia),
      p('c1', Role.civilian),
      p('c2', Role.civilian),
    ];
    expect(checkWinner(table(asMafia, settings: allow)), Team.mafia);

    final asDoctor = [
      p('gf', Role.godfather),
      p('ch', Role.chameleon, as: Role.doctor),
      p('c1', Role.civilian),
    ];
    expect(checkWinner(table(asDoctor)), isNull);
  });

  test('if nobody is alive, Civilians win (no Mafia left)', () {
    final s = table([p('gf', Role.godfather), p('c1', Role.civilian)], dead: {'gf', 'c1'});
    expect(checkWinner(s), Team.civilians);
  });

  test('dead Mafia do not count', () {
    final s = table(
      [
        p('gf', Role.godfather),
        p('maf', Role.mafia),
        p('c1', Role.civilian),
        p('c2', Role.civilian)
      ],
      dead: {'maf'},
    );
    expect(checkWinner(s), isNull);
  });
}
