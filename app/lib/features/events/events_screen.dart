import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../data/game_repository.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';
import '../home/tonight_card.dart';
import 'event_detail_screen.dart';

/// Game nights: tonight's table, then every past night with its results.
class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.mafia;
    final active = ref.watch(activeGameProvider).value;
    final canContinue = active != null && active.stage != GameStage.gameOver;
    final nights = ref.watch(gameNightsProvider).value ?? const [];
    final lastNames = ref.watch(lastPlayerNamesProvider).value ?? const [];

    return PhaseScaffold(
      glow: Glow(color: MafiaColors.night.glow, start: -100, end: null, top: -160, size: 420),
      body: ListView(
        padding: const EdgeInsetsDirectional.fromSTEB(Space.page, Space.sm, Space.page, 120),
        children: [
          Text(l.eventsTitle, style: context.type.headlineLarge),
          const SizedBox(height: Space.xl),
          TonightCard(
            session: canContinue ? active : null,
            lastNames: lastNames,
            onStart: () => startNewGame(context, canContinue: canContinue),
            onContinue: () => continueGame(context),
          ),
          const SizedBox(height: 28),
          SectionTitle(l.eventsPast),
          const SizedBox(height: Space.md),
          if (nights.isEmpty)
            Text(l.eventsEmpty, style: context.type.bodySmall)
          else
            for (final n in nights) ...[_NightRow(night: n), const SizedBox(height: 10)],
          const SizedBox(height: Space.lg),
          Text(l.eventsPlanningSoon, style: context.type.bodySmall!.copyWith(color: c.textMuted)),
        ],
      ),
    );
  }
}

/// Results of a night as small team chips: "Mafia 1", "Civilians 2".
class NightResultChips extends StatelessWidget {
  const NightResultChips({super.key, required this.night});

  final GameNight night;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final mafia = night.games.where((g) => g.winner == Team.mafia).length;
    final civ = night.games.where((g) => g.winner == Team.civilians).length;
    Widget chip(Color color, Color text, String label) => Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: Space.xs),
      decoration: BoxDecoration(
        color: c.tint(color, 0.14),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(label, style: context.type.labelSmall!.copyWith(color: text, letterSpacing: 0)),
    );
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (mafia > 0) chip(c.mafia, c.mafiaSoft, l.teamCount(l.teamMafia, context.number(mafia))),
        if (civ > 0)
          chip(c.civilian, c.civilianSoft, l.teamCount(l.teamCivilians, context.number(civ))),
      ],
    );
  }
}

class _NightRow extends StatelessWidget {
  const _NightRow({required this.night});

  final GameNight night;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final locale = Localizations.localeOf(context).toString();
    return GlassCard(
      radius: Radii.tile,
      padding: const EdgeInsetsDirectional.all(14),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => EventDetailScreen(night: night)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.veil(0.06),
              borderRadius: BorderRadius.circular(Radii.iconBox),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.MMM(locale).format(night.date).toUpperCase(),
                  style: context.type.labelSmall!.copyWith(
                    fontSize: TextSizes.tag,
                    color: c.mafiaSoft,
                  ),
                ),
                Text(
                  DateFormat.d(locale).format(night.date),
                  style: context.type.titleLarge!.copyWith(height: 1.1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.EEEE(locale).format(night.date),
                  style: context.type.bodyLarge!.copyWith(fontSize: TextSizes.row),
                ),
                Text(
                  l.eventsNightDetail(night.games.length, night.players.length),
                  style: context.type.bodySmall,
                ),
                const SizedBox(height: 6),
                NightResultChips(night: night),
              ],
            ),
          ),
          MafiaIcon(MafiaGlyphs.forward, size: 18, color: c.textMuted),
        ],
      ),
    );
  }
}
