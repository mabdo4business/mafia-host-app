import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/describe.dart';
import '../../common/l10n.dart';
import '../../game/game_input.dart';
import '../../game/game_session.dart';
import '../../game/providers.dart';

/// Every action and outcome, night by night and day by day, for disputes.
class GameLogScreen extends ConsumerWidget {
  const GameLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final session = ref.watch(activeGameProvider).value;
    final sections = session == null ? const <_Section>[] : _sections(session);
    final describe = session == null ? null : Describer(l, session.state);

    return Scaffold(
      appBar: AppBar(title: Text(l.logTitle)),
      body: sections.isEmpty
          ? Center(child: Text(l.logEmpty))
          : ListView(
              padding: const EdgeInsetsDirectional.all(16),
              children: [
                for (final section in sections)
                  Card(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                section.night ? Icons.nightlight_round : Icons.wb_sunny_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                section.night
                                    ? l.stageNight(section.round)
                                    : l.stageDay(section.round),
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          for (final entry in section.entries)
                            for (final line in describe!.logLines(entry))
                              Padding(
                                padding: const EdgeInsetsDirectional.only(top: 4),
                                child: Text('• $line'),
                              ),
                        ],
                      ),
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
