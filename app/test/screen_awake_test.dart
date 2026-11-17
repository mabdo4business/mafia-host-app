import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/game/game_session.dart';

import 'helpers.dart';

GameSetup table() => GameSetup(
  settings: const GameSettings(),
  players: [
    p('gf', Role.godfather),
    p('doc', Role.doctor),
    p('c1', Role.civilian),
    p('c2', Role.civilian),
    p('c3', Role.civilian),
  ],
);

/// Plays a night with no actions (Mafia + Doctor steps).
Future<void> quietNight(WidgetTester tester) async {
  await tapText(tester, l10nOf(tester).nightBegin);
  await nightPick(tester, null);
  await nightPick(tester, null);
  await tapKey(tester, 'resolveNight');
}

void main() {
  testWidgets('screen stays on during the night only', (tester) async {
    final awake = FakeScreenAwake();
    await pumpGame(tester, table(), screenAwake: awake);
    expect(awake.isOn, isTrue, reason: 'night 1');

    await quietNight(tester);
    expect(awake.isOn, isFalse, reason: 'morning');

    await tapKey(tester, 'startDay');
    expect(awake.isOn, isFalse, reason: 'day');

    await tapKey(tester, 'skipVote');
    await tapKey(tester, 'startNight');
    expect(awake.isOn, isTrue, reason: 'night 2');

    // Leaving the game screen (back to home) releases it.
    await tester.pumpWidget(const SizedBox());
    expect(awake.isOn, isFalse, reason: 'left the game');
    expect(awake.calls, [true, false, true, false], reason: 'no redundant calls');
  });

  testWidgets('screen is released when the night ends the game', (tester) async {
    final awake = FakeScreenAwake();
    await pumpGame(
      tester,
      GameSetup(
        settings: const GameSettings(),
        players: [p('gf', Role.godfather), p('c1', Role.civilian), p('c2', Role.civilian)],
      ),
      screenAwake: awake,
    );
    expect(awake.isOn, isTrue);

    await tapText(tester, l10nOf(tester).nightBegin);
    await nightPick(tester, 'c1');
    await tapKey(tester, 'resolveNight');
    expect(find.text(l10nOf(tester).winMafia), findsWidgets);
    expect(awake.isOn, isFalse);
  });
}
