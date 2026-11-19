import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

GameSetup table() => GameSetup(
  settings: const GameSettings(),
  players: [
    p('gf', Role.godfather),
    p('doc', Role.doctor),
    p('det', Role.detective),
    p('c1', Role.civilian),
    p('c2', Role.civilian),
    p('c3', Role.civilian),
  ],
);

void main() {
  testWidgets('Read aloud speaks the public announcement, never host-only notes', (tester) async {
    final narrator = FakeNarrator();
    await pumpGame(tester, table(), narrator: narrator, locale: const Locale('ar'));
    final l = l10nOf(tester);
    await tapText(tester, l.nightBegin);
    await nightPick(tester, 'c1'); // Mafia
    await nightPick(tester, null); // Doctor
    await nightPick(tester, 'gf'); // Detective (host-only result)
    await tapKey(tester, 'resolveNight');

    await tapKey(tester, 'readAloud');
    expect(narrator.read.single, [l.announceKilled('C1')]);
    expect(narrator.lastLocale, const Locale('ar'));

    // Tapping again stops; leaving the morning stops too.
    await tapKey(tester, 'readAloud');
    expect(narrator.stops, 1);
    await tapKey(tester, 'startDay');
    expect(narrator.stops, greaterThanOrEqualTo(2));
  });
}
