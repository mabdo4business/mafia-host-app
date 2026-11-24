import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

Player p(String id, Role role) => Player(id: id, name: id, role: role);

/// Every role at one table, in seat order (seat 0 sits next to the last).
/// Mafia Team: gf, maf, put, law, witch (5). Civilians Team: 13.
List<Player> fullTable() => [
      p('gf', Role.godfather),
      p('maf', Role.mafia),
      p('put', Role.putana),
      p('law', Role.lawyer),
      p('witch', Role.witch),
      p('det', Role.detective),
      p('doc', Role.doctor),
      p('joker', Role.joker),
      p('sw', Role.switchman),
      p('sil', Role.silencer),
      p('bomb', Role.bomb),
      p('shape', Role.shapeshifter),
      p('cham', Role.chameleon),
      p('tnt', Role.tnt),
      p('c1', Role.civilian),
      p('c2', Role.civilian),
      p('c3', Role.civilian),
      p('c4', Role.civilian),
    ];

/// A table from `(id, role)` pairs in seat order.
List<Player> table(List<(String, Role)> seats) => [for (final (id, role) in seats) p(id, role)];

GameState newGame({List<Player>? players, GameSettings settings = const GameSettings()}) =>
    GameState.initial(players: players ?? fullTable(), settings: settings);

bool isAlive(GameState s, String id) => s.player(id).isAlive;

/// Ids of everyone who died in [r], in event order.
List<String> deaths(Resolution r) => [
      for (final e in r.events)
        if (e is PlayerDied) e.playerId
    ];

PlayerDied deathOf(Resolution r, String id) =>
    r.events.whereType<PlayerDied>().firstWhere((e) => e.playerId == id);

Matcher throwsInvalid(InvalidActionReason reason) => throwsA(
      isA<InvalidActionException>().having((e) => e.reason, 'reason', reason),
    );

Matcher throwsSetup(InvalidSetupReason reason) => throwsA(
      isA<InvalidSetupException>().having((e) => e.reason, 'reason', reason),
    );

/// A day where nobody is eliminated; advances to the next night.
GameState skipDay(GameState s) => resolveDayVote(s, const {}).state;

/// Resolves a night and then skips the following day.
GameState nightThenSkipDay(GameState s, [List<NightAction> actions = const []]) =>
    skipDay(resolveNight(s, actions).state);

/// Plays quiet nights and days until night [n] begins.
GameState toNight(GameState s, int n) {
  while (s.nightNumber < n) {
    s = nightThenSkipDay(s);
  }
  return s;
}

/// Votes [targetId] out with every living, unsilenced player's vote.
Resolution voteOut(GameState s, String targetId) => resolveDayVoteTally(s, {targetId: 1});
