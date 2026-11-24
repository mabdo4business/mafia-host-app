import 'game_state.dart';
import 'roles.dart';

/// GAME_RULES Q13: Civilians win when the whole Mafia Team is gone; Mafia
/// win when the Mafia Team is at least (or, with `mafiaWinsAtParity` off,
/// more than) the Civilians Team alive. Null while the game goes on.
Team? checkWinner(GameState state) {
  final alive = state.alivePlayers;
  final mafia = alive.where((p) => p.team == Team.mafia).length;
  final civilians = alive.length - mafia;
  if (mafia == 0) return Team.civilians;
  final mafiaWin = state.settings.mafiaWinsAtParity ? mafia >= civilians : mafia > civilians;
  return mafiaWin ? Team.mafia : null;
}
