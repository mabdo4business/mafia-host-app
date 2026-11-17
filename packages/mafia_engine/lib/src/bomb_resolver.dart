import 'deaths.dart';
import 'exceptions.dart';
import 'game_event.dart';
import 'game_state.dart';

/// A triggered Bomb takes [victimIds] with it. Victims die immediately; any
/// victim who is also a Bomb triggers in turn (chain). The win check runs
/// once no Bomb is pending.
Resolution detonateBomb(GameState state, String bombId, List<String> victimIds) {
  if (!state.pendingBombs.contains(bombId)) {
    throw InvalidActionException(InvalidActionReason.bombNotPending, playerId: bombId);
  }
  for (final id in victimIds) {
    if (!state.player(id).isAlive) {
      throw InvalidActionException(InvalidActionReason.targetDead, playerId: id);
    }
  }
  if (victimIds.toSet().length != victimIds.length) {
    throw const InvalidActionException(InvalidActionReason.invalidTarget);
  }
  if (victimIds.length != state.bombVictimsRequired) {
    throw const InvalidActionException(InvalidActionReason.wrongVictimCount);
  }

  final saved = state.settings.doctorCanSaveBombVictims
      ? (state.lastNight?.savedPlayerIds ?? const <String>{})
      : const <String>{};
  final events = <GameEvent>[];
  final deaths = <String, Set<DeathCause>>{};
  for (final id in inSeatingOrder(state, victimIds)) {
    if (saved.contains(id)) {
      events.add(PlayerSaved(id, const {DeathCause.bomb}));
    } else {
      deaths[id] = {DeathCause.bomb};
    }
  }

  var next = state.copyWith(
    pendingBombs: [...state.pendingBombs]..remove(bombId),
  );
  next = applyDeaths(next, deaths, events);
  next = settle(next, events);
  return Resolution(next, List.unmodifiable(events));
}
