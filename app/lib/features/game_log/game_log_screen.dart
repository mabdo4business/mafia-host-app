import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../common/describe.dart';
import '../../common/l10n.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';
import '../../ui/ui.dart';

/// Every action and outcome as a timeline, night by night and day by day,
/// for settling disputes. Filters: All / Kills / Saves / Votes. Uses the
/// current phase's theme (pushed with it from the game).
class GameLogScreen extends ConsumerStatefulWidget {
  const GameLogScreen({super.key});

  @override
  ConsumerState<GameLogScreen> createState() => _GameLogScreenState();
}

class _GameLogScreenState extends ConsumerState<GameLogScreen> {
  LogKind? _filter;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.mafia;
    final session = ref.watch(activeGameProvider).value;
    final describe = session == null ? null : Describer(l, session.state);
    final sections = [
      if (session != null)
        for (final s in _sections(session))
          (
            section: s,
            items: [
              for (final e in s.entries)
                for (final item in describe!.logItems(e))
                  if (_filter == null || item.kind == _filter) item,
            ],
          ),
    ].where((s) => s.items.isNotEmpty).toList();

    return PhaseScaffold(
      glow: Glow(color: c.glow),
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
              Text(l.logTitle, style: context.type.headlineSmall),
            ],
          ),
          const SizedBox(height: Space.xl),
          SegmentedPill<LogKind?>(
            key: const Key('logFilter'),
            segments: [
              (null, l.logFilterAll),
              (LogKind.kill, l.logFilterKills),
              (LogKind.save, l.logFilterSaves),
              (LogKind.vote, l.logFilterVotes),
            ],
            selected: _filter,
            onChanged: (f) => setState(() => _filter = f),
          ),
          const SizedBox(height: Space.xl),
          if (sections.isEmpty)
            Text(
              session == null || session.log.isEmpty ? l.logEmpty : l.logNothingHere,
              style: context.type.bodyMedium!.copyWith(color: c.textMuted),
            ),
          for (final (:section, :items) in sections) ...[
            Row(
              children: [
                MafiaIcon(
                  section.night ? MafiaGlyphs.moon : MafiaGlyphs.sun,
                  size: 18,
                  color: section.night
                      ? celestialColor(MafiaColors.night)
                      : MafiaColors.day.primaryCta,
                ),
                const SizedBox(width: Space.sm),
                Text(
                  section.night ? l.stageNight(section.round) : l.stageDay(section.round),
                  style: context.type.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: Space.md),
            for (final (i, item) in items.indexed)
              _TimelineEntry(item: item, last: i == items.length - 1),
            const SizedBox(height: Space.xl),
          ],
        ],
      ),
    );
  }
}

/// An icon on the timeline's line, then the text.
class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.item, required this.last});

  final LogItem item;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final c = context.mafia;
    final (glyph, color) = switch (item.kind) {
      LogKind.kill => (MafiaGlyphs.skull, c.mafia),
      LogKind.save => (MafiaGlyphs.shield, c.saved),
      LogKind.vote => (MafiaGlyphs.vote, c.primaryCta),
      LogKind.other => (MafiaGlyphs.sparkle, c.textMuted),
    };
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: c.tint(color, 0.16),
                    borderRadius: BorderRadius.circular(Radii.chip),
                  ),
                  child: MafiaIcon(glyph, size: 16, color: color),
                ),
                if (!last) Expanded(child: Container(width: 1, color: c.surfaceBorder)),
              ],
            ),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(top: 6, bottom: Space.md),
              child: Text(item.text, style: context.type.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section {
  _Section(this.round, this.night);
  final int round;
  final bool night;
  final List<LogEntry> entries = [];
}

List<_Section> _sections(GameSession session) {
  final sections = <_Section>[];
  for (final entry in session.log) {
    if (entry.input is AdvanceInput) continue;
    final night = entry.stage == GameStage.night || entry.stage == GameStage.morning;
    final last = sections.lastOrNull;
    if (last == null || last.round != entry.round || last.night != night) {
      sections.add(_Section(entry.round, night));
    }
    sections.last.entries.add(entry);
  }
  return sections;
}
