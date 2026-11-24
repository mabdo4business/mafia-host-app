// Internal helpers shared by the resolvers. Not exported.

import 'exceptions.dart';
import 'game_event.dart';
import 'game_state.dart';
import 'roles.dart';
import 'win_checker.dart';

/// Kills everyone in [initial] (in seat order), then runs the chain deaths
/// in a loop until no new deaths (GAME_RULES §5): Witch link (night only),
/// a Bomb's charges, TNT's neighbors, the Detective chain. A voted-out
/// Godfather, and a Bomb voted out on day 1, leave a [PendingChoice].
///
/// Events come out breadth-first: the initial deaths, then each death's
/// chain victims (in seat order), and so on. TNT and the day-1 Bomb take
/// the neighbors from the table as it was before these deaths.
///
/// [savedTonight]: players under an unblocked Doctor save, who survive
/// chain deaths when `doctorBlocksChainDeaths` is on.
GameState applyDeaths(
  GameState state,
  Map<String, Set<DeathCause>> initial,
  List<GameEvent> events, {
  required bool atNight,
  String? causedBy,
  Set<String> savedTonight = const {},
}) {
  if (initial.isEmpty) return state;
  final settings = state.settings;
  final seated = {for (final p in state.alivePlayers) p.id};
  final dying = <String>{};
  final queue = <({String id, Set<DeathCause> causes, String? causedBy})>[];
  final pending = [...state.pendingChoices];

  void kill(String id, Set<DeathCause> causes, String? by) {
    dying.add(id);
    queue.add((id: id, causes: causes, causedBy: by));
  }

  for (final id in inSeatOrder(state, initial.keys)) {
    kill(id, initial[id]!, causedBy);
  }

  for (var i = 0; i < queue.length; i++) {
    final death = queue[i];
    final dead = state.player(death.id);
    events.add(PlayerDied(
      dead.id,
      Set.of(death.causes),
      causedBy: death.causedBy,
      revealedRole: settings.revealRoleOnDeath ? dead.role : null,
    ));

    void take(Iterable<String> ids, DeathCause cause) {
      for (final id in inSeatOrder(state, ids)) {
        if (!seated.contains(id) || dying.contains(id)) continue;
        if (atNight && settings.doctorBlocksChainDeaths && savedTonight.contains(id)) {
          events.add(PlayerSaved(id, {cause}));
        } else {
          kill(id, {cause}, dead.id);
        }
      }
    }

    void choose(PendingChoice choice) {
      pending.add(choice);
      events.add(ChoiceRequired(choice));
    }

    final removed = death.causes.contains(DeathCause.removed);
    final votedOut = death.causes.contains(DeathCause.vote);

    if (state.witchLink case (final a, final b) when atNight) {
      if (dead.id == a) take([b], DeathCause.witchLink);
      if (dead.id == b) take([a], DeathCause.witchLink);
    }

    switch (dead.effectiveRole) {
      case Role.bomb when !removed:
        final charges = state.bombPlants[dead.id];
        final beforePlanting = state.nightNumber == 1 &&
            (votedOut || (atNight && !settings.bombNoEffectBeforePlant));
        if (charges != null) {
          events.add(BombExploded(dead.id));
          take(charges, DeathCause.bomb);
        } else if (beforePlanting) {
          choose(PendingChoice(
            dead.id,
            ChoiceKind.bombTakesNeighbors,
            options: state.neighborsOf(dead.id, seated: seated),
            atNight: atNight,
          ));
        }
      case Role.tnt:
        take(state.neighborsOf(dead.id, seated: seated), DeathCause.tnt);
      case Role.detective when !removed && (atNight || settings.detectiveChainOnVote):
        take(state.detectiveRecords[dead.id]?.chainVictims ?? const [], DeathCause.detectiveChain);
      case Role.godfather when votedOut:
        choose(PendingChoice(dead.id, ChoiceKind.godfatherTakesOne));
      default:
    }
  }

  return state.copyWith(
    players: [
      for (final p in state.players) dying.contains(p.id) ? p.copyWith(isAlive: false) : p,
    ],
    pendingChoices: pending,
  );
}

/// After deaths: promotes a Putana left alone on the Mafia Team, then runs
/// the win check once no choice is pending.
GameState settle(GameState state, List<GameEvent> events) {
  final mafiaTeam = [
    for (final p in state.alivePlayers)
      if (p.team == Team.mafia) p
  ];
  if (mafiaTeam case [final last]
      when last.effectiveRole == Role.putana && !state.promotedPutanas.contains(last.id)) {
    events.add(PutanaPromoted(last.id));
    state = state.copyWith(promotedPutanas: {...state.promotedPutanas, last.id});
  }

  if (state.pendingChoices.isNotEmpty || state.phase == GamePhase.gameOver) return state;
  final winner = checkWinner(state);
  if (winner == null) return state;
  events.add(GameOver(winner));
  return state.copyWith(phase: GamePhase.gameOver, winner: winner);
}

/// Restricts [ids] to seat order so output never depends on input order.
List<String> inSeatOrder(GameState state, Iterable<String> ids) {
  final wanted = ids.toSet();
  return [
    for (final p in state.players)
      if (wanted.contains(p.id)) p.id
  ];
}

InvalidActionException invalid(InvalidActionReason reason, [String? playerId]) =>
    InvalidActionException(reason, playerId: playerId);
