import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/common/describe.dart';
import 'package:mafia_host/common/speech.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/l10n/app_localizations.dart';
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

/// Godfather kills C1, the Doctor passes, the Detective checks GF.
Future<void> nightWithCheck(WidgetTester tester) async {
  await beginNight(tester);
  await nightPick(tester, 'c1');
  await nightPick(tester, null);
  await nightPick(tester, 'gf');
  await tapKey(tester, 'resolveNight');
}

void main() {
  group('spoken text', () {
    final l = lookupAppLocalizations(const Locale('en'));
    final describe = Describer(l, GameState.initial(players: table().players));

    test('reads headlines only; host notes stay silent', () {
      final text = describe.spokenText([
        Announcement(
          AnnouncementType.death,
          l.announceKilled('Yousef'),
          detail: l.announceRoleSecret,
        ),
        Announcement(AnnouncementType.save, l.announceSomeoneSaved, detail: l.announceDontSayWho),
      ]);
      expect(text, '${l.announceKilled('Yousef')}\n${l.announceSomeoneSaved}');
    });

    test("a Bomb's victims are read with their lead-in", () {
      final text = describe.spokenText([
        Announcement(
          AnnouncementType.bomb,
          l.announceWasBomb(l.announceKilled('Faisal')),
          detail: l.announceBombTakes(2),
          chips: const ['Huda', 'Ali'],
        ),
      ]);
      expect(
        text,
        '${l.announceWasBomb(l.announceKilled('Faisal'))} ${l.announceBombTakes(2)} '
        '${['Huda', 'Ali'].join(l.listSeparator)}.',
      );
    });
  });

  testWidgets('Morning reads the announcement aloud, never the Detective note', (tester) async {
    final speaker = RecordingSpeaker();
    await pumpGame(tester, table(), speaker: speaker);
    await nightWithCheck(tester);
    final l = l10nOf(tester);

    await tapKey(tester, 'readAloud');
    expect(speaker.spoken, hasLength(1));
    final (text, locale) = speaker.spoken.single;
    expect(text, l.announceKilled('C1'));
    expect(text, isNot(contains('GF')), reason: 'the Detective check is host-only');
    expect(locale, const Locale('en'));

    // While speaking the button stops instead.
    expect(find.bySemanticsLabel(l.stopReading), findsOneWidget);
    await tapKey(tester, 'readAloud');
    expect(speaker.speaking.value, isFalse);
    expect(find.bySemanticsLabel(l.readAloud), findsOneWidget);

    // Moving on cuts the voice off.
    await tapKey(tester, 'readAloud');
    expect(speaker.speaking.value, isTrue);
    await tapKey(tester, 'startDay');
    expect(speaker.speaking.value, isFalse);
  });

  testWidgets('speaks in the app language', (tester) async {
    final speaker = RecordingSpeaker();
    await pumpGame(tester, table(), speaker: speaker, locale: const Locale('ar'));
    await nightWithCheck(tester);

    await tapKey(tester, 'readAloud');
    expect(speaker.spoken.single.$2, const Locale('ar'));
    expect(speaker.spoken.single.$1, l10nOf(tester).announceKilled('C1'));
  });

  test('iOS: plays through the silent switch and ducks music', () {
    expect(ttsIosCategory, IosTextToSpeechAudioCategory.playback, reason: 'ignores silent switch');
    expect(ttsIosOptions, [
      IosTextToSpeechAudioCategoryOptions.duckOthers,
    ], reason: 'music dips, keeps playing');
  });

  test('TTS language tags carry a region (iOS needs one)', () {
    expect(ttsLanguage(const Locale('ar')), 'ar-SA');
    expect(ttsLanguage(const Locale('en')), 'en-US');
  });
}
