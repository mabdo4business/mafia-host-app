import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../data/game_repository.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';
import 'join_room_screen.dart';
import 'tonight_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.onSeeStats});

  /// Opens the Players tab (leaderboard).
  final VoidCallback? onSeeStats;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<void> _newGame(bool canContinue) => startNewGame(context, canContinue: canContinue);

  void _continue() => continueGame(context);

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
              TonightCard(
                session: canContinue ? active : null,
                lastNames: lastNames,
                onStart: () => _newGame(canContinue),
                onContinue: _continue,
              ),
              const SizedBox(height: 20),
              SegmentedPill<bool>(
                segments: [(false, l.modeHostOnly), (true, l.modePlayersPhones)],
                selected: false,
                onChanged: (_) => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const JoinRoomScreen()),
                ),
              ),
              const SizedBox(height: 28),
              SectionTitle(l.homeYourTable, action: l.homeSeeStats, onAction: widget.onSeeStats),
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
        ],
      ),
    );
  }

  String _greeting(BuildContext context) {
    final l = context.l10n;
    final h = ref.read(clockProvider)().hour;
    return h < 12
        ? l.homeGreetingMorning
        : h < 18
        ? l.homeGreetingAfternoon
        : l.homeGreetingEvening;
  }

  String _rate(BuildContext context, int? percent) =>
      percent == null ? context.l10n.statNone : context.l10n.percent(percent);
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
