import 'deaths.dart';
import 'exceptions.dart';
import 'game_event.dart';
import 'game_state.dart';

/// Settles [playerId]'s pending death choice with [victimIds]:
/// - Godfather voted out: one living player (not himself), or none.
/// - Bomb voted out on day 1: both neighbors (those still alive), or none.
/// The victims die at once, and their chains follow.
Resolution resolveChoice(GameState state, String playerId, List<String> victimIds) {
  final choice = state.pendingChoices.where((c) => c.playerId == playerId).firstOrNull;
  if (choice == null) throw invalid(InvalidActionReason.noChoicePending, playerId);

  bool alive(String id) => state.player(id).isAlive;
  final ids = victimIds.toSet();
  final ok = switch (choice.kind) {
    ChoiceKind.godfatherTakesOne =>
      ids.length == victimIds.length && ids.length <= 1 && ids.every((id) => id != playerId && alive(id)),
    ChoiceKind.bombTakesNeighbors => ids.isEmpty ||
        (ids.length == victimIds.length &&
            ids.containsAll(choice.options.where(alive)) &&
            choice.options.where(alive).toSet().containsAll(ids)),
  };
  if (!ok) throw invalid(InvalidActionReason.invalidChoice, playerId);

  final cause = switch (choice.kind) {
    ChoiceKind.godfatherTakesOne => DeathCause.godfather,
    ChoiceKind.bombTakesNeighbors => DeathCause.bomb,
  };
  final events = <GameEvent>[];
  var next = state.copyWith(pendingChoices: [...state.pendingChoices]..remove(choice));
  next = applyDeaths(
    next,
    {for (final id in ids) id: {cause}},
    events,
    atNight: choice.atNight,
    causedBy: playerId,
  );
  next = settle(next, events);
  return Resolution(next, List.unmodifiable(events));
}

/// [playerId] takes a Foul (an extra 15-second speech). Counted per player
/// for the whole game; silenced players have no speech to extend.
GameState takeFoul(GameState state, String playerId) {
  if (state.phase != GamePhase.day) throw invalid(InvalidActionReason.wrongPhase);
  if (!state.player(playerId).isAlive) throw invalid(InvalidActionReason.actorDead, playerId);
  if (state.isSilenced(playerId)) throw invalid(InvalidActionReason.playerSilenced, playerId);
  return state.copyWith(fouls: {...state.fouls, playerId: state.foulsOf(playerId) + 1});
}

/// The host removes [playerId] for repeatedly breaking the table rules
/// (GAME_RULES §3). TNT still explodes ("eliminated any way"); the Bomb,
/// Godfather and Detective chain need a night death or a vote.
Resolution removePlayer(GameState state, String playerId) {
  if (state.phase == GamePhase.gameOver) throw invalid(InvalidActionReason.wrongPhase);
  if (state.pendingChoices.isNotEmpty) throw invalid(InvalidActionReason.choicePending);
  if (!state.player(playerId).isAlive) throw invalid(InvalidActionReason.targetDead, playerId);
  final events = <GameEvent>[];
  var next = applyDeaths(state, {playerId: {DeathCause.removed}}, events, atNight: false);
  next = settle(next, events);
  return Resolution(next, List.unmodifiable(events));
}
