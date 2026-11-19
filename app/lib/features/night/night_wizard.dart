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

/// Step-by-step night: intro → one step per role (resolution order) →
/// review → resolve. One screen; the prompt, selection color and the CTA verb
/// follow the role being woken.
class NightWizard extends ConsumerStatefulWidget {
  const NightWizard({super.key, required this.session, this.initialIndex = -1});

  final GameSession session;

  /// -1 = intro (previews may start on a step).
  final int initialIndex;

  @override
  ConsumerState<NightWizard> createState() => _NightWizardState();
}

class _NightWizardState extends ConsumerState<NightWizard> {
  late final List<NightStep> _steps = buildNightSteps(widget.session.state);

  /// -1 = intro, steps.length = review.
  late int _index = widget.initialIndex.clamp(-1, _steps.length);

  /// Step index → chosen target, or null for "no action".
  final Map<int, String?> _choices = {};

  /// Mafia step: player id → how many Mafia members proposed them (shown as
  /// dots; the decider's pick is what counts).
  final Map<String, int> _proposals = {};
  bool _resolving = false;

  GameState get _state => widget.session.state;

  List<NightAction> _actionsBefore(int index) => [
    for (var i = 0; i < index; i++)
      if (_choices[i] case final target?) _steps[i].actionFor(target),
  ];

  Set<String> get _blocked => {
    for (final a in _actionsBefore(_steps.length))
      if (a is PotanaBlock) a.targetId,
  };

  Future<void> _resolve() async {
    setState(() => _resolving = true);
    // Before applying: the wizard is replaced (and its ref unusable) once
    // the night resolves.
    playGameSound(ref, GameSound.morning);
    await ref.read(activeGameProvider.notifier).apply(NightInput(_actionsBefore(_steps.length)));
  }

  Future<void> _next(NightStep step) async {
    final target = _choices[_index];
    // The Detective's answer is shown full screen before moving on.
    if (step.kind == NightStepKind.detective && target != null) {
      final result = previewDetectiveResult(
        _state,
        _actionsBefore(_index),
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

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
    if (_index >= _steps.length) return _review(context, header);
    return _step(context, header, _steps[_index]);
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

  Widget _step(BuildContext context, Widget header, NightStep step) {
    final l = context.l10n;
    final c = context.mafia;
    final actor = _state.player(step.actorId);
    final chosen = _choices[_index];
    final answered = _choices.containsKey(_index);
    final blocked = step.kind != NightStepKind.mafia && _blocked.contains(step.actorId);
    final accent = step.kind == NightStepKind.mafia ? c.mafia : c.civilian;
    final targets = step.targetIds.toSet();
    final mafiaStep = step.kind == NightStepKind.mafia;
    final mafiaAlive = _state.alivePlayers.where((p) => p.team == Team.mafia).length;
    final godfatherDecides = mafiaStep && actor.effectiveRole == Role.godfather;

    // Seating order. The living players this role can't pick are left out
    // rather than greyed: greying them would show the table who is Mafia.
    final tiles = [
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
            selected: chosen == p.id,
            enabled: !step.disabledTargetIds.contains(p.id),
            note: step.disabledTargetIds.contains(p.id) ? l.nightDoctorLastNight : null,
            dots: mafiaStep ? _proposals[p.id] ?? 0 : 0,
            onTap: () => setState(() => _choices[_index] = p.id),
            onLongPress: mafiaStep
                ? () => setState(
                    () => _proposals[p.id] = ((_proposals[p.id] ?? 0) + 1) % (mafiaAlive + 1),
                  )
                : null,
          ),
    ];

    final String cta;
    if (chosen != null && godfatherDecides) {
      cta = l.nightGodfatherConfirms(_state.player(chosen).name);
    } else if (chosen != null) {
      cta = _verb(l, step.kind, _state.player(chosen).name);
    } else if (answered) {
      cta = l.nightContinueNoAction;
    } else {
      cta = _pickHint(l, step.kind);
    }

    return PhaseScaffold(
      transparent: true,
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.lg),
        children: [
          header,
          const SizedBox(height: 18),
          StepRail(steps: [for (final s in _steps) l.role(_stepRole(s.kind))], current: _index),
          const SizedBox(height: 18),
          PromptCard(
            glyph: roleGlyph(_stepRole(step.kind)),
            title: _title(l, step.kind),
            line: _line(l, step.kind),
            accent: accent,
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.kind == NightStepKind.mafia
                      ? l.nightMafiaDecider(actor.name)
                      : l.nightActor(actor.name),
                  style: context.type.bodySmall,
                ),
                if (blocked)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(top: Space.xs),
                    child: Text(
                      l.nightBlockedWarning,
                      key: const Key('blockedWarning'),
                      style: context.type.bodySmall!.copyWith(color: c.mafiaSoft),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PlayerTargetGrid(children: tiles),
          if (mafiaStep && mafiaAlive > 1) ...[
            const SizedBox(height: Space.md),
            Text(l.nightMafiaProposalHint, style: context.type.bodySmall!.copyWith(fontSize: 12)),
          ],
          const SizedBox(height: Space.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _NoActionChip(
              selected: answered && chosen == null,
              onTap: () => setState(() => _choices[_index] = null),
            ),
          ),
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
              tone: step.kind == NightStepKind.mafia ? ActionTone.danger : ActionTone.phase,
              onPressed: answered ? () => _next(step) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _review(BuildContext context, Widget header) {
    final l = context.l10n;
    final c = context.mafia;
    final describe = Describer(l, _state);
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
          if (_steps.isEmpty) Text(l.logNoActions, style: context.type.bodyMedium),
          for (final (i, step) in _steps.indexed) ...[
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
                      color: c.tint(step.kind == NightStepKind.mafia ? c.mafia : c.civilian, 0.16),
                      borderRadius: BorderRadius.circular(Radii.iconBox),
                    ),
                    child: MafiaIcon(
                      roleGlyph(_stepRole(step.kind)),
                      color: step.kind == NightStepKind.mafia ? c.mafiaSoft : c.civilianSoft,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _choices[i] == null
                          ? l.reviewNoAction(describe.actor(step.actorId))
                          : describe.action(step.actionFor(_choices[i]!)),
                      style: context.type.bodyMedium,
                    ),
                  ),
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
            onPressed: () => setState(() => _index = _steps.isEmpty ? -1 : _index - 1),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: PrimaryActionButton(
              key: const Key('resolveNight'),
              label: l.nightResolve,
              trailing: MafiaGlyphs.sun,
              onPressed: _resolving ? null : _resolve,
            ),
          ),
        ],
      ),
    );
  }
}

Role _stepRole(NightStepKind kind) => switch (kind) {
  NightStepKind.potana => Role.potana,
  NightStepKind.lawyer => Role.lawyer,
  NightStepKind.mafia => Role.mafia,
  NightStepKind.joker => Role.joker,
  NightStepKind.doctor => Role.doctor,
  NightStepKind.detective => Role.detective,
};

String _title(AppLocalizations l, NightStepKind kind) => switch (kind) {
  NightStepKind.potana => l.nightWakeTitlePotana,
  NightStepKind.lawyer => l.nightWakeTitleLawyer,
  NightStepKind.mafia => l.nightWakeTitleMafia,
  NightStepKind.joker => l.nightWakeTitleJoker,
  NightStepKind.doctor => l.nightWakeTitleDoctor,
  NightStepKind.detective => l.nightWakeTitleDetective,
};

String _line(AppLocalizations l, NightStepKind kind) => switch (kind) {
  NightStepKind.potana => l.nightLinePotana,
  NightStepKind.lawyer => l.nightLineLawyer,
  NightStepKind.mafia => l.nightLineMafia,
  NightStepKind.joker => l.nightLineJoker,
  NightStepKind.doctor => l.nightLineDoctor,
  NightStepKind.detective => l.nightLineDetective,
};

String _verb(AppLocalizations l, NightStepKind kind, String name) => switch (kind) {
  NightStepKind.potana => l.actionBlock(name),
  NightStepKind.lawyer => l.actionProtect(name),
  NightStepKind.mafia || NightStepKind.joker => l.actionKill(name),
  NightStepKind.doctor => l.actionSave(name),
  NightStepKind.detective => l.actionCheck(name),
};

String _pickHint(AppLocalizations l, NightStepKind kind) => switch (kind) {
  NightStepKind.potana => l.nightPickToBlock,
  NightStepKind.lawyer => l.nightPickToProtect,
  NightStepKind.mafia || NightStepKind.joker => l.nightPickToKill,
  NightStepKind.doctor => l.nightPickToSave,
  NightStepKind.detective => l.nightPickToCheck,
};

/// "No action tonight": a pill that stays selected when picked.
class _NoActionChip extends StatelessWidget {
  const _NoActionChip({required this.selected, required this.onTap});

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
                  selected ? MafiaGlyphs.check : MafiaGlyphs.potana,
                  size: 16,
                  color: selected ? c.civilianSoft : c.textMuted,
                ),
                const SizedBox(width: Space.sm),
                Text(
                  context.l10n.nightNoAction,
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
