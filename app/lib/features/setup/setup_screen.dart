import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../game/providers.dart';
import '../../game/role_mix.dart';
import '../../l10n/app_localizations.dart';
import 'deal_screen.dart';

const _timerOptions = [0, 60, 120, 180, 300];

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _nameController = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    ref.read(setupDraftProvider.notifier).prefillNames();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (ref.read(setupDraftProvider.notifier).addPlayer(_nameController.text)) {
      _nameController.clear();
    }
    _nameFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final draft = ref.watch(setupDraftProvider);
    final controller = ref.read(setupDraftProvider.notifier);
    final settings = draft.settings;
    final problem = draft.problem;
    final hasBomb = draft.countOf(Role.bomb) > 0 || draft.countOf(Role.chameleon) > 0;

    return Scaffold(
      appBar: AppBar(title: Text(l.setupTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.only(bottom: 24),
        children: [
          SectionHeader(l.setupPlayersSection, trailing: Text(l.playerCount(draft.names.length))),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('playerNameField'),
                    controller: _nameController,
                    focusNode: _nameFocus,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      hintText: l.setupPlayerNameHint,
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: l.setupAddPlayer,
                  icon: const Icon(Icons.person_add_alt_1),
                  onPressed: _addPlayer,
                ),
              ],
            ),
          ),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: draft.names.length,
            onReorderItem: controller.reorder,
            itemBuilder: (context, i) => ListTile(
              key: ValueKey(draft.names[i]),
              leading: CircleAvatar(child: Text(context.number(i + 1))),
              title: Text(draft.names[i]),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l.setupRemovePlayer,
                    icon: const Icon(Icons.close),
                    onPressed: () => controller.removePlayer(i),
                  ),
                  ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_handle)),
                ],
              ),
            ),
          ),
          SectionHeader(
            l.setupRolesSection,
            trailing: TextButton(
              onPressed: controller.useSuggestedMix,
              child: Text(l.setupSuggestedMix),
            ),
          ),
          for (final role in configurableRoles)
            _RoleCountRow(
              role: role,
              count: draft.countOf(role),
              onChanged: (n) => controller.setRoleCount(role, n),
              max: controller.maxCount(role),
            ),
          _RoleCountRow(role: Role.civilian, count: draft.civilianCount.clamp(0, 999)),
          SectionHeader(l.setupOptionsSection),
          if (hasBomb)
            ListTile(
              title: Text(l.setupBombVictims),
              trailing: SegmentedButton<int>(
                segments: [
                  for (final n in [2, 3]) ButtonSegment(value: n, label: Text(context.number(n))),
                ],
                selected: {settings.bombVictimCount},
                onSelectionChanged: (s) =>
                    controller.updateSettings(settings.copyWith(bombVictimCount: s.single)),
              ),
            ),
          SwitchListTile(
            title: Text(l.setupRevealRole),
            value: settings.revealRoleOnDeath,
            onChanged: (v) => controller.updateSettings(settings.copyWith(revealRoleOnDeath: v)),
          ),
          ListTile(
            title: Text(l.setupDiscussionTimer),
            trailing: DropdownButton<int>(
              value: draft.discussionSeconds,
              underline: const SizedBox.shrink(),
              items: [
                for (final s in _timerOptions)
                  DropdownMenuItem(value: s, child: Text(s == 0 ? l.timerOff : l.minutes(s ~/ 60))),
              ],
              onChanged: (v) => controller.setDiscussionSeconds(v ?? 0),
            ),
          ),
          ExpansionTile(
            title: Text(l.setupHouseRules),
            children: [
              SwitchListTile(
                title: Text(l.ruleDoctorSaveBlocksJoker),
                value: settings.doctorSaveBlocksJokerKill,
                onChanged: (v) =>
                    controller.updateSettings(settings.copyWith(doctorSaveBlocksJokerKill: v)),
              ),
              SwitchListTile(
                title: Text(l.ruleDoctorCanSaveBombVictims),
                value: settings.doctorCanSaveBombVictims,
                onChanged: (v) =>
                    controller.updateSettings(settings.copyWith(doctorCanSaveBombVictims: v)),
              ),
              SwitchListTile(
                title: Text(l.ruleBlockedBombExplodes),
                value: settings.blockedBombStillExplodes,
                onChanged: (v) =>
                    controller.updateSettings(settings.copyWith(blockedBombStillExplodes: v)),
              ),
              SwitchListTile(
                title: Text(l.ruleChameleonMafia),
                value: settings.chameleonCanPickMafiaRoles,
                onChanged: (v) =>
                    controller.updateSettings(settings.copyWith(chameleonCanPickMafiaRoles: v)),
              ),
              ListTile(
                title: Text(l.ruleTieVote),
                trailing: DropdownButton<TieVoteRule>(
                  value: settings.tieVoteRule,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final rule in TieVoteRule.values)
                      DropdownMenuItem(value: rule, child: Text(_tieRuleLabel(l, rule))),
                  ],
                  onChanged: (v) => controller.updateSettings(settings.copyWith(tieVoteRule: v)),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomActions(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (problem != null)
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 8),
                  child: Text(
                    _problemText(l, problem),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              FilledButton.icon(
                icon: const Icon(Icons.style_outlined),
                label: Text(l.setupDealRoles),
                onPressed: problem != null
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => DealScreen(
                            names: draft.names,
                            mix: draft.mix,
                            settings: settings,
                            discussionSeconds: draft.discussionSeconds,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _tieRuleLabel(AppLocalizations l, TieVoteRule rule) => switch (rule) {
  TieVoteRule.revote => l.tieRevote,
  TieVoteRule.noElimination => l.tieNoElimination,
  TieVoteRule.hostDecides => l.tieHostDecides,
};

String _problemText(AppLocalizations l, SetupProblem p) => switch (p) {
  SetupProblem.tooFewPlayers => l.setupProblemTooFewPlayers(minPlayers),
  SetupProblem.duplicateName => l.setupProblemDuplicateName,
  SetupProblem.tooManyRoles => l.setupProblemTooManyRoles,
  SetupProblem.noMafia => l.setupProblemNoMafia,
  SetupProblem.mafiaTooStrong => l.setupProblemMafiaTooStrong,
};

class _RoleCountRow extends StatelessWidget {
  const _RoleCountRow({required this.role, required this.count, this.onChanged, this.max = 0});

  final Role role;
  final int count;
  final int max;

  /// Null for the computed Civilian row.
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final color = teamColor(context, role.team);
    return ListTile(
      key: Key('roleRow_${role.name}'),
      dense: true,
      leading: Icon(Icons.circle, size: 12, color: color),
      title: Text(l.role(role)),
      subtitle: Text(l.team(role.team)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onChanged != null)
            IconButton(
              key: Key('decrement_${role.name}'),
              tooltip: l.decrease,
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: count > 0 ? () => onChanged!(count - 1) : null,
            ),
          SizedBox(
            width: 32,
            child: Text(
              context.number(count),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (onChanged != null)
            IconButton(
              key: Key('increment_${role.name}'),
              tooltip: l.increase,
              icon: const Icon(Icons.add_circle_outline),
              onPressed: count < max ? () => onChanged!(count + 1) : null,
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
