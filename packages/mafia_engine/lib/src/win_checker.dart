import 'game_state.dart';
import 'roles.dart';

/// Civilians win when no Mafia is left; Mafia win when they are at least as
/// many as the living civilian team. Returns null while the game goes on.
Team? checkWinner(GameState state) {
  final alive = state.alivePlayers;
  final mafia = alive.where((p) => p.team == Team.mafia).length;
  final civilians = alive.length - mafia;
  if (mafia == 0) return Team.civilians;
  if (mafia >= civilians) return Team.mafia;
  return null;
}
