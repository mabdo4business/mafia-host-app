import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../game/providers.dart';
import '../../game/role_mix.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'assign_cards_screen.dart';
import 'players_sheet.dart';
import 'reveal_screen.dart';

/// Timer choices in seconds (GAME_RULES §2 defaults: 120, 30, 15, 20).
const _freeChatOptions = [60, 120, 180, 300];
const _speechOptions = [20, 30, 45, 60];
const _foulOptions = [10, 15, 20, 30];
const _mafiaTalkOptions = [10, 20, 30, 45];

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
      for (final r in configurableRoles) chip(r),
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
          const SizedBox(height: Space.sm),
          Text(
            l.setupSeatOrderHint,
            key: const Key('seatOrderHint'),
            style: context.type.bodySmall!.copyWith(fontSize: TextSizes.small),
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
          Text(
            l.setupRolesHint,
            style: context.type.bodySmall!.copyWith(fontSize: TextSizes.small),
          ),
          const SizedBox(height: Space.xl),
          SectionTitle(l.setupOptionsSection),
          const SizedBox(height: Space.sm),
          _OptionCard(
            title: l.setupRolesHow,
            subtitle: draft.cardsMode ? l.setupModeCardsHint : l.setupModePhoneHint,
            below: SegmentedPill<bool>(
              key: const Key('rolesMode'),
              segments: [(true, l.setupModeCards), (false, l.setupModePhone)],
              selected: draft.cardsMode,
              onChanged: controller.setCardsMode,
            ),
          ),
          const SizedBox(height: 10),
          _OptionCard(
            title: l.setupRevealRole,
            trailing: Switch(
              value: settings.revealRoleOnDeath,
              onChanged: (v) => controller.updateSettings(settings.copyWith(revealRoleOnDeath: v)),
            ),
          ),
          const SizedBox(height: 10),
          _TimersCard(settings: settings, onChanged: controller.updateSettings),
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
            label: draft.cardsMode ? l.setupCardsDealt : l.setupShuffleDeal,
            tone: ActionTone.danger,
            trailing: draft.cardsMode ? MafiaGlyphs.arrow : MafiaGlyphs.shuffle,
            onPressed: problem != null
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => draft.cardsMode
                          ? AssignCardsScreen(
                              names: draft.names,
                              mix: draft.mix,
                              settings: settings,
                            )
                          : RevealScreen(names: draft.names, mix: draft.mix, settings: settings),
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
                    Text(
                      subtitle!,
                      style: context.type.bodySmall!.copyWith(fontSize: TextSizes.small),
                    ),
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

/// Free Chat, Speech, Foul and the Mafia's talk at night.
class _TimersCard extends StatelessWidget {
  const _TimersCard({required this.settings, required this.onChanged});

  final GameSettings settings;
  final ValueChanged<GameSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    String clock(int s) => s % 60 == 0 ? l.minutesShort(s ~/ 60) : l.secondsShort(s);
    Widget timer(
      String key,
      String title,
      List<int> options,
      int selected,
      GameSettings Function(int) set,
    ) => Padding(
      padding: const EdgeInsetsDirectional.only(top: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: context.type.bodySmall),
          const SizedBox(height: Space.xs),
          SegmentedPill<int>(
            key: Key(key),
            segments: [for (final s in options) (s, clock(s))],
            selected: options.contains(selected) ? selected : options.first,
            onChanged: (s) => onChanged(set(s)),
          ),
        ],
      ),
    );
    return _OptionCard(
      title: l.setupTimers,
      subtitle: l.setupTimersHint,
      below: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          timer(
            'freeChatTimer',
            l.dayFreeChat,
            _freeChatOptions,
            settings.freeChatSeconds,
            (s) => settings.copyWith(freeChatSeconds: s),
          ),
          timer(
            'speechTimer',
            l.daySpeech,
            _speechOptions,
            settings.speechSeconds,
            (s) => settings.copyWith(speechSeconds: s),
          ),
          timer(
            'foulTimer',
            l.dayFoul,
            _foulOptions,
            settings.foulSeconds,
            (s) => settings.copyWith(foulSeconds: s),
          ),
          timer(
            'mafiaTimer',
            l.nightMafiaTalk,
            _mafiaTalkOptions,
            settings.mafiaDiscussionSeconds,
            (s) => settings.copyWith(mafiaDiscussionSeconds: s),
          ),
        ],
      ),
    );
  }
}

/// Every open question of GAME_RULES §6 (Q14 is "Reveal role on death" on
/// the setup screen itself).
class _HouseRulesSheet extends ConsumerWidget {
  const _HouseRulesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(setupDraftProvider).settings;
    final controller = ref.read(setupDraftProvider.notifier);
    void update(GameSettings next) => controller.updateSettings(next);

    Widget rule(String key, String title, bool value, ValueChanged<bool> onChanged) =>
        SwitchListTile(
          key: Key(key),
          contentPadding: EdgeInsetsDirectional.zero,
          title: Text(title, style: context.type.bodyMedium),
          value: value,
          onChanged: onChanged,
        );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.xl, Space.page, Space.lg),
          children: [
            Text(l.setupHouseRules, style: context.type.headlineSmall),
            const SizedBox(height: Space.xs),
            Text(l.setupHouseRulesSheetHint, style: context.type.bodySmall),
            const SizedBox(height: Space.md),
            rule(
              'rule_godfatherAppearsCivilian',
              l.ruleGodfatherAppearsCivilian,
              s.godfatherAppearsCivilian,
              (v) => update(s.copyWith(godfatherAppearsCivilian: v)),
            ),
            rule(
              'rule_putanaCanBlockMafia',
              l.rulePutanaCanBlockMafia,
              s.putanaCanBlockMafia,
              (v) => update(s.copyWith(putanaCanBlockMafia: v)),
            ),
            rule(
              'rule_chameleonMafiaJoinsMafiaTeam',
              l.ruleChameleonMafiaJoins,
              s.chameleonMafiaJoinsMafiaTeam,
              (v) => update(s.copyWith(chameleonMafiaJoinsMafiaTeam: v)),
            ),
            rule(
              'rule_detectiveChainOnVote',
              l.ruleDetectiveChainOnVote,
              s.detectiveChainOnVote,
              (v) => update(s.copyWith(detectiveChainOnVote: v)),
            ),
            rule(
              'rule_blockedChecksCount',
              l.ruleBlockedChecksCount,
              s.blockedChecksCount,
              (v) => update(s.copyWith(blockedChecksCount: v)),
            ),
            rule(
              'rule_doctorBlocksChainDeaths',
              l.ruleDoctorBlocksChainDeaths,
              s.doctorBlocksChainDeaths,
              (v) => update(s.copyWith(doctorBlocksChainDeaths: v)),
            ),
            rule(
              'rule_switchmanRedirectsEach',
              l.ruleSwitchmanRedirectsEach,
              s.switchmanRedirectsEach,
              (v) => update(s.copyWith(switchmanRedirectsEach: v)),
            ),
            rule(
              'rule_doctorSavesRedirectedBullet',
              l.ruleDoctorSavesRedirected,
              s.doctorSavesRedirectedBullet,
              (v) => update(s.copyWith(doctorSavesRedirectedBullet: v)),
            ),
            rule(
              'rule_bombNoEffectBeforePlant',
              l.ruleBombNoEffectBeforePlant,
              s.bombNoEffectBeforePlant,
              (v) => update(s.copyWith(bombNoEffectBeforePlant: v)),
            ),
            rule(
              'rule_silenceLastsNextDay',
              l.ruleSilenceLastsNextDay,
              s.silenceLastsNextDay,
              (v) => update(s.copyWith(silenceLastsNextDay: v)),
            ),
            rule(
              'rule_witchCiviliansOnly',
              l.ruleWitchCiviliansOnly,
              s.witchCiviliansOnly,
              (v) => update(s.copyWith(witchCiviliansOnly: v)),
            ),
            rule(
              'rule_mafiaWinsAtParity',
              l.ruleMafiaWinsAtParity,
              s.mafiaWinsAtParity,
              (v) => update(s.copyWith(mafiaWinsAtParity: v)),
            ),
            const SizedBox(height: Space.md),
            Text(l.ruleSecondTie, style: context.type.bodyMedium),
            const SizedBox(height: Space.sm),
            SegmentedPill<SecondTieRule>(
              key: const Key('rule_secondTieRule'),
              segments: [
                (SecondTieRule.noElimination, l.tieNoElimination),
                (SecondTieRule.hostDecides, l.tieHostDecides),
                (SecondTieRule.randomAmongTied, l.tieRandom),
              ],
              selected: s.secondTieRule,
              onChanged: (r) => update(s.copyWith(secondTieRule: r)),
            ),
          ],
        ),
      ),
    );
  }
}
