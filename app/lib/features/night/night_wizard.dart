import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../../common/describe.dart';
import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../l10n/app_localizations.dart';
import 'night_steps.dart';

/// Step-by-step night: intro → one step per role (resolution order) →
/// review → resolve.
class NightWizard extends ConsumerStatefulWidget {
  const NightWizard({super.key, required this.session});

  final GameSession session;

  @override
  ConsumerState<NightWizard> createState() => _NightWizardState();
}

class _NightWizardState extends ConsumerState<NightWizard> {
  late final List<NightStep> _steps = buildNightSteps(widget.session.state);

  /// -1 = intro, steps.length = review.
  int _index = -1;

  /// Step index → chosen target, or null for "no action".
  final Map<int, String?> _choices = {};
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
    await ref.read(activeGameProvider.notifier).apply(NightInput(_actionsBefore(_steps.length)));
  }

  @override
  Widget build(BuildContext context) {
    if (_index < 0) return _intro(context);
    if (_index >= _steps.length) return _review(context);
    return _step(context, _steps[_index]);
  }

  Widget _intro(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bedtime_outlined, size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    l.nightIntro,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
        BottomActions(
          children: [
            FilledButton(onPressed: () => setState(() => _index = 0), child: Text(l.nightBegin)),
          ],
        ),
      ],
    );
  }

  Widget _step(BuildContext context, NightStep step) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final actor = _state.player(step.actorId);
    final chosen = _choices[_index];
    final answered = _choices.containsKey(_index);
    final blocked = step.kind != NightStepKind.mafia && _blocked.contains(step.actorId);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(16),
            children: [
              Text(
                l.nightStepCounter(_index + 1, _steps.length),
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 8),
              Text(_prompt(l, step.kind), style: theme.textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                step.kind == NightStepKind.mafia
                    ? l.nightMafiaDecider(actor.name)
                    : l.nightActor(actor.name),
                style: theme.textTheme.bodyLarge,
              ),
              if (blocked) ...[
                const SizedBox(height: 12),
                _Banner(
                  icon: Icons.block,
                  text: l.nightBlockedWarning,
                  color: theme.colorScheme.error,
                ),
              ],
              const SizedBox(height: 12),
              _NoActionOption(
                selected: answered && chosen == null,
                onTap: () => setState(() => _choices[_index] = null),
              ),
              for (final id in step.targetIds)
                PlayerOption(
                  key: Key('target_$id'),
                  player: _state.player(id),
                  selected: chosen == id,
                  note: step.disabledTargetIds.contains(id) ? l.nightDoctorLastNight : null,
                  onTap: step.disabledTargetIds.contains(id)
                      ? null
                      : () => setState(() => _choices[_index] = id),
                ),
            ],
          ),
        ),
        // Pinned outside the list so the host sees it without scrolling.
        if (step.kind == NightStepKind.detective && chosen != null)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
            child: _DetectiveAnswer(
              result: previewDetectiveResult(
                _state,
                _actionsBefore(_index),
                DetectiveCheck(step.actorId, chosen),
              ),
            ),
          ),
        BottomActions(
          children: [
            OutlinedButton(onPressed: () => setState(() => _index--), child: Text(l.back)),
            FilledButton(
              key: const Key('nightNext'),
              onPressed: answered ? () => setState(() => _index++) : null,
              child: Text(l.next),
            ),
          ],
        ),
      ],
    );
  }

  Widget _review(BuildContext context) {
    final l = context.l10n;
    final describe = Describer(l, _state);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsetsDirectional.all(16),
            children: [
              Text(l.nightReviewTitle, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              if (_steps.isEmpty) Text(l.logNoActions),
              for (final (i, step) in _steps.indexed)
                Card(
                  child: ListTile(
                    title: Text(
                      _choices[i] == null
                          ? l.reviewNoAction(describe.actor(step.actorId))
                          : describe.action(step.actionFor(_choices[i]!)),
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => setState(() => _index = i),
                  ),
                ),
            ],
          ),
        ),
        BottomActions(
          children: [
            OutlinedButton(
              onPressed: _steps.isEmpty
                  ? () => setState(() => _index = -1)
                  : () => setState(() => _index--),
              child: Text(l.back),
            ),
            FilledButton(
              key: const Key('resolveNight'),
              onPressed: _resolving ? null : _resolve,
              child: Text(l.nightResolve),
            ),
          ],
        ),
      ],
    );
  }
}

String _prompt(AppLocalizations l, NightStepKind kind) => switch (kind) {
  NightStepKind.potana => l.nightWakePotana,
  NightStepKind.lawyer => l.nightWakeLawyer,
  NightStepKind.mafia => l.nightWakeMafia,
  NightStepKind.joker => l.nightWakeJoker,
  NightStepKind.doctor => l.nightWakeDoctor,
  NightStepKind.detective => l.nightWakeDetective,
};

class _NoActionOption extends StatelessWidget {
  const _NoActionOption({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: selected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
      margin: const EdgeInsetsDirectional.symmetric(vertical: 4),
      child: ListTile(
        key: const Key('noAction'),
        leading: const Icon(Icons.do_not_disturb_alt),
        title: Text(context.l10n.nightNoAction),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.circle_outlined,
          color: selected ? scheme.primary : scheme.outline,
        ),
        onTap: onTap,
      ),
    );
  }
}

/// What the host signals to the Detective, shown big.
class _DetectiveAnswer extends StatelessWidget {
  const _DetectiveAnswer({required this.result});

  /// Null when the Detective is blocked.
  final DetectiveResult? result;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    if (result == null) {
      return _Banner(
        icon: Icons.block,
        text: l.nightDetectiveBlocked,
        color: theme.colorScheme.error,
      );
    }
    final team = result == DetectiveResult.mafia ? Team.mafia : Team.civilians;
    final color = teamColor(context, team);
    return Card(
      key: const Key('detectiveAnswer'),
      color: color.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.nightDetectiveShow,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              result == DetectiveResult.mafia ? l.resultMafia : l.resultCivilian,
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsetsDirectional.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.6)),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: TextStyle(color: color)),
        ),
      ],
    ),
  );
}
