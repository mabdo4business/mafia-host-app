// Internal helpers shared by the resolvers. Not exported.

import 'game_event.dart';
import 'game_state.dart';
import 'roles.dart';
import 'win_checker.dart';

/// Kills every player in [deaths] (iterated in the map's order, which callers
/// keep in seating order), emits death events, then triggers any Bombs.
GameState applyDeaths(
  GameState state,
  Map<String, Set<DeathCause>> deaths,
  List<GameEvent> events,
) {
  if (deaths.isEmpty) return state;

  final players = [
    for (final p in state.players) deaths.containsKey(p.id) ? p.copyWith(isAlive: false) : p,
  ];
  for (final MapEntry(key: id, value: causes) in deaths.entries) {
    events.add(PlayerDied(
      id,
      Set.of(causes),
      revealedRole: state.settings.revealRoleOnDeath ? state.player(id).role : null,
    ));
  }

  final pending = [...state.pendingBombs];
  final blocked = state.lastNight?.blockedPlayerIds ?? const {};
  for (final id in deaths.keys) {
    if (state.player(id).effectiveRole != Role.bomb) continue;
    if (blocked.contains(id) && !state.settings.blockedBombStillExplodes) {
      events.add(BombDefused(id));
    } else {
      events.add(BombTriggered(id));
      pending.add(id);
    }
  }
  return state.copyWith(players: players, pendingBombs: pending);
}

/// Runs the win check once nothing is left pending.
GameState settle(GameState state, List<GameEvent> events) {
  if (state.pendingBombs.isNotEmpty || state.phase == GamePhase.gameOver) {
    return state;
  }
  final winner = checkWinner(state);
  if (winner == null) return state;
  events.add(GameOver(winner));
  return state.copyWith(phase: GamePhase.gameOver, winner: winner);
}

/// Restricts [ids] to seating order so output never depends on input order.
List<String> inSeatingOrder(GameState state, Iterable<String> ids) {
  final wanted = ids.toSet();
  return [
    for (final p in state.players)
      if (wanted.contains(p.id)) p.id
  ];
}
