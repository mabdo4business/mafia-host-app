import 'bullets.dart';
import 'deaths.dart';
import 'exceptions.dart';
import 'game_event.dart';
import 'game_state.dart';
import 'night_action.dart';
import 'player.dart';
import 'roles.dart';

/// Resolves a full night (GAME_RULES §5). All [actions] are validated
/// first, then applied in the fixed order, whatever order they came in:
///
/// 1. Putana's block: the blocked player's action has no effect.
/// 2. Lawyer, Witch link, Silencer, Bomb planting, Chameleon's choice.
/// 3. Kill attempts: the Mafia's, then each Joker kill by seat.
/// 4. Switchman: an unblocked Switchman sends each bullet on, or dodges it.
/// 5. Doctor saves.  6. Detective results (Lawyer applied).
/// 7. Deaths → chain deaths in a loop.  8. Putana promotion, win check.
Resolution resolveNight(GameState state, List<NightAction> actions) {
  if (state.phase != GamePhase.night) throw invalid(InvalidActionReason.wrongPhase);
  if (state.pendingChoices.isNotEmpty) throw invalid(InvalidActionReason.choicePending);
  _validate(state, actions);

  final settings = state.settings;
  final events = <GameEvent>[];
  final night = state.nightNumber;
  List<T> bySeat<T extends NightAction>(Iterable<NightAction> from) => from.whereType<T>().toList()
    ..sort((a, b) => state.seatOf(a.actorId).compareTo(state.seatOf(b.actorId)));
  Set<String> targetsOf<T extends TargetedAction>(Iterable<NightAction> from) =>
      inSeatOrder(state, from.whereType<T>().map((a) => a.targetId)).toSet();

  // 1. Putana's block. The Chameleon's choice is who they are, not an
  // ability, so a block does not stop it.
  final blocked = targetsOf<PutanaBlock>(actions);
  events.addAll(blocked.map(PlayerBlocked.new));
  final active = [
    for (final a in actions)
      if (!blocked.contains(a.actorId) || a is ChameleonChoose) a
  ];

  // 2. Protections, links, silences, charges, the Chameleon's choice.
  final protected = targetsOf<LawyerProtect>(active);
  events.addAll(protected.map(LawyerProtected.new));

  var witchLink = state.witchLink;
  for (final link in bySeat<WitchLink>(active)) {
    witchLink = (link.firstId, link.secondId);
    events.add(SoulsLinked(link.firstId, link.secondId));
  }

  final silencedThrough = {
    for (final MapEntry(:key, :value) in state.silencedThrough.entries)
      if (value >= night) key: value,
  };
  for (final id in targetsOf<SilencerSilence>(active)) {
    silencedThrough[id] = night + (settings.silenceLastsNextDay ? 0 : 1);
    events.add(PlayerSilenced(id));
  }

  final bombPlants = {...state.bombPlants};
  for (final plant in bySeat<BombPlant>(active)) {
    bombPlants[plant.actorId] = [plant.firstId, plant.secondId];
    events.add(BombPlanted(plant.actorId, plant.firstId, plant.secondId));
  }

  var players = state.players;
  for (final choice in bySeat<ChameleonChoose>(active)) {
    final joins = choice.role == Role.mafia && settings.chameleonMafiaJoinsMafiaTeam;
    players = [
      for (final p in players)
        p.id == choice.actorId ? p.copyWith(chameleonRole: choice.role, joinedMafia: joins) : p,
    ];
    events.add(ChameleonChose(choice.actorId, choice.role));
  }

  // 3. Kill attempts.
  final fired = firedBullets(state, active);
  if (fired.mafiaCancelled) events.add(const MafiaKillCancelled());

  // 4. Switchman.
  bool immortal(String id) =>
      state.abilityOf(id) == Role.switchman && !blocked.contains(id);
  final redirects = <String, List<String>>{
    for (final r in bySeat<SwitchmanRedirect>(active)) r.actorId: [],
  };
  for (final r in active.whereType<SwitchmanRedirect>()) {
    redirects[r.actorId]!.add(r.targetId);
  }
  final shotAt = <String, int>{};
  final bullets = <Bullet>[];
  for (final b in fired.bullets) {
    final sw = b.targetId;
    if (!immortal(sw)) {
      bullets.add(b);
      continue;
    }
    final mine = redirects[sw] ?? const [];
    final n = shotAt[sw] = (shotAt[sw] ?? 0) + 1;
    final to = settings.switchmanRedirectsEach ? mine.elementAtOrNull(n - 1) : mine.firstOrNull;
    if (to == null) {
      events.add(BulletDodged(sw));
    } else if (immortal(to)) {
      events.add(BulletRedirected(sw, to));
      events.add(BulletDodged(to));
    } else {
      events.add(BulletRedirected(sw, to));
      bullets.add(Bullet(to, b.cause, redirected: true));
    }
  }
  for (final MapEntry(key: sw, value: mine) in redirects.entries) {
    final shots = shotAt[sw] ?? 0;
    if (shots == 0) throw invalid(InvalidActionReason.notTargeted, sw);
    final allowed = settings.switchmanRedirectsEach ? shots : 1;
    if (mine.length > allowed) throw invalid(InvalidActionReason.duplicateAction, sw);
  }

  // 5. Doctor saves.
  final saved = targetsOf<DoctorSave>(active);
  final hits = <String, Set<DeathCause>>{};
  final stopped = <String, Set<DeathCause>>{};
  for (final b in bullets) {
    final saves = saved.contains(b.targetId) &&
        (!b.redirected || settings.doctorSavesRedirectedBullet);
    (saves ? stopped : hits).putIfAbsent(b.targetId, () => {}).add(b.cause);
  }
  final deaths = <String, Set<DeathCause>>{};
  for (final id in inSeatOrder(state, {...hits.keys, ...stopped.keys})) {
    if (hits[id] case final causes?) {
      deaths[id] = causes;
    } else {
      events.add(PlayerSaved(id, stopped[id]!));
    }
  }

  // 6. Detective results.
  final records = {...state.detectiveRecords};
  for (final check in bySeat<DetectiveCheck>(actions)) {
    final record = records[check.actorId] ?? const DetectiveRecord();
    if (blocked.contains(check.actorId)) {
      if (settings.blockedChecksCount) {
        records[check.actorId] =
            DetectiveRecord(checks: record.checks + 1, mafiaFound: record.mafiaFound);
      }
      continue;
    }
    final target = players.firstWhere((p) => p.id == check.targetId);
    final result = _looksMafia(state, target, protected) ? DetectiveResult.mafia : DetectiveResult.civilian;
    events.add(DetectiveResultRevealed(check.actorId, check.targetId, result));
    final next = DetectiveRecord(
      checks: record.checks + 1,
      mafiaFound: [
        ...record.mafiaFound,
        if (result == DetectiveResult.mafia && !record.mafiaFound.contains(target.id)) target.id,
      ],
    );
    records[check.actorId] = next;
    if (next.armed && !record.armed) {
      events.add(DetectiveChainArmed(check.actorId, next.chainVictims));
    }
  }

  // 7. Deaths and chains. Every Doctor pick counts for the streak, even a
  // blocked one.
  var next = state.copyWith(
    players: players,
    phase: GamePhase.day,
    doctorStreaks: {
      for (final s in actions.whereType<DoctorSave>())
        s.actorId: (
          targetId: s.targetId,
          nights: state.doctorStreaks[s.actorId]?.targetId == s.targetId
              ? state.doctorStreaks[s.actorId]!.nights + 1
              : 1,
        ),
    },
    detectiveRecords: records,
    witchLink: witchLink,
    bombPlants: bombPlants,
    silencedThrough: silencedThrough,
    revoteCandidates: null,
  );
  next = applyDeaths(next, deaths, events, atNight: true, savedTonight: saved);

  // 8. Putana promotion, win check.
  next = settle(next, events);
  return Resolution(next, List.unmodifiable(events));
}

bool _looksMafia(GameState state, Player target, Set<String> lawyerProtected) =>
    target.team == Team.mafia &&
    !lawyerProtected.contains(target.id) &&
    !(target.effectiveRole == Role.godfather && state.settings.godfatherAppearsCivilian);

void _validate(GameState state, List<NightAction> actions) {
  final settings = state.settings;
  final night = state.nightNumber;
  final seen = <(Type, String)>{};
  for (final a in actions) {
    final actor = state.player(a.actorId);
    final targets = a.targetIds.map(state.player).toList();
    InvalidActionException fail(InvalidActionReason r, [String? id]) => invalid(r, id ?? actor.id);

    if (!actor.isAlive) throw fail(InvalidActionReason.actorDead);
    for (final t in targets) {
      if (!t.isAlive) throw fail(InvalidActionReason.targetDead, t.id);
    }
    if (a is! SwitchmanRedirect && !seen.add((a.runtimeType, actor.id))) {
      throw fail(InvalidActionReason.duplicateAction);
    }

    final ability = state.abilityOf(actor.id);
    void requireAbility(Role role) {
      if (ability != role) throw fail(InvalidActionReason.actorLacksRole);
    }

    void requireNight(bool ok) {
      if (!ok) throw fail(InvalidActionReason.notTonight);
    }

    void requireTarget(bool ok, [String? id]) {
      if (!ok) throw fail(InvalidActionReason.invalidTarget, id ?? a.targetIds.firstOrNull);
    }

    final notSelf = !a.targetIds.contains(actor.id);
    switch (a) {
      case MafiaKill():
        if (!state.joinsMafiaKill(actor.id)) throw fail(InvalidActionReason.actorLacksRole);
        requireTarget(notSelf);
      case JokerKill():
        requireAbility(Role.joker);
        requireTarget(notSelf);
      case DoctorSave(:final targetId):
        requireAbility(Role.doctor);
        final streak = state.doctorStreaks[actor.id];
        if (streak != null && streak.targetId == targetId && streak.nights >= 2) {
          throw fail(InvalidActionReason.doctorRepeatTarget, targetId);
        }
      case DetectiveCheck():
        requireAbility(Role.detective);
        requireTarget(notSelf);
      case PutanaBlock(:final targetId):
        requireAbility(Role.putana);
        requireNight(night >= 2);
        requireTarget(notSelf);
        requireTarget(settings.putanaCanBlockMafia || state.player(targetId).team == Team.civilians);
      case LawyerProtect(:final targetId):
        requireAbility(Role.lawyer);
        requireTarget(state.player(targetId).team == Team.mafia);
      case SilencerSilence():
        requireAbility(Role.silencer);
        requireTarget(notSelf);
      case SwitchmanRedirect():
        requireAbility(Role.switchman);
        requireTarget(notSelf);
      case WitchLink(:final firstId, :final secondId):
        requireAbility(Role.witch);
        requireNight(night == 2);
        requireTarget(notSelf && firstId != secondId);
        if (settings.witchCiviliansOnly) {
          for (final t in targets) {
            requireTarget(t.team == Team.civilians, t.id);
          }
        }
      case BombPlant(:final firstId, :final secondId):
        requireAbility(Role.bomb);
        requireNight(night == 2);
        requireTarget(notSelf && firstId != secondId);
      case ChameleonChoose(:final role):
        if (actor.role != Role.chameleon) throw fail(InvalidActionReason.actorLacksRole);
        requireNight(night == 3 && actor.chameleonRole == null);
        if (!chameleonChoices.contains(role)) throw fail(InvalidActionReason.roleNotAllowed);
    }
  }
}
