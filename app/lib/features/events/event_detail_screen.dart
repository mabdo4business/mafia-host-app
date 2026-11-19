import 'package:intl/intl.dart' show DateFormat;
import 'package:mafia_engine/mafia_engine.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/l10n.dart';
import '../../data/game_repository.dart';
import '../../ui/ui.dart';
import '../players/player_profile_screen.dart';
import 'events_screen.dart';

/// One game night: when, who came, and the games played.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.night});

  final GameNight night;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final locale = Localizations.localeOf(context).toString();
    final times = night.games.map((g) => g.playedAt).toList()..sort();
    final time = DateFormat.jm(locale);

    return PhaseScaffold(
      glow: Glow(color: c.tint(c.mafia, 0.22)),
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
            ],
          ),
          const SizedBox(height: Space.xl),
          Overline(DateFormat.MMMMEEEEd(locale).format(night.date), color: c.mafiaSoft),
          const SizedBox(height: Space.sm),
          Text(l.eventsGameNight, style: context.type.headlineLarge),
          const SizedBox(height: Space.sm),
          Text(
            l.eventsTimeRange(time.format(times.first), time.format(times.last)),
            style: context.type.bodyMedium!.copyWith(color: c.textMuted),
          ),
          const SizedBox(height: Space.lg),
          NightResultChips(night: night),
          const SizedBox(height: 28),
          SectionTitle(l.eventsAttendees(night.players.length)),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final name in night.players)
                InkWell(
                  borderRadius: BorderRadius.circular(Radii.pill),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (_) => PlayerProfileScreen(name: name)),
                  ),
                  child: Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 12, 4),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(Radii.pill),
                      border: Border.all(color: c.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Avatar(name, size: 28),
                        const SizedBox(width: Space.sm),
                        Text(name, style: context.type.labelMedium),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          SectionTitle(l.eventsGamesPlayed),
          const SizedBox(height: Space.md),
          for (final (i, g) in night.games.reversed.indexed) ...[
            GlassCard(
              radius: Radii.tile,
              tintColor: g.winner == Team.mafia ? c.mafia : c.civilian,
              fillOpacity: 0.06,
              borderOpacity: 0.2,
              padding: const EdgeInsetsDirectional.all(14),
              child: Row(
                children: [
                  Text(
                    context.number(i + 1),
                    style: context.type.titleLarge!.copyWith(color: c.textMuted),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.winner == Team.mafia ? l.recentMafiaWon : l.recentCiviliansWon,
                          style: context.type.bodyLarge!.copyWith(fontSize: 15),
                        ),
                        Text(l.recentDetail(g.nights, g.players), style: context.type.bodySmall),
                      ],
                    ),
                  ),
                  Text(time.format(g.playedAt), style: context.type.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
          ],
        ],
      ),
    );
  }
}
