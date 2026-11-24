import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/features/setup/setup_screen.dart';
import 'package:mafia_host/game/game_input.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/providers.dart';
import 'package:mafia_host/ui/ui.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

/// GAME_RULES roles in seat order. TNT sits between c1 and c2.
GameSetup guideTable({GameSettings settings = const GameSettings()}) => GameSetup(
  settings: settings,
  players: [
    p('gf', Role.godfather),
    p('witch', Role.witch),
    p('sil', Role.silencer),
    p('sw', Role.switchman),
    p('bomb', Role.bomb),
    p('shape', Role.shapeshifter),
    p('cham', Role.chameleon),
    p('c1', Role.civilian),
    p('tnt', Role.tnt),
    p('c2', Role.civilian),
    p('c3', Role.civilian),
  ],
);

Future<ProviderContainer> pumpAt(WidgetTester tester, List<GameInput> inputs) async {
  final container = await pumpGame(tester, guideTable());
  await tester.runAsync(() async {
    final game = container.read(activeGameProvider.notifier);
    for (final i in inputs) {
      await game.apply(i);
    }
  });
  await tester.pumpAndSettle();
  return container;
}

/// Quiet nights and days until night [n].
List<GameInput> untilNight(int n) => [
  for (var i = 1; i < n; i++) ...const [
    NightInput([]),
    AdvanceInput(),
    TallyVoteInput({}),
    AdvanceInput(),
  ],
];

GameSession sessionOf(ProviderContainer c) => c.read(activeGameProvider).value!;

void main() {
  group('day phase', () {
    testWidgets('Free Chat → speeches in seat order (silenced skipped) → vote', (tester) async {
      final container = await pumpAt(tester, const [
        NightInput([SilencerSilence('sil', 'witch')]),
      ]);
      final l = l10nOf(tester);
      expect(find.text(l.announceSilenced('WITCH')), findsOneWidget);
      await tapKey(tester, 'startDay');

      // Free Chat with its 2:00 timer; the silenced player is named.
      expect(find.byKey(const Key('freeChatTimer')), findsOneWidget);
      expect(find.text('2:00'), findsOneWidget);
      expect(find.text(l.daySilencedToday('WITCH')), findsOneWidget);
      await tapKey(tester, 'startSpeeches');

      // Speeches start at seat 1; the Witch (silenced) has no turn.
      expect(find.text(l.daySpeechCounter(1, 10).toUpperCase()), findsOneWidget);
      expect(find.byKey(const Key('speaker_witch')), findsNothing);
      expect(find.text('0:30'), findsOneWidget);
      await tapKey(tester, 'nextSpeaker');
      expect(find.text(l.daySpeechCounter(2, 10).toUpperCase()), findsOneWidget);

      // A Foul: an extra 15 s speech, counted for the player.
      await tapKey(tester, 'takeFoul');
      expect(sessionOf(container).state.foulsOf('sil'), 1);
      expect(find.text(l.statusFouls(1)), findsWidgets);
      expect(find.text('0:15'), findsOneWidget);
      expect(
        find.text(l.daySpeechCounter(2, 10).toUpperCase()),
        findsOneWidget,
        reason: 'still their turn',
      );

      // Through to the vote; the silenced player can't vote.
      await tapKey(tester, 'speaker_c3');
      await tapKey(tester, 'startVoting');
      expect(find.text('0${l.dayOfVoters(10)}', findRichText: true), findsOneWidget);
      expect(find.text(l.daySilencedNoVote('WITCH')), findsOneWidget);
    });

    testWidgets('the host removes a player from the table', (tester) async {
      final container = await pumpAt(tester, const [NightInput([]), AdvanceInput()]);
      final l = l10nOf(tester);
      await gameMenu(tester, 'remove');
      await tapKey(tester, 'remove_tnt');
      expect(find.text(l.removePlayerConfirmTitle('TNT')), findsOneWidget);
      await tapText(tester, l.removePlayerConfirm);

      final state = sessionOf(container).state;
      expect(
        [
          for (final p in state.players)
            if (!p.isAlive) p.id,
        ],
        ['c1', 'tnt', 'c2'],
      );
      expect(sessionOf(container).stage, GameStage.day);
    });
  });

  group('night steps', () {
    testWidgets('night 2: the Witch links two players, the Bomb plants on two', (tester) async {
      final container = await pumpAt(tester, untilNight(2));
      final l = l10nOf(tester);
      await beginNight(tester);
      await nightPick(tester, null); // Mafia

      expect(find.text(l.nightWakeTitleWitch), findsOneWidget);
      expect(find.byKey(const Key('target_gf')), findsNothing, reason: 'Civilians only (Q12)');
      await tapKey(tester, 'target_c1');
      expect(
        tester.widget<PrimaryActionButton>(find.byKey(const Key('nightNext'))).onPressed,
        isNull,
        reason: 'needs two',
      );
      await tapKey(tester, 'target_c2');
      expect(find.text(l.actionLink('C1', 'C2')), findsOneWidget);
      await tapKey(tester, 'nightNext');

      await nightPick(tester, null); // Silencer
      await nightPick(tester, null); // Shapeshifter (Doctor tonight)
      expect(find.text(l.nightWakeTitleBomb), findsOneWidget);
      await tapKey(tester, 'target_c3');
      await tapKey(tester, 'target_tnt');
      await tapKey(tester, 'nightNext');
      await tapKey(tester, 'resolveNight');

      final state = sessionOf(container).state;
      expect(state.witchLink, ('c1', 'c2'));
      expect(state.bombPlants['bomb'], ['tnt', 'c3']);
    });

    testWidgets('a shot Switchman is woken to send the bullet on', (tester) async {
      final container = await pumpGame(tester, guideTable());
      final l = l10nOf(tester);
      await beginNight(tester);
      await nightPick(tester, 'sw'); // Mafia
      await nightPick(tester, null); // Silencer
      await nightPick(tester, null); // Shapeshifter (Detective tonight)

      expect(find.text(l.nightWakeTitleSwitchman), findsOneWidget);
      expect(find.text(l.quoted(l.nightLineSwitchman)), findsOneWidget);
      await nightPick(tester, 'gf');
      await tapKey(tester, 'resolveNight');

      final state = sessionOf(container).state;
      expect(state.player('sw').isAlive, isTrue);
      expect(state.player('gf').isAlive, isFalse);
    });

    testWidgets('the Shapeshifter is woken with tonight\'s role', (tester) async {
      await pumpAt(tester, untilNight(3));
      final l = l10nOf(tester);
      await beginNight(tester);
      await nightPick(tester, null); // Mafia
      await nightPick(tester, null); // Silencer
      expect(find.text(l.quoted(l.nightLineShapeshifter(l.roleJoker))), findsOneWidget);
    });

    testWidgets('night 3: the Chameleon chooses a role for the rest of the game', (tester) async {
      final container = await pumpAt(tester, untilNight(3));
      final l = l10nOf(tester);
      await beginNight(tester);
      await nightPick(tester, null); // Mafia
      await nightPick(tester, null); // Silencer
      await nightPick(tester, null); // Shapeshifter

      expect(find.text(l.quoted(l.nightLineChameleonChoose)), findsOneWidget);
      for (final r in chameleonChoices) {
        expect(find.byKey(Key('chameleonPick_${r.name}')), findsOneWidget);
      }
      await tapKey(tester, 'chameleonPick_doctor');
      expect(find.text(l.chameleonBecome(l.roleDoctor)), findsOneWidget);
      await tapKey(tester, 'nightNext');
      await tapKey(tester, 'resolveNight');
      expect(sessionOf(container).state.player('cham').chameleonRole, Role.doctor);
    });

    testWidgets('night 1 has no Putana step; from night 2 she blocks', (tester) async {
      await pumpGame(
        tester,
        GameSetup(
          settings: const GameSettings(),
          players: [
            p('gf', Role.godfather),
            p('put', Role.putana),
            p('c1', Role.civilian),
            p('c2', Role.civilian),
            p('c3', Role.civilian),
            p('c4', Role.civilian),
          ],
        ),
      );
      final l = l10nOf(tester);
      await tapText(tester, l.nightBegin);
      expect(find.byKey(const Key('member_put')), findsOneWidget, reason: 'recognizes the team');
      await tapKey(tester, 'nightNext');
      expect(find.text(l.nightWakeTitlePutana), findsNothing);
      expect(find.text(l.nightWakeTitleMafia), findsOneWidget);
    });
  });

  group('setup', () {
    testWidgets('seat order, timers and every house rule are set up front', (tester) async {
      usePhoneSize(tester);
      final container = containerFor(memoryDb());
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: testApp(const SetupScreen())),
      );
      await tester.pumpAndSettle();
      final l = l10nOf(tester);

      expect(find.byKey(const Key('seatOrderHint')), findsOneWidget);
      for (final r in [Role.witch, Role.switchman, Role.silencer, Role.shapeshifter, Role.tnt]) {
        await reveal(tester, find.byKey(Key('roleChip_${r.name}')));
      }

      await reveal(tester, find.byKey(const Key('speechTimer')));
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('speechTimer')),
          matching: find.text(l.secondsShort(45)),
        ),
      );
      await tester.pumpAndSettle();
      expect(container.read(setupDraftProvider).settings.speechSeconds, 45);

      await tapText(tester, l.setupHouseRules);
      await tapKey(tester, 'rule_witchCiviliansOnly');
      expect(container.read(setupDraftProvider).settings.witchCiviliansOnly, isFalse);
      await reveal(tester, find.byKey(const Key('rule_secondTieRule')));
      await tapText(tester, l.tieRandom);
      expect(
        container.read(setupDraftProvider).settings.secondTieRule,
        SecondTieRule.randomAmongTied,
      );
    });
  });
}
