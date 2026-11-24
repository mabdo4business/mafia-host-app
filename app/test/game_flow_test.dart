import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/game/game_flow_screen.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/providers.dart';
import 'package:mafia_host/ui/ui.dart';

import 'helpers.dart';

GameSetup smallTable({GameSettings settings = const GameSettings()}) => GameSetup(
  settings: settings,
  players: [
    p('gf', Role.godfather),
    p('doc', Role.doctor),
    p('det', Role.detective),
    p('c1', Role.civilian),
    p('c2', Role.civilian),
    p('c3', Role.civilian),
  ],
);

/// A night where nobody acts (Mafia, Doctor, Detective steps).
Future<void> quietNight(WidgetTester tester) async {
  await beginNight(tester);
  await nightPick(tester, null);
  await nightPick(tester, null);
  await nightPick(tester, null);
  await tapKey(tester, 'resolveNight');
}

void main() {
  testWidgets('a full game: night wizard → morning → vote → game over', (tester) async {
    final container = await pumpGame(tester, smallTable());
    final l = l10nOf(tester);
    expect(find.text(l.stageNight(1)), findsOneWidget);

    await tapText(tester, l.nightBegin);
    // Night 1 opens with the Mafia Team recognizing each other.
    expect(find.text(l.nightWakeTitleRecognition), findsOneWidget);
    expect(find.byKey(const Key('member_gf')), findsOneWidget);
    await tapKey(tester, 'nightNext');

    // Then the wake order: Mafia, Doctor, Detective.
    expect(find.text(l.nightWakeTitleMafia), findsOneWidget);
    expect(find.byKey(const Key('mafiaTimer')), findsOneWidget);
    expect(find.byKey(const Key('target_gf')), findsNothing, reason: 'Mafia cannot target itself');
    await nightPick(tester, 'c1');

    expect(find.text(l.nightWakeTitleDoctor), findsOneWidget);
    await nightPick(tester, 'c2');

    expect(find.text(l.nightWakeTitleDetective), findsOneWidget);
    await tapKey(tester, 'target_gf');
    await tapKey(tester, 'nightNext');
    expect(
      find.descendant(
        of: find.byKey(const Key('detectiveAnswer')),
        matching: find.text(l.resultMafia),
      ),
      findsOneWidget,
      reason: 'Q1 default: the Godfather reads as Mafia',
    );
    await tapKey(tester, 'detectiveDone');

    expect(find.text(l.nightReviewTitle), findsOneWidget);
    await tapKey(tester, 'resolveNight');

    // Morning.
    expect(find.text(l.stageMorning(1).toUpperCase()), findsOneWidget);
    expect(find.text(l.announceKilled('C1')), findsOneWidget);
    expect(find.text(l.hostOnlyDetective('GF', l.resultMafia)), findsOneWidget);
    await tapKey(tester, 'startDay');

    // Day vote: everyone votes out the Godfather, who may take one player.
    expect(find.text(l.stageDay(1).toUpperCase()), findsOneWidget);
    await castVotes(tester, {
      'gf': ['doc', 'det', 'c2'],
    });
    expect(find.byKey(const Key('choicePanel')), findsOneWidget);
    expect(find.text(l.choiceWasGodfather('GF')), findsOneWidget);
    await tapKey(tester, 'choiceConfirm'); // no one

    expect(find.text(l.winCivilians), findsWidgets);
    expect(container.read(activeGameProvider).value!.stage, GameStage.gameOver);

    // Stored as finished: nothing to continue.
    final reloaded = await tester.runAsync(
      () => container.read(gameRepositoryProvider).loadActiveGame(),
    );
    expect(reloaded, isNull);
  });

  testWidgets('the voted-out Godfather takes a player with him', (tester) async {
    final container = await pumpGame(
      tester,
      GameSetup(
        settings: const GameSettings(),
        players: [
          p('gf', Role.godfather),
          p('maf', Role.mafia),
          p('c1', Role.civilian),
          p('c2', Role.civilian),
          p('c3', Role.civilian),
          p('c4', Role.civilian),
          p('c5', Role.civilian),
        ],
      ),
    );
    final l = l10nOf(tester);
    await beginNight(tester);
    await nightPick(tester, null);
    await tapKey(tester, 'resolveNight');
    await tapKey(tester, 'startDay');
    await castVotes(tester, {
      'gf': ['c1', 'c2', 'c3'],
    });

    // The choice comes before the result; the night can't start yet.
    expect(find.byKey(const Key('startNight')), findsNothing);
    expect(find.byKey(const Key('choiceVictim_gf')), findsNothing);
    await tapKey(tester, 'choiceVictim_c4');
    expect(find.text(l.choiceTake('C4')), findsOneWidget);
    await tapKey(tester, 'choiceConfirm');

    expect(container.read(activeGameProvider).value!.state.player('c4').isAlive, isFalse);
    expect(find.text(l.announceVotedOut('GF')), findsOneWidget);
    expect(find.text('C4'), findsOneWidget, reason: 'listed under the Godfather');
    expect(find.byKey(const Key('startNight')), findsOneWidget);
  });

  testWidgets('the Doctor cannot save the same player a third night running', (tester) async {
    final container = await pumpGame(tester, smallTable());
    final l = l10nOf(tester);
    for (var night = 1; night <= 2; night++) {
      await beginNight(tester);
      await nightPick(tester, null); // Mafia: no kill
      await nightPick(tester, 'c2'); // Doctor
      await nightPick(tester, null); // Detective
      await tapKey(tester, 'resolveNight');
      await tapKey(tester, 'startDay');
      await skipVote(tester);
      await tapKey(tester, 'startNight');
    }

    expect(container.read(activeGameProvider).value!.round, 3);
    await beginNight(tester);
    await nightPick(tester, null);
    expect(find.text(l.nightDoctorTwoNights), findsOneWidget);
    await tapKey(tester, 'target_c2');
    expect(
      tester.widget<PrimaryActionButton>(find.byKey(const Key('nightNext'))).onPressed,
      isNull,
    );
  });

  testWidgets('a tie calls a re-vote between the tied; a second tie: nobody out', (tester) async {
    await pumpGame(tester, smallTable());
    final l = l10nOf(tester);
    await quietNight(tester);
    await tapKey(tester, 'startDay');

    await castVotes(tester, {
      'c1': ['gf'],
      'c2': ['doc'],
    });
    expect(find.byKey(const Key('tieCard')), findsOneWidget);
    expect(find.text(l.dayTieRevote('C1, C2')), findsOneWidget);
    expect(find.byKey(const Key('voteRow_c3')), findsNothing, reason: 'only the tied');

    await castVotes(tester, {
      'c1': ['gf'],
      'c2': ['doc'],
    });
    expect(find.text(l.announceNoElimination), findsOneWidget);
  });

  testWidgets('a second tie under hostDecides lets the host pick', (tester) async {
    await pumpGame(
      tester,
      smallTable(settings: const GameSettings(secondTieRule: SecondTieRule.hostDecides)),
    );
    final l = l10nOf(tester);
    await quietNight(tester);
    await tapKey(tester, 'startDay');
    for (var i = 0; i < 2; i++) {
      await castVotes(tester, {
        'c1': ['gf'],
        'c2': ['doc'],
      });
    }
    expect(find.text(l.dayTieHostDecides('C1, C2')), findsOneWidget);
    await tapKey(tester, 'tieBreak_c2');
    expect(find.text(l.announceVotedOut('C2')), findsOneWidget);
  });

  testWidgets('undo goes back one step', (tester) async {
    final container = await pumpGame(tester, smallTable());
    final l = l10nOf(tester);
    await beginNight(tester);
    await nightPick(tester, 'c1');
    await nightPick(tester, null);
    await nightPick(tester, null);
    await tapKey(tester, 'resolveNight');
    expect(container.read(activeGameProvider).value!.state.player('c1').isAlive, isFalse);

    await gameMenu(tester, 'undo');

    final session = container.read(activeGameProvider).value!;
    expect(session.stage, GameStage.night);
    expect(session.state.player('c1').isAlive, isTrue);
    expect(find.text(l.nightIntro), findsOneWidget);
  });

  testWidgets('a game in progress survives an app restart', (tester) async {
    final db = memoryDb();
    await pumpGame(tester, smallTable(), db: db);
    final l = l10nOf(tester);
    await beginNight(tester);
    await nightPick(tester, 'c3');
    await nightPick(tester, null);
    await nightPick(tester, null);
    await tapKey(tester, 'resolveNight');
    await tapKey(tester, 'startDay');
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));

    // A fresh container over the same database = the app restarted.
    final fresh = containerFor(db);
    addTearDown(fresh.dispose);
    final restored = await tester.runAsync(() => fresh.read(activeGameProvider.future));
    expect(restored!.stage, GameStage.day);
    expect(restored.state.player('c3').isAlive, isFalse);
    expect(restored.log, hasLength(2));

    await tester.pumpWidget(
      UncontrolledProviderScope(container: fresh, child: testApp(const GameFlowScreen())),
    );
    await tester.pumpAndSettle();
    expect(find.text(l.stageDay(1).toUpperCase()), findsOneWidget);
  });

  testWidgets('Arabic lays out right-to-left with Arabic text', (tester) async {
    await pumpGame(tester, smallTable(), locale: const Locale('ar'));
    final l = l10nOf(tester);
    expect(l.localeName, 'ar');
    expect(Directionality.of(tester.element(find.byType(Scaffold).first)), TextDirection.rtl);
    await beginNight(tester);
    expect(find.text('أيقظ المافيا'), findsOneWidget);

    // The bottom bar's first action (Back) sits on the right in RTL.
    final back = tester.getCenter(
      find.byWidgetPredicate(
        (w) => w is IconCircleButton && w.semanticLabel == l.nightPreviousStep,
      ),
    );
    final next = tester.getCenter(find.byKey(const Key('nightNext')));
    expect(back.dx, greaterThan(next.dx));
  });
}
