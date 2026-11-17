import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/common/sounds.dart';
import 'package:mafia_host/features/settings/settings_screen.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/providers.dart';

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

/// Begins the night and resolves it with no actions (Mafia + Doctor steps).
Future<void> quietNight(WidgetTester tester) async {
  await tapText(tester, l10nOf(tester).nightBegin);
  await nightPick(tester, null);
  await nightPick(tester, null);
  await tapKey(tester, 'resolveNight');
}

void main() {
  test('every sound cue is bundled as a WAV file', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final sound in GameSound.values) {
      final data = await rootBundle.load('assets/sounds/${sound.name}.wav');
      final header = String.fromCharCodes(data.buffer.asUint8List(0, 12));
      expect(header, startsWith('RIFF'), reason: sound.name);
      expect(header, endsWith('WAVE'), reason: sound.name);
      expect(data.lengthInBytes, greaterThan(44 * 1024), reason: '${sound.name} is not empty');
    }
  });

  testWidgets('night cue when the night begins, morning cue when it ends', (tester) async {
    final sounds = FakeSoundPlayer();
    await pumpGame(tester, table(), sounds: sounds);
    expect(sounds.played, isEmpty, reason: 'nothing before the host begins');

    await tapText(tester, l10nOf(tester).nightBegin);
    expect(sounds.played, [GameSound.night]);

    await nightPick(tester, null);
    await nightPick(tester, null);
    await tapKey(tester, 'resolveNight');
    expect(sounds.played, [GameSound.night, GameSound.morning]);

    // Day passes silently; the next night plays the cue again.
    await tapKey(tester, 'startDay');
    await tapKey(tester, 'skipVote');
    await tapKey(tester, 'startNight');
    expect(sounds.played, [GameSound.night, GameSound.morning]);
    await tapText(tester, l10nOf(tester).nightBegin);
    expect(sounds.played, [GameSound.night, GameSound.morning, GameSound.night]);
  });

  testWidgets('the morning cue also plays when the night ends the game', (tester) async {
    final sounds = FakeSoundPlayer();
    await pumpGame(
      tester,
      GameSetup(
        settings: const GameSettings(),
        players: [p('gf', Role.godfather), p('c1', Role.civilian), p('c2', Role.civilian)],
      ),
      sounds: sounds,
    );
    await tapText(tester, l10nOf(tester).nightBegin);
    await nightPick(tester, 'c1');
    await tapKey(tester, 'resolveNight');
    expect(find.text(l10nOf(tester).winMafia), findsWidgets);
    expect(sounds.played, [GameSound.night, GameSound.morning]);
  });

  testWidgets('undo and going back through the wizard stay silent', (tester) async {
    final sounds = FakeSoundPlayer();
    final container = await pumpGame(tester, table(), sounds: sounds);
    await quietNight(tester);
    expect(sounds.played, hasLength(2));

    await tester.runAsync(() => container.read(activeGameProvider.notifier).undo());
    await tester.pumpAndSettle();
    expect(container.read(activeGameProvider).value!.stage, GameStage.night);
    expect(sounds.played, hasLength(2), reason: 'undo is not a new night');
  });

  testWidgets('no sounds when the host turned them off', (tester) async {
    final sounds = FakeSoundPlayer();
    final container = await pumpGame(tester, table(), sounds: sounds);
    await tester.runAsync(() async {
      await container.read(preferencesProvider.future);
      await container.read(preferencesProvider.notifier).setSoundEnabled(false);
    });
    await quietNight(tester);
    expect(sounds.played, isEmpty);
  });

  testWidgets('settings toggle turns sounds off and is remembered', (tester) async {
    usePhoneSize(tester);
    final db = memoryDb();
    final container = containerFor(db);
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(preferencesProvider.future));
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: testApp(const SettingsScreen())),
    );
    await tester.pumpAndSettle();
    final l = l10nOf(tester);

    final toggle = find.widgetWithText(SwitchListTile, l.settingsSound);
    expect(tester.widget<SwitchListTile>(toggle).value, isTrue, reason: 'on by default');
    await tester.runAsync(() async {
      await tester.tap(toggle);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);

    // A fresh container over the same database = app restarted.
    final fresh = containerFor(db);
    addTearDown(fresh.dispose);
    final prefs = await tester.runAsync(() => fresh.read(preferencesProvider.future));
    expect(prefs!.soundEnabled, isFalse);
  });
}
