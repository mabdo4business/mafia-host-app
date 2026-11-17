import 'package:mafia_engine/mafia_engine.dart';
import 'package:test/test.dart';

Player p(String id, Role role, {Role? as}) =>
    Player(id: id, name: id, role: role, chameleonRole: as);

/// A standard 12-player table: 4 Mafia-team, 8 Civilian-team.
List<Player> standardPlayers() => [
      p('gf', Role.godfather),
      p('maf', Role.mafia),
      p('pot', Role.potana),
      p('law', Role.lawyer),
      p('doc', Role.doctor),
      p('det', Role.detective),
      p('bomb', Role.bomb),
      p('joker', Role.joker),
      p('c1', Role.civilian),
      p('c2', Role.civilian),
      p('c3', Role.civilian),
      p('c4', Role.civilian),
    ];

GameState newGame({
  List<Player>? players,
  GameSettings settings = const GameSettings(),
}) =>
    GameState.initial(players: players ?? standardPlayers(), settings: settings);

bool isAlive(GameState s, String id) => s.player(id).isAlive;

Matcher throwsInvalid(InvalidActionReason reason) => throwsA(
      isA<InvalidActionException>().having((e) => e.reason, 'reason', reason),
    );

Matcher throwsSetup(InvalidSetupReason reason) => throwsA(
      isA<InvalidSetupException>().having((e) => e.reason, 'reason', reason),
    );

/// A day where nobody is eliminated; advances to the next night.
GameState skipDay(GameState s) => resolveDayVote(s, const {}).state;

/// Resolves a night and then skips the following day.
GameState nightThenSkipDay(GameState s, List<NightAction> actions) =>
    skipDay(resolveNight(s, actions).state);
