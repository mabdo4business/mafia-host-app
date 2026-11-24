import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/common/describe.dart';
import 'package:mafia_host/game/game_input.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('en'));
  GameSession night(List<NightAction> actions) => GameSession.start(
    1,
    GameSetup(
      settings: const GameSettings(),
      players: [
        p('gf', Role.godfather),
        p('sil', Role.silencer),
        p('det', Role.detective),
        p('shape', Role.shapeshifter),
        p('c1', Role.civilian),
        p('c2', Role.civilian),
        p('c3', Role.civilian),
      ],
    ),
  ).apply(NightInput(actions));

  test('deaths are read before silences', () {
    final s = night(const [SilencerSilence('sil', 'c2'), MafiaKill('gf', 'c1')]);
    final items = Describer(l, s.state).announcementItems(s.latestRound);
    expect([for (final i in items) i.headline], [l.announceKilled('C1'), l.announceSilenced('C2')]);
  });

  test("a check's host note names who checked when it isn't the Detective", () {
    final s = night(const [DetectiveCheck('det', 'gf'), DetectiveCheck('shape', 'c1')]);
    final describe = Describer(l, s.state);
    expect(describe.secretNotes(s.latestRound), [
      l.hostOnlyDetective('GF', l.resultMafia),
      l.hostOnlyCheckBy(describe.actor('shape'), 'C1', l.resultCivilian),
    ]);
  });
}
