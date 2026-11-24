import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/describe.dart';
import '../../common/l10n.dart';
import '../../common/sounds.dart';
import '../../game/game_input.dart';
import '../../game/game_menu.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'detective_result_screen.dart';
import 'night_steps.dart';

/// Step-by-step night: intro → one step per role (wake order, GAME_RULES
/// §5) → the Switchman if shot at → review → resolve. One screen; the
/// prompt, selection color and the CTA verb follow the role being woken.
class NightWizard extends ConsumerStatefulWidget {
  const NightWizard({
    super.key,
    required this.session,
    this.initialIndex = -1,
    this.initialChoices = const {},
    this.initialPartial = const {},
  });

  final GameSession session;

  /// -1 = intro (previews may start on a step, with answers in).
  final int initialIndex;
  final Map<String, NightPick?> initialChoices;
  final Map<String, List<String>> initialPartial;

  @override
  ConsumerState<NightWizard> createState() => _NightWizardState();
}

class _NightWizardState extends ConsumerState<NightWizard> {
  late final List<NightStep> _base = buildNightSteps(_state);

  /// Step id → the host's answer; `null` = no action. Missing = unanswered.
  late final Map<String, NightPick?> _choices = {...widget.initialChoices};

  /// Two-player steps: the players tapped so far.
  late final Map<String, List<String>> _partial = {
    for (final MapEntry(:key, :value) in widget.initialPartial.entries) key: [...value],
  };

  /// -1 = intro, steps.length = review.
  late int _index = widget.initialIndex.clamp(-1, _steps.length);

  /// Mafia step: player id → how many Mafia members proposed them (shown as
  /// dots; the decider's pick is what counts).
  final Map<String, int> _proposals = {};
  bool _resolving = false;

  GameState get _state => widget.session.state;

  /// The steps as answered so far: the Switchman is woken for each bullet
  /// the earlier picks aim at them.
  List<NightStep> get _steps => [..._base, ...switchmanSteps(_state, _actionsOf(_base))];

  List<NightAction> _actionsOf(List<NightStep> steps) {
    final actions = <NightAction>[];
    for (final step in steps) {
      final pick = _choices[step.id];
      if (pick == null) continue;
      final blocked = {for (final a in actions.whereType<PutanaBlock>()) a.targetId};
      actions.addAll(step.actionsFor(pick, blocked: blocked));
    }
    return actions;
  }

  List<NightAction> _actionsBefore(List<NightStep> steps, int index) =>
      _actionsOf(steps.take(index).toList());

  Future<void> _resolve(List<NightStep> steps) async {
    setState(() => _resolving = true);
    // Before applying: the wizard is replaced (and its ref unusable) once
    // the night resolves.
    playGameSound(ref, GameSound.morning);
    await ref.read(activeGameProvider.notifier).apply(NightInput(_actionsOf(steps)));
  }

  Future<void> _next(List<NightStep> steps, NightStep step) async {
    final pick = _choices[step.id];
    // A check's answer is shown full screen before moving on.
    if (step.ability == Role.detective && pick != null && pick.playerIds.isNotEmpty) {
      final target = pick.playerIds.single;
      final result = previewDetectiveResult(
        _state,
        _actionsBefore(steps, _index),
        DetectiveCheck(step.actorId, target),
      );
      final go = await Navigator.push<bool>(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (_, _, _) => Theme(
            data: Theme.of(context),
            child: DetectiveResultScreen(targetName: _state.player(target).name, result: result),
          ),
          transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: Motion.base,
        ),
      );
      if (go != true) return;
    }
    if (mounted) setState(() => _index++);
  }

  void _tap(NightStep step, String id) => setState(() {
    if (step.picks == 1) {
      _choices[step.id] = NightPick.players([id]);
      return;
    }
    final picked = _partial[step.id] ??= [];
    if (!picked.remove(id) && picked.length < step.picks) picked.add(id);
    if (picked.length == step.picks) {
      _choices[step.id] = NightPick.players(_inSeatOrder(picked));
    } else {
      _choices.remove(step.id);
    }
  });

  List<String> _inSeatOrder(List<String> ids) => [
    for (final p in _state.players)
      if (ids.contains(p.id)) p.id,
  ];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final steps = _steps;
    final header = PhaseHeader(
      phase: Phase.night,
      title: l.stageNight(widget.session.round),
      actionLabel: l.logTitle,
      onAction: () => openGameLog(context),
      trailing: Padding(
        padding: const EdgeInsetsDirectional.only(start: Space.sm),
        child: GameMenuButton(session: widget.session),
      ),
    );
    if (_index < 0) return _intro(context, header);
    if (_index >= steps.length) return _review(context, header, steps);
    return _step(context, header, steps, steps[_index]);
  }

  Widget _intro(BuildContext context, Widget header) {
    final l = context.l10n;
    final c = context.mafia;
    return PhaseScaffold(
      transparent: true,
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, 0),
        child: Column(
          children: [
            header,
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MafiaIcon(MafiaGlyphs.moon, size: 72, color: celestialColor(c)),
                    const SizedBox(height: Space.xl),
                    Text(
                      l.nightIntro,
                      textAlign: TextAlign.center,
                      style: context.type.headlineLarge,
                    ),
                    const SizedBox(height: Space.md),
                    Text(
                      l.nightIntroHint,
                      textAlign: TextAlign.center,
                      style: context.type.bodyMedium!.copyWith(color: c.textMuted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PrimaryActionButton(
        key: const Key('nightBegin'),
        label: l.nightBegin,
        onPressed: () {
          playGameSound(ref, GameSound.night);
          setState(() => _index = 0);
        },
      ),
    );
  }

  Widget _step(BuildContext context, Widget header, List<NightStep> steps, NightStep step) {
    final l = context.l10n;
    final c = context.mafia;
    final actor = _state.player(step.actorId);
    final pick = _choices[step.id];
    final answered = _choices.containsKey(step.id) || step.kind == NightStepKind.recognition;
    final before = _actionsBefore(steps, _index);
    final blocked = {
      for (final a in before.whereType<PutanaBlock>()) a.targetId,
    }.contains(step.actorId);
    final mafiaStep = step.kind == NightStepKind.mafia;
    final mafiaSide = mafiaStep || step.kind == NightStepKind.recognition;
    final accent = mafiaSide ? c.mafia : c.civilian;
    final godfatherDecides = mafiaStep && _state.abilityOf(actor.id) == Role.godfather;
    final mustAgree = mafiaStep && !godfatherDecides && step.memberIds.length > 1;
    final picked = step.picks == 2 ? (_partial[step.id] ?? const []) : pick?.playerIds ?? const [];
    final role = stepRole(step);

    final List<Widget> body;
    if (step.kind == NightStepKind.recognition) {
      body = [
        PlayerTargetGrid(
          children: [
            for (final id in step.memberIds)
              PlayerTile(
                key: Key('member_$id'),
                name: _state.player(id).name,
                accent: c.mafia,
                selected: true,
                note: l.playerRole(_state.player(id)),
              ),
          ],
        ),
      ];
    } else if (step.choosesRole) {
      body = [_roleChoices(context, step, pick?.role)];
    } else {
      final targets = step.targetIds.toSet();
      // Seat order. The living players this role can't pick are left out
      // rather than greyed: greying them would show the table who is Mafia.
      body = [
        PlayerTargetGrid(
          children: [
            for (final p in _state.players)
              if (!p.isAlive)
                PlayerTile(
                  key: Key('target_${p.id}'),
                  name: p.name,
                  enabled: false,
                  struck: true,
                  note: l.statusEliminated,
                )
              else if (targets.contains(p.id))
                PlayerTile(
                  key: Key('target_${p.id}'),
                  name: p.name,
                  accent: accent,
                  selected: picked.contains(p.id),
                  enabled: !step.disabledTargetIds.contains(p.id),
                  note: step.disabledTargetIds.contains(p.id) ? l.nightDoctorTwoNights : null,
                  dots: mafiaStep ? _proposals[p.id] ?? 0 : 0,
                  onTap: () => _tap(step, p.id),
                  onLongPress: mafiaStep
                      ? () => setState(
                          () => _proposals[p.id] =
                              ((_proposals[p.id] ?? 0) + 1) % (step.memberIds.length + 1),
                        )
                      : null,
                ),
          ],
        ),
        if (mafiaStep && step.memberIds.length > 1) ...[
          const SizedBox(height: Space.md),
          Text(
            mustAgree ? l.nightMafiaMustAgree : l.nightMafiaProposalHint,
            style: context.type.bodySmall!.copyWith(fontSize: TextSizes.small),
          ),
        ],
        const SizedBox(height: Space.md),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _NoActionChip(
            label: mustAgree ? l.nightMafiaNoMatch : l.nightNoAction,
            selected: _choices.containsKey(step.id) && pick == null,
            onTap: () => setState(() {
              _choices[step.id] = null;
              _partial.remove(step.id);
            }),
          ),
        ),
      ];
    }

    final String cta;
    if (step.kind == NightStepKind.recognition) {
      cta = l.nightRecognized;
    } else if (pick == null && answered) {
      cta = l.nightContinueNoAction;
    } else if (pick == null) {
      cta = _pickHint(l, step);
    } else if (pick.role case final r?) {
      cta = l.chameleonBecome(l.role(r));
    } else if (godfatherDecides) {
      cta = l.nightGodfatherConfirms(_state.player(pick.playerIds.single).name);
    } else {
      cta = _verb(l, step, [for (final id in pick.playerIds) _state.player(id).name]);
    }

    return PhaseScaffold(
      transparent: true,
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.lg),
        children: [
          header,
          const SizedBox(height: 18),
          StepRail(steps: [for (final s in steps) _railLabel(l, s)], current: _index),
          const SizedBox(height: 18),
          PromptCard(
            glyph: roleGlyph(role),
            title: _title(l, step),
            line: _line(l, step, steps),
            accent: accent,
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(switch (step.kind) {
                  NightStepKind.mafia => l.nightMafiaDecider(actor.name),
                  NightStepKind.recognition => l.nightRecognitionHint,
                  _ => l.nightActor(actor.name),
                }, style: context.type.bodySmall),
                if (blocked && step.kind != NightStepKind.recognition)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: Space.xs),
                    child: Text(
                      mafiaStep && step.memberIds.length > 1
                          ? l.nightBlockedDecider(actor.name)
                          : l.nightBlockedWarning,
                      key: const Key('blockedWarning'),
                      style: context.type.bodySmall!.copyWith(color: c.mafiaSoft),
                    ),
                  ),
              ],
            ),
          ),
          if (mafiaStep) ...[
            const SizedBox(height: Space.lg),
            TimedRow(
              key: const Key('mafiaTimer'),
              title: l.nightMafiaTalk,
              hint: l.nightMafiaTalkHint,
              timer: TalkTimer(seconds: _state.settings.mafiaDiscussionSeconds),
            ),
          ],
          const SizedBox(height: 18),
          ...body,
        ],
      ),
      bottom: Row(
        children: [
          IconCircleButton.large(
            glyph: MafiaGlyphs.back,
            semanticLabel: l.nightPreviousStep,
            onPressed: () => setState(() => _index--),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PrimaryActionButton(
              key: const Key('nightNext'),
              label: cta,
              tone: mafiaSide ? ActionTone.danger : ActionTone.phase,
              onPressed: answered ? () => _next(steps, step) : null,
            ),
          ),
        ],
      ),
    );
  }

  /// The Chameleon's five roles, with the chosen one's card below.
  Widget _roleChoices(BuildContext context, NightStep step, Role? chosen) {
    final l = context.l10n;
    final c = context.mafia;
    final chips = [
      for (final r in step.roleChoices)
        RoleChip(
          key: Key('chameleonPick_${r.name}'),
          glyph: roleGlyph(r),
          name: l.role(r),
          team: r.team,
          count: 1,
          showCount: false,
          selected: r == chosen,
          onTap: () => setState(() => _choices[step.id] = NightPick.role(r)),
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < chips.length; i += 2) ...[
          Row(
            children: [
              Expanded(child: chips[i]),
              const SizedBox(width: 10),
              Expanded(child: i + 1 < chips.length ? chips[i + 1] : const SizedBox()),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (chosen != null)
          Text(
            l.ability(chosen),
            key: const Key('chameleonAbility'),
            style: context.type.bodyMedium!.copyWith(color: c.textMuted),
          ),
      ],
    );
  }

  Widget _review(BuildContext context, Widget header, List<NightStep> steps) {
    final l = context.l10n;
    final c = context.mafia;
    final describe = Describer(l, _state);
    String line(NightStep step) {
      if (step.kind == NightStepKind.recognition) return l.reviewRecognition;
      final pick = _choices[step.id];
      if (pick == null) return l.reviewNoAction(describe.actor(step.actorId));
      return step.actionsFor(pick).map(describe.action).first;
    }

    return PhaseScaffold(
      transparent: true,
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.lg),
        children: [
          header,
          const SizedBox(height: Space.xl),
          Text(l.nightReviewTitle, style: context.type.headlineMedium),
          const SizedBox(height: Space.sm),
          Text(l.nightReviewHint, style: context.type.bodyMedium!.copyWith(color: c.textMuted)),
          const SizedBox(height: Space.lg),
          if (steps.isEmpty) Text(l.logNoActions, style: context.type.bodyMedium),
          for (final (i, step) in steps.indexed) ...[
            GlassCard(
              radius: Radii.tile,
              padding: const EdgeInsetsDirectional.all(14),
              onTap: () => setState(() => _index = i),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.tint(_isMafiaSide(step) ? c.mafia : c.civilian, 0.16),
                      borderRadius: BorderRadius.circular(Radii.iconBox),
                    ),
                    child: MafiaIcon(
                      roleGlyph(stepRole(step)),
                      color: _isMafiaSide(step) ? c.mafiaSoft : c.civilianSoft,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Text(line(step), style: context.type.bodyMedium)),
                  MafiaIcon(MafiaGlyphs.forward, size: 18, color: c.textMuted),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
          ],
        ],
      ),
      bottom: Row(
        children: [
          IconCircleButton.large(
            glyph: MafiaGlyphs.back,
            semanticLabel: l.nightPreviousStep,
            onPressed: () => setState(() => _index = steps.isEmpty ? -1 : _index - 1),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PrimaryActionButton(
              key: const Key('resolveNight'),
              label: l.nightResolve,
              trailing: MafiaGlyphs.sun,
              onPressed: _resolving ? null : () => _resolve(steps),
            ),
          ),
        ],
      ),
    );
  }
}

bool _isMafiaSide(NightStep s) =>
    s.kind == NightStepKind.mafia || s.kind == NightStepKind.recognition;

/// The role card a step wakes.
Role stepRole(NightStep s) => switch (s.kind) {
  NightStepKind.recognition || NightStepKind.mafia => Role.mafia,
  NightStepKind.putana => Role.putana,
  NightStepKind.lawyer => Role.lawyer,
  NightStepKind.witch => Role.witch,
  NightStepKind.joker => Role.joker,
  NightStepKind.silencer => Role.silencer,
  NightStepKind.doctor => Role.doctor,
  NightStepKind.shapeshifter => Role.shapeshifter,
  NightStepKind.detective => Role.detective,
  NightStepKind.bomb => Role.bomb,
  NightStepKind.chameleon => Role.chameleon,
  NightStepKind.switchman => Role.switchman,
};

String _railLabel(AppLocalizations l, NightStep s) =>
    s.kind == NightStepKind.recognition ? l.teamLabelMafia : l.role(stepRole(s));

String _title(AppLocalizations l, NightStep s) => switch (s.kind) {
  NightStepKind.recognition => l.nightWakeTitleRecognition,
  NightStepKind.putana => l.nightWakeTitlePutana,
  NightStepKind.lawyer => l.nightWakeTitleLawyer,
  NightStepKind.mafia => l.nightWakeTitleMafia,
  NightStepKind.witch => l.nightWakeTitleWitch,
  NightStepKind.joker => l.nightWakeTitleJoker,
  NightStepKind.silencer => l.nightWakeTitleSilencer,
  NightStepKind.doctor => l.nightWakeTitleDoctor,
  NightStepKind.shapeshifter => l.nightWakeTitleShapeshifter,
  NightStepKind.detective => l.nightWakeTitleDetective,
  NightStepKind.bomb => l.nightWakeTitleBomb,
  NightStepKind.chameleon => l.nightWakeTitleChameleon,
  NightStepKind.switchman => l.nightWakeTitleSwitchman,
};

String _line(AppLocalizations l, NightStep s, List<NightStep> steps) => switch (s.kind) {
  NightStepKind.recognition => l.nightLineRecognition,
  NightStepKind.putana => l.nightLinePutana,
  NightStepKind.lawyer => l.nightLineLawyer,
  NightStepKind.mafia => l.nightLineMafia,
  NightStepKind.witch => l.nightLineWitch,
  NightStepKind.joker => l.nightLineJoker,
  NightStepKind.silencer => l.nightLineSilencer,
  NightStepKind.doctor => l.nightLineDoctor,
  NightStepKind.shapeshifter => l.nightLineShapeshifter(l.role(s.ability)),
  NightStepKind.detective => l.nightLineDetective,
  NightStepKind.bomb => l.nightLineBomb,
  NightStepKind.chameleon when s.choosesRole => l.nightLineChameleonChoose,
  NightStepKind.chameleon => l.nightLineChameleonAs(l.role(s.ability)),
  NightStepKind.switchman => () {
    final mine = [
      for (final o in steps)
        if (o.kind == NightStepKind.switchman && o.actorId == s.actorId) o,
    ];
    return mine.length > 1
        ? l.nightLineSwitchmanBullet(mine.indexOf(s) + 1, mine.length)
        : l.nightLineSwitchman;
  }(),
};

String _verb(AppLocalizations l, NightStep s, List<String> names) => switch (s.kind) {
  NightStepKind.putana => l.actionBlock(names.single),
  NightStepKind.lawyer => l.actionProtect(names.single),
  NightStepKind.witch => l.actionLink(names[0], names[1]),
  NightStepKind.silencer => l.actionSilenceShort(names.single),
  NightStepKind.bomb => l.actionPlant(names[0], names[1]),
  NightStepKind.switchman => l.actionRedirectTo(names.single),
  _ => switch (s.ability) {
    Role.doctor => l.actionSave(names.single),
    Role.detective => l.actionCheck(names.single),
    _ => l.actionKill(names.single),
  },
};

String _pickHint(AppLocalizations l, NightStep s) => switch (s.kind) {
  NightStepKind.putana => l.nightPickToBlock,
  NightStepKind.lawyer => l.nightPickToProtect,
  NightStepKind.witch => l.nightPickTwoToLink,
  NightStepKind.silencer => l.nightPickToSilence,
  NightStepKind.bomb => l.nightPickTwoToPlant,
  NightStepKind.switchman => l.nightPickToRedirect,
  NightStepKind.chameleon when s.choosesRole => l.chameleonPickHint,
  _ => switch (s.ability) {
    Role.doctor => l.nightPickToSave,
    Role.detective => l.nightPickToCheck,
    _ => l.nightPickToKill,
  },
};

/// "No action tonight": a pill that stays selected when picked.
class _NoActionChip extends StatelessWidget {
  const _NoActionChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final shape = StadiumBorder(
      side: BorderSide(color: selected ? c.civilian : c.veil(0.10), width: selected ? 1.5 : 1),
    );
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        shape: shape,
        color: selected ? c.tint(c.civilian, 0.14) : c.veil(0.04),
        child: InkWell(
          key: const Key('noAction'),
          customBorder: shape,
          onTap: onTap,
          child: Container(
            height: Sizes.iconButton,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MafiaIcon(
                  selected ? MafiaGlyphs.check : MafiaGlyphs.putana,
                  size: 16,
                  color: selected ? c.civilianSoft : c.textMuted,
                ),
                const SizedBox(width: Space.sm),
                Text(
                  label,
                  style: context.type.labelMedium!.copyWith(
                    color: selected ? c.civilianSoft : c.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
