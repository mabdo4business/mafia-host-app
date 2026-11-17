import 'deaths.dart';
import 'exceptions.dart';
import 'game_event.dart';
import 'game_state.dart';
import 'night_action.dart';
import 'player.dart';
import 'roles.dart';

/// Resolves a full night. All [actions] are validated first, then applied in
/// the fixed rule order, independent of the order they were submitted in:
///
/// 1. Potana block  2. Lawyer protection  3. Mafia kill  4. Joker kill
/// 5. Doctor save  6. Detective check  7. Deaths → Bomb trigger  8. Win check
Resolution resolveNight(GameState state, List<NightAction> actions) {
  if (state.phase != GamePhase.night) {
    throw const InvalidActionException(InvalidActionReason.wrongPhase);
  }
  if (state.pendingBombs.isNotEmpty) {
    throw const InvalidActionException(InvalidActionReason.bombDetonationPending);
  }
  _validate(state, actions);

  final events = <GameEvent>[];
  Iterable<String> targetsOf<T extends NightAction>(Iterable<NightAction> a) =>
      a.whereType<T>().map((x) => x.targetId);

  // 1. Potana block.
  final blocked = inSeatingOrder(state, targetsOf<PotanaBlock>(actions)).toSet();
  events.addAll(blocked.map(PlayerBlocked.new));
  final active = [
    for (final a in actions)
      if (!blocked.contains(a.actorId)) a
  ];

  // 2. Lawyer protection.
  final protected = inSeatingOrder(state, targetsOf<LawyerProtect>(actions)).toSet();
  events.addAll(protected.map(LawyerProtected.new));

  // 3–4. Attacks.
  final attacks = <String, Set<DeathCause>>{};
  final mafiaTarget = _mafiaKillTarget(state, actions);
  if (mafiaTarget != null) {
    attacks.putIfAbsent(mafiaTarget, () => {}).add(DeathCause.mafia);
  }
  for (final id in targetsOf<JokerKill>(active)) {
    attacks.putIfAbsent(id, () => {}).add(DeathCause.joker);
  }

  // 5. Doctor save.
  final saved = targetsOf<DoctorSave>(active).toSet();
  final preventable = {
    DeathCause.mafia,
    if (state.settings.doctorSaveBlocksJokerKill) DeathCause.joker,
  };
  final deaths = <String, Set<DeathCause>>{};
  for (final id in inSeatingOrder(state, attacks.keys)) {
    final causes = attacks[id]!;
    final remaining = saved.contains(id) ? causes.difference(preventable) : causes;
    if (remaining.isEmpty) {
      events.add(PlayerSaved(id, causes));
    } else {
      deaths[id] = remaining;
    }
  }

  // 6. Detective check.
  final checks = active.whereType<DetectiveCheck>().toList()
    ..sort((a, b) => _seat(state, a.actorId).compareTo(_seat(state, b.actorId)));
  for (final c in checks) {
    events.add(DetectiveResultRevealed(
      c.actorId,
      c.targetId,
      _readAs(state.player(c.targetId), protected),
    ));
  }

  // 7. Deaths and Bomb trigger.
  var next = state.copyWith(
    phase: GamePhase.day,
    doctorLastTargets: {
      // Every pick counts for the two-nights rule, even a blocked one.
      for (final s in actions.whereType<DoctorSave>()) s.actorId: s.targetId,
    },
    lastNight: NightRecord(blockedPlayerIds: blocked, savedPlayerIds: saved),
  );
  next = applyDeaths(next, deaths, events);

  // 8. Win check.
  next = settle(next, events);
  return Resolution(next, List.unmodifiable(events));
}

DetectiveResult _readAs(Player target, Set<String> lawyerProtected) {
  final looksMafia = target.team == Team.mafia &&
      target.effectiveRole != Role.godfather &&
      !lawyerProtected.contains(target.id);
  return looksMafia ? DetectiveResult.mafia : DetectiveResult.civilian;
}

/// The Godfather's choice wins. Without one, the remaining Mafia must agree.
String? _mafiaKillTarget(GameState state, List<NightAction> actions) {
  final kills = actions.whereType<MafiaKill>().toList();
  if (kills.isEmpty) return null;
  final byGodfather =
      kills.where((k) => state.player(k.actorId).effectiveRole == Role.godfather).toList();
  final deciding = byGodfather.isNotEmpty ? byGodfather : kills;
  final targets = deciding.map((k) => k.targetId).toSet();
  if (targets.length > 1) {
    throw const InvalidActionException(InvalidActionReason.conflictingMafiaKill);
  }
  return targets.single;
}

int _seat(GameState state, String id) => state.players.indexWhere((p) => p.id == id);

void _validate(GameState state, List<NightAction> actions) {
  final seen = <(Type, String)>{};
  for (final a in actions) {
    final actor = state.player(a.actorId);
    final target = state.player(a.targetId);
    InvalidActionException fail(InvalidActionReason r, [String? id]) =>
        InvalidActionException(r, playerId: id ?? actor.id);

    if (!actor.isAlive) throw fail(InvalidActionReason.actorDead);
    if (!target.isAlive) throw fail(InvalidActionReason.targetDead, target.id);
    if (!seen.add((a.runtimeType, actor.id))) {
      throw fail(InvalidActionReason.duplicateAction);
    }

    void requireRole(Role role) {
      if (actor.effectiveRole != role) throw fail(InvalidActionReason.actorLacksRole);
    }

    final self = actor.id == target.id;
    switch (a) {
      case MafiaKill():
        if (actor.team != Team.mafia) throw fail(InvalidActionReason.actorLacksRole);
      case JokerKill():
        requireRole(Role.joker);
        if (self) throw fail(InvalidActionReason.invalidTarget, target.id);
      case DoctorSave():
        requireRole(Role.doctor);
        if (state.doctorLastTargets[actor.id] == target.id) {
          throw fail(InvalidActionReason.doctorRepeatTarget, target.id);
        }
      case DetectiveCheck():
        requireRole(Role.detective);
        if (self) throw fail(InvalidActionReason.invalidTarget, target.id);
      case PotanaBlock():
        requireRole(Role.potana);
        if (target.team != Team.civilians) {
          throw fail(InvalidActionReason.invalidTarget, target.id);
        }
      case LawyerProtect():
        requireRole(Role.lawyer);
        if (target.team != Team.mafia) {
          throw fail(InvalidActionReason.invalidTarget, target.id);
        }
    }
  }
}
