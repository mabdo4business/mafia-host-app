import 'package:mafia_engine/mafia_engine.dart';

/// Night wizard steps, in the wake order of GAME_RULES §5. Wake order is
/// only for the table; the engine resolves the collected actions in its own
/// order (Putana block → Lawyer → kills → Switchman → Doctor → …).
enum NightStepKind {
  /// Night 1: the Mafia Team (with Putana) open their eyes and recognize
  /// each other. No action.
  recognition,
  putana,
  lawyer,
  mafia,
  witch,
  joker,
  silencer,
  doctor,
  shapeshifter,
  detective,
  bomb,

  /// Night 3: the Chameleon chooses a role. From night 4: wakes as it.
  chameleon,

  /// Woken only when shot at: where does each bullet go?
  switchman,
}

/// The host's answer to a step: the picked players, or a picked role.
/// A step with no entry in the wizard's choices is unanswered; an entry of
/// `null` is "no action".
final class NightPick {
  const NightPick.players(this.playerIds) : role = null;
  const NightPick.role(Role this.role) : playerIds = const [];

  final List<String> playerIds;
  final Role? role;
}

/// One "wake X, who do they pick?" prompt.
final class NightStep {
  const NightStep({
    required this.id,
    required this.kind,
    required this.actorId,
    required this.ability,
    this.picks = 1,
    this.targetIds = const [],
    this.disabledTargetIds = const {},
    this.roleChoices = const [],
    this.memberIds = const [],
    this.bullet,
  });

  /// Stable across rebuilds of the step list, so answers survive going back
  /// and changing an earlier step.
  final String id;
  final NightStepKind kind;

  /// The player woken. For the Mafia: the one with the final say (the
  /// Godfather, or the first Mafia killer when he is gone).
  final String actorId;

  /// The ability used tonight (the Shapeshifter's role for the night, a
  /// Chameleon's chosen role).
  final Role ability;

  /// How many players to pick: 0 (recognition, role choice), 1 or 2.
  final int picks;

  /// Players the host can pick, in seat order.
  final List<String> targetIds;

  /// Shown but not pickable (the Doctor's third night in a row).
  final Set<String> disabledTargetIds;

  /// The Chameleon's choice on night 3.
  final List<Role> roleChoices;

  /// The Mafia step and recognition: everyone awake, in seat order.
  final List<String> memberIds;

  /// The Switchman step: the bullet being sent on.
  final DeathCause? bullet;

  bool get choosesRole => roleChoices.isNotEmpty;

  /// The actions [pick] makes. The Mafia's number is shown by the decider;
  /// if Putana blocked the decider, the other killers' agreed number counts.
  List<NightAction> actionsFor(NightPick pick, {Set<String> blocked = const {}}) {
    final p = pick.playerIds;
    return switch (kind) {
      NightStepKind.recognition => const [],
      NightStepKind.mafia => [
        MafiaKill(actorId, p.single),
        if (blocked.contains(actorId))
          for (final id in memberIds)
            if (id != actorId && !blocked.contains(id)) MafiaKill(id, p.single),
      ],
      NightStepKind.putana => [PutanaBlock(actorId, p.single)],
      NightStepKind.lawyer => [LawyerProtect(actorId, p.single)],
      NightStepKind.witch => [WitchLink(actorId, p[0], p[1])],
      NightStepKind.silencer => [SilencerSilence(actorId, p.single)],
      NightStepKind.bomb => [BombPlant(actorId, p[0], p[1])],
      NightStepKind.switchman => [SwitchmanRedirect(actorId, p.single)],
      NightStepKind.chameleon when pick.role != null => [ChameleonChoose(actorId, pick.role!)],
      NightStepKind.joker ||
      NightStepKind.doctor ||
      NightStepKind.detective ||
      NightStepKind.shapeshifter ||
      NightStepKind.chameleon => [
        switch (ability) {
          Role.doctor => DoctorSave(actorId, p.single),
          Role.detective => DetectiveCheck(actorId, p.single),
          _ => JokerKill(actorId, p.single),
        },
      ],
    };
  }
}

/// Tonight's steps before any Switchman is woken. Roles not in the game,
/// dead, or with nothing to do tonight are skipped; a role held by several
/// players gets one step each.
List<NightStep> buildNightSteps(GameState state) {
  final s = state.settings;
  final night = state.nightNumber;
  final alive = state.alivePlayers;
  List<String> ids(bool Function(Player) test) => [
    for (final p in alive)
      if (test(p)) p.id,
  ];
  Iterable<Player> holders(Role role) => alive.where((p) => p.role == role);

  final mafiaTeam = alive.where((p) => p.team == Team.mafia).toList();
  final killers = state.mafiaKillers;
  final decider =
      killers.where((p) => state.abilityOf(p.id) == Role.godfather).firstOrNull ??
      killers.firstOrNull;
  bool isMafiaSide(Player p) => p.team == Team.mafia || state.joinsMafiaKill(p.id);

  NightStep acting(String id, NightStepKind kind, Player p, Role ability) => NightStep(
    id: id,
    kind: kind,
    actorId: p.id,
    ability: ability,
    targetIds: ids((t) => ability == Role.doctor || t.id != p.id),
    disabledTargetIds: {
      if (ability == Role.doctor)
        if (state.doctorStreaks[p.id] case (:final targetId, :final nights) when nights >= 2)
          targetId,
    },
  );

  return [
    if (night == 1 && mafiaTeam.isNotEmpty)
      NightStep(
        id: 'recognition',
        kind: NightStepKind.recognition,
        actorId: mafiaTeam.first.id,
        ability: Role.mafia,
        picks: 0,
        memberIds: [for (final p in mafiaTeam) p.id],
      ),
    if (night >= 2)
      for (final p in holders(Role.putana))
        if (state.abilityOf(p.id) == Role.putana)
          NightStep(
            id: 'putana:${p.id}',
            kind: NightStepKind.putana,
            actorId: p.id,
            ability: Role.putana,
            targetIds: ids(
              (t) => t.id != p.id && (s.putanaCanBlockMafia || t.team == Team.civilians),
            ),
          ),
    for (final p in holders(Role.lawyer))
      NightStep(
        id: 'lawyer:${p.id}',
        kind: NightStepKind.lawyer,
        actorId: p.id,
        ability: Role.lawyer,
        targetIds: ids((t) => t.team == Team.mafia),
      ),
    if (decider != null)
      NightStep(
        id: 'mafia',
        kind: NightStepKind.mafia,
        actorId: decider.id,
        ability: Role.mafia,
        targetIds: ids((t) => !isMafiaSide(t)),
        memberIds: [for (final p in killers) p.id],
      ),
    if (night == 2)
      for (final p in holders(Role.witch))
        NightStep(
          id: 'witch:${p.id}',
          kind: NightStepKind.witch,
          actorId: p.id,
          ability: Role.witch,
          picks: 2,
          targetIds: ids(
            (t) => t.id != p.id && (!s.witchCiviliansOnly || t.team == Team.civilians),
          ),
        ),
    for (final p in holders(Role.joker))
      acting('joker:${p.id}', NightStepKind.joker, p, Role.joker),
    for (final p in holders(Role.silencer))
      NightStep(
        id: 'silencer:${p.id}',
        kind: NightStepKind.silencer,
        actorId: p.id,
        ability: Role.silencer,
        targetIds: ids((t) => t.id != p.id),
      ),
    for (final p in holders(Role.doctor))
      acting('doctor:${p.id}', NightStepKind.doctor, p, Role.doctor),
    for (final p in holders(Role.shapeshifter))
      acting('shapeshifter:${p.id}', NightStepKind.shapeshifter, p, state.abilityOf(p.id)),
    for (final p in holders(Role.detective))
      acting('detective:${p.id}', NightStepKind.detective, p, Role.detective),
    if (night == 2)
      for (final p in holders(Role.bomb))
        NightStep(
          id: 'bomb:${p.id}',
          kind: NightStepKind.bomb,
          actorId: p.id,
          ability: Role.bomb,
          picks: 2,
          targetIds: ids((t) => t.id != p.id),
        ),
    for (final p in holders(Role.chameleon))
      if (night == 3 && p.chameleonRole == null)
        NightStep(
          id: 'chameleon:${p.id}',
          kind: NightStepKind.chameleon,
          actorId: p.id,
          ability: Role.chameleon,
          picks: 0,
          roleChoices: chameleonChoices,
        )
      else if (p.chameleonRole case final r?
          when const {Role.detective, Role.doctor, Role.joker}.contains(r))
        acting('chameleon:${p.id}', NightStepKind.chameleon, p, r),
  ];
}

/// The Switchman steps for [actions] (everything picked before them): one
/// per bullet aimed at an unblocked Switchman (one in all, with
/// `switchmanRedirectsEach` off). They come last, once every shot is known.
List<NightStep> switchmanSteps(GameState state, List<NightAction> actions) {
  final blocked = {for (final a in actions.whereType<PutanaBlock>()) a.targetId};
  return [
    for (final p in state.alivePlayers)
      if (state.abilityOf(p.id) == Role.switchman && !blocked.contains(p.id))
        for (final (i, cause) in state.bulletsAt(p.id, actions).indexed)
          if (i == 0 || state.settings.switchmanRedirectsEach)
            NightStep(
              id: 'switchman:${p.id}:$i',
              kind: NightStepKind.switchman,
              actorId: p.id,
              ability: Role.switchman,
              targetIds: [
                for (final t in state.alivePlayers)
                  if (t.id != p.id) t.id,
              ],
              bullet: cause,
            ),
  ];
}

/// What a Detective (or anyone checking tonight) should be shown right now,
/// given the actions picked before. Null means they are blocked: give no
/// answer.
DetectiveResult? previewDetectiveResult(
  GameState state,
  List<NightAction> earlierActions,
  DetectiveCheck check,
) {
  final events = resolveNight(state, [...earlierActions, check]).events;
  for (final e in events) {
    if (e is DetectiveResultRevealed && e.detectiveId == check.actorId) return e.result;
  }
  return null;
}
