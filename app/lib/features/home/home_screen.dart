import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../common/widgets.dart';
import '../../data/game_repository.dart';
import '../../game/game_flow_screen.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';
import '../settings/settings_screen.dart';
import '../setup/setup_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _comingSoon() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.comingSoon)));
  }

  Future<void> _newGame(bool canContinue) async {
    final l = context.l10n;
    if (canContinue &&
        !await confirm(
          context,
          title: l.newGameConfirmTitle,
          body: l.newGameConfirmBody,
          confirmLabel: l.homeNewGame,
        )) {
      return;
    }
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const SetupScreen()));
  }

  void _continue() =>
      Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const GameFlowScreen()));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final active = ref.watch(activeGameProvider).value;
    final canContinue = active != null && active.stage != GameStage.gameOver;
    final stats = ref.watch(tableStatsProvider).value ?? const TableStats();
    final recent = ref.watch(recentGamesProvider).value ?? const [];
    final lastNames = ref.watch(lastPlayerNamesProvider).value ?? const [];

    return PhaseScaffold(
      glow: Glow(color: c.tint(c.mafia, 0.28)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, 120),
            children: [
              Text(_greeting(context), style: context.type.bodySmall!.copyWith(letterSpacing: 0.5)),
              const SizedBox(height: Space.xs),
              Text(l.homeTitle, style: context.type.headlineLarge),
              const SizedBox(height: 28),
              _HeroCard(
                session: canContinue ? active : null,
                lastNames: lastNames,
                onStart: () => _newGame(canContinue),
                onContinue: _continue,
              ),
              const SizedBox(height: 20),
              SegmentedPill<bool>(
                segments: [(false, l.modeHostOnly), (true, l.modePlayersPhones)],
                selected: false,
                onChanged: (_) => _comingSoon(),
              ),
              const SizedBox(height: 28),
              SectionTitle(l.homeYourTable),
              const SizedBox(height: Space.md),
              Row(
                children: [
                  Expanded(
                    child: StatTile(value: context.number(stats.games), label: l.statGames),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      value: _rate(context, stats.winRate(Team.mafia)),
                      label: l.statMafiaWins,
                      tint: c.mafia,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      value: _rate(context, stats.winRate(Team.civilians)),
                      label: l.statCivilianWins,
                      tint: c.civilian,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.xl),
              if (recent.isEmpty)
                Text(l.homeRecentEmpty, style: context.type.bodySmall)
              else
                for (final g in recent) ...[_RecentGameRow(game: g), const SizedBox(height: 10)],
            ],
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: FloatingNavBar(
              current: 0,
              items: [
                NavItem(MafiaGlyphs.home, l.navHome),
                NavItem(MafiaGlyphs.calendar, l.navEvents),
                NavItem(MafiaGlyphs.players, l.navPlayers),
                NavItem(MafiaGlyphs.settings, l.settingsTitle),
              ],
              onSelect: (i) => switch (i) {
                3 => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                ),
                0 => null,
                _ => _comingSoon(),
              },
            ),
          ),
        ],
      ),
    );
  }

  String _greeting(BuildContext context) {
    final l = context.l10n;
    final h = DateTime.now().hour;
    return h < 12
        ? l.homeGreetingMorning
        : h < 18
        ? l.homeGreetingAfternoon
        : l.homeGreetingEvening;
  }

  String _rate(BuildContext context, int? percent) =>
      percent == null ? context.l10n.statNone : context.l10n.percent(percent);
}

/// The red "tonight" card: start a game, or continue the one in progress.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.session,
    required this.lastNames,
    required this.onStart,
    required this.onContinue,
  });

  /// The game in progress, if any.
  final GameSession? session;
  final List<String> lastNames;
  final VoidCallback onStart;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final s = session;
    final cardColor = Color.alphaBlend(c.tint(c.mafia, 0.10), c.bg);
    final names = s == null ? lastNames : [for (final p in s.state.players) p.name];

    return Stack(
      children: [
        GlassCard(
          radius: Radii.hero,
          tintColor: c.mafia,
          borderOpacity: 0.25,
          padding: const EdgeInsetsDirectional.all(Space.xl),
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [cardColor, Color.alphaBlend(c.veil(0.03), c.bg)],
            stops: const [0, 0.7],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TagPill(
                s == null ? l.homeHeroTag : l.homeHeroInProgress,
                color: c.mafia,
                textColor: c.mafiaSoft,
                dot: true,
              ),
              const SizedBox(height: 14),
              Text(
                s == null ? l.homeHeroTitle : l.stageTitle(s),
                style: context.type.headlineMedium,
              ),
              const SizedBox(height: 14),
              Text(
                s != null
                    ? l.playerCount(s.state.players.length)
                    : names.isEmpty
                    ? l.homeHeroEmpty
                    : l.homeHeroLastTable(names.length),
                style: context.type.bodyMedium!.copyWith(color: c.textMuted),
              ),
              if (names.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    AvatarStack(
                      names: names.take(3).toList(),
                      extra: names.length > 3 ? names.length - 3 : 0,
                      ring: cardColor,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      s == null
                          ? l.homeHeroReady(names.length)
                          : l.homeHeroAlive(s.state.alivePlayers.length),
                      style: context.type.bodySmall,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              PrimaryActionButton(
                key: Key(s == null ? 'homeNewGame' : 'homeContinue'),
                label: s == null ? l.homeStartGame : l.homeContinueAt(l.stageTitle(s)),
                tone: ActionTone.danger,
                trailing: MafiaGlyphs.arrow,
                height: Sizes.heroButton,
                radius: Radii.tile,
                onPressed: s == null ? onStart : onContinue,
              ),
              if (s != null)
                Center(
                  child: TextButton(
                    key: const Key('homeNewGame'),
                    onPressed: onStart,
                    style: TextButton.styleFrom(
                      foregroundColor: c.textMuted,
                      minimumSize: const Size(48, 44),
                    ),
                    child: Text(l.homeNewGame),
                  ),
                ),
            ],
          ),
        ),
        PositionedDirectional(
          top: -18,
          end: -14,
          child: IgnorePointer(
            child: CustomPaint(
              size: const Size.square(120),
              painter: _CrescentPainter(moon: c.text, shadow: cardColor),
            ),
          ),
        ),
      ],
    );
  }
}

/// The hero card's crescent moon: a disc with a card-colored disc over it.
class _CrescentPainter extends CustomPainter {
  _CrescentPainter({required this.moon, required this.shadow});

  final Color moon, shadow;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 120);
    canvas.saveLayer(Offset.zero & const Size.square(120), Paint());
    canvas.drawCircle(const Offset(70, 50), 34, Paint()..color = moon.withValues(alpha: 0.92));
    canvas.drawCircle(const Offset(84, 40), 32, Paint()..blendMode = BlendMode.dstOut);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CrescentPainter old) => old.moon != moon || old.shadow != shadow;
}

class _RecentGameRow extends StatelessWidget {
  const _RecentGameRow({required this.game});

  final GameSummary game;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final mafiaWon = game.winner == Team.mafia;
    final accent = mafiaWon ? c.mafia : c.civilian;
    final date = DateFormat.MMMd(Localizations.localeOf(context).toString()).format(game.playedAt);
    return GlassCard(
      radius: Radii.tile,
      padding: const EdgeInsetsDirectional.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.tint(accent, 0.16),
              borderRadius: BorderRadius.circular(Radii.iconBox),
            ),
            child: MafiaIcon(
              mafiaWon ? MafiaGlyphs.mafiaWon : MafiaGlyphs.star,
              color: mafiaWon ? c.mafiaSoft : c.civilianSoft,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mafiaWon ? l.recentMafiaWon : l.recentCiviliansWon,
                  style: context.type.bodyLarge!.copyWith(fontSize: 15),
                ),
                Text(l.recentDetail(game.nights, game.players), style: context.type.bodySmall),
              ],
            ),
          ),
          Text(date, style: context.type.bodySmall!.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}
