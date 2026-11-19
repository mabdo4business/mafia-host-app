import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/providers.dart';
import '../../game/role_mix.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'players_sheet.dart';
import 'reveal_screen.dart';

const _timerOptions = [0, 60, 120, 180, 300];

/// Mockup order: Mafia team first, then the Civilian roles.
const _gridRoles = [
  Role.godfather,
  Role.potana,
  Role.lawyer,
  Role.mafia,
  Role.doctor,
  Role.detective,
  Role.bomb,
  Role.joker,
  Role.chameleon,
];

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(setupDraftProvider.notifier).prefillNames();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final draft = ref.watch(setupDraftProvider);
    final controller = ref.read(setupDraftProvider.notifier);
    final settings = draft.settings;
    final problem = draft.problem;
    final hasBomb = draft.countOf(Role.bomb) > 0 || draft.countOf(Role.chameleon) > 0;
    final mafia = [
      for (final r in Role.values)
        if (r.team == Team.mafia) draft.countOf(r),
    ].fold(0, (a, b) => a + b);
    final civilians = draft.names.length - mafia;

    Widget chip(Role role) => RoleChip(
      key: Key('roleChip_${role.name}'),
      glyph: roleGlyph(role),
      name: l.role(role),
      team: role.team,
      count: draft.countOf(role),
      onTap: draft.countOf(role) < controller.maxCount(role)
          ? () => controller.setRoleCount(role, draft.countOf(role) + 1)
          : null,
      onLongPress: draft.countOf(role) > 0
          ? () => controller.setRoleCount(role, draft.countOf(role) - 1)
          : null,
    );
    final chips = [
      for (final r in _gridRoles) chip(r),
      RoleChip(
        key: const Key('roleChip_civilian'),
        glyph: roleGlyph(Role.civilian),
        name: l.roleCivilian,
        team: Team.civilians,
        count: draft.civilianCount.clamp(0, 999),
      ),
    ];

    return PhaseScaffold(
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, Space.xl),
        children: [
          Row(
            children: [
              IconCircleButton(
                glyph: MafiaGlyphs.back,
                semanticLabel: l.back,
                onPressed: () => Navigator.maybePop(context),
              ),
              const SizedBox(width: Space.md),
              Expanded(child: Text(l.setupTitle, style: context.type.headlineSmall)),
            ],
          ),
          const SizedBox(height: Space.xl),
          _PlayersCard(
            names: draft.names,
            mafia: mafia,
            civilians: civilians,
            balanced: problem == null,
            onEdit: () => showPlayersSheet(context),
          ),
          const SizedBox(height: Space.xl),
          SectionTitle(
            l.setupRolesSection,
            action: l.setupAutoBalance,
            onAction: controller.useSuggestedMix,
          ),
          const SizedBox(height: Space.sm),
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
          Text(l.setupRolesHint, style: context.type.bodySmall!.copyWith(fontSize: 12)),
          if (hasBomb) ...[
            const SizedBox(height: Space.lg),
            _OptionCard(
              title: l.setupBombTakesDown,
              subtitle: l.setupBombTakesDownHint,
              trailing: SegmentedPill<int>(
                key: const Key('bombCount'),
                dense: true,
                segments: [
                  for (final n in [2, 3]) (n, context.number(n)),
                ],
                selected: settings.bombVictimCount,
                onChanged: (n) => controller.updateSettings(settings.copyWith(bombVictimCount: n)),
              ),
            ),
          ],
          const SizedBox(height: Space.xl),
          SectionTitle(l.setupOptionsSection),
          const SizedBox(height: Space.sm),
          _OptionCard(
            title: l.setupRevealRole,
            trailing: Switch(
              value: settings.revealRoleOnDeath,
              onChanged: (v) => controller.updateSettings(settings.copyWith(revealRoleOnDeath: v)),
            ),
          ),
          const SizedBox(height: 10),
          _OptionCard(
            title: l.setupDiscussionTimer,
            below: SegmentedPill<int>(
              segments: [
                for (final s in _timerOptions) (s, s == 0 ? l.timerOff : l.minutes(s ~/ 60)),
              ],
              selected: draft.discussionSeconds,
              onChanged: controller.setDiscussionSeconds,
            ),
          ),
          const SizedBox(height: 10),
          _OptionCard(
            title: l.setupHouseRules,
            subtitle: l.setupHouseRulesHint,
            trailing: MafiaIcon(MafiaGlyphs.forward, color: c.textMuted),
            onTap: () => _showHouseRules(context),
          ),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (problem != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 10),
              child: Text(
                setupProblemText(l, problem),
                textAlign: TextAlign.center,
                style: context.type.bodySmall!.copyWith(color: c.mafiaSoft),
              ),
            ),
          PrimaryActionButton(
            key: const Key('dealRoles'),
            label: l.setupShuffleDeal,
            tone: ActionTone.danger,
            trailing: MafiaGlyphs.shuffle,
            onPressed: problem != null
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => RevealScreen(
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
    );
  }

  void _showHouseRules(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Color.alphaBlend(context.mafia.veil(0.05), context.mafia.bg),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.button)),
    ),
    builder: (_) => const _HouseRulesSheet(),
  );
}

String setupProblemText(AppLocalizations l, SetupProblem p) => switch (p) {
  SetupProblem.tooFewPlayers => l.setupProblemTooFewPlayers(minPlayers),
  SetupProblem.duplicateName => l.setupProblemDuplicateName,
  SetupProblem.tooManyRoles => l.setupProblemTooManyRoles,
  SetupProblem.noMafia => l.setupProblemNoMafia,
  SetupProblem.mafiaTooStrong => l.setupProblemMafiaTooStrong,
};

/// "Players at the table · 11" with the team balance; opens the players sheet.
class _PlayersCard extends StatelessWidget {
  const _PlayersCard({
    required this.names,
    required this.mafia,
    required this.civilians,
    required this.balanced,
    required this.onEdit,
  });

  final List<String> names;
  final int mafia, civilians;
  final bool balanced;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    return GlassCard(
      key: const Key('playersCard'),
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.setupPlayersAtTable, style: context.type.bodySmall),
                    Text(context.number(names.length), style: context.type.displayLarge),
                  ],
                ),
              ),
              if (names.isNotEmpty) ...[
                AvatarStack(
                  names: names.take(3).toList(),
                  extra: names.length > 3 ? names.length - 3 : 0,
                  ring: Color.alphaBlend(c.surface, c.bg),
                ),
                const SizedBox(width: Space.md),
              ],
              Semantics(
                button: true,
                label: l.setupAddPlayer,
                excludeSemantics: true,
                child: Material(
                  color: c.text,
                  borderRadius: BorderRadius.circular(Radii.iconBoxLg),
                  child: InkWell(
                    key: const Key('editPlayers'),
                    borderRadius: BorderRadius.circular(Radii.iconBoxLg),
                    onTap: onEdit,
                    child: SizedBox.square(
                      dimension: 48,
                      child: Center(child: MafiaIcon(MafiaGlyphs.plus, color: c.onText)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          TeamBalanceBar(
            mafia: mafia,
            civilians: civilians.clamp(0, 999),
            note: names.isEmpty
                ? l.setupAddPlayersHint
                : balanced
                ? l.setupBalancedFor(names.length)
                : null,
          ),
        ],
      ),
    );
  }
}

/// A glass row with a title, optional hint and a control at the end (or
/// below, for wide controls).
class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.title, this.subtitle, this.trailing, this.below, this.onTap});

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? below;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GlassCard(
    radius: Radii.tile,
    onTap: onTap,
    padding: const EdgeInsetsDirectional.symmetric(horizontal: Space.lg, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.type.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: context.type.bodySmall!.copyWith(fontSize: 12)),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: Space.md), trailing!],
          ],
        ),
        if (below != null) ...[const SizedBox(height: Space.md), below!],
      ],
    ),
  );
}

class _HouseRulesSheet extends ConsumerWidget {
  const _HouseRulesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final settings = ref.watch(setupDraftProvider).settings;
    final controller = ref.read(setupDraftProvider.notifier);
    void update(GameSettings s) => controller.updateSettings(s);

    Widget rule(String title, bool value, ValueChanged<bool> onChanged) => SwitchListTile(
      contentPadding: EdgeInsetsDirectional.zero,
      title: Text(title, style: context.type.bodyMedium),
      value: value,
      onChanged: onChanged,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.xl, Space.page, Space.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.setupHouseRules, style: context.type.headlineSmall),
            const SizedBox(height: Space.md),
            rule(
              l.ruleDoctorSaveBlocksJoker,
              settings.doctorSaveBlocksJokerKill,
              (v) => update(settings.copyWith(doctorSaveBlocksJokerKill: v)),
            ),
            rule(
              l.ruleDoctorCanSaveBombVictims,
              settings.doctorCanSaveBombVictims,
              (v) => update(settings.copyWith(doctorCanSaveBombVictims: v)),
            ),
            rule(
              l.ruleBlockedBombExplodes,
              settings.blockedBombStillExplodes,
              (v) => update(settings.copyWith(blockedBombStillExplodes: v)),
            ),
            rule(
              l.ruleChameleonMafia,
              settings.chameleonCanPickMafiaRoles,
              (v) => update(settings.copyWith(chameleonCanPickMafiaRoles: v)),
            ),
            const SizedBox(height: Space.md),
            Text(l.ruleTieVote, style: context.type.bodyMedium),
            const SizedBox(height: Space.sm),
            SegmentedPill<TieVoteRule>(
              segments: [
                (TieVoteRule.hostDecides, l.tieHostDecides),
                (TieVoteRule.revote, l.tieRevote),
                (TieVoteRule.noElimination, l.tieNoElimination),
              ],
              selected: settings.tieVoteRule,
              onChanged: (r) => update(settings.copyWith(tieVoteRule: r)),
            ),
          ],
        ),
      ),
    );
  }
}
