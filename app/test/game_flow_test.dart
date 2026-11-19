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

void main() {
  testWidgets('a full game: night wizard → morning → vote → game over', (tester) async {
    final container = await pumpGame(tester, smallTable());
    final l = l10nOf(tester);
    expect(find.text(l.stageNight(1)), findsOneWidget);

    await tapText(tester, l.nightBegin);
    // Steps in resolution order: Mafia, Doctor, Detective.
    expect(find.text(l.nightWakeTitleMafia), findsOneWidget);
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
        matching: find.text(l.resultCivilian),
      ),
      findsOneWidget,
      reason: 'the Godfather reads as Civilian',
    );
    await tapKey(tester, 'detectiveDone');

    expect(find.text(l.nightReviewTitle), findsOneWidget);
    await tapKey(tester, 'resolveNight');

    // Morning.
    expect(find.text(l.stageMorning(1).toUpperCase()), findsOneWidget);
    expect(find.text(l.announceKilled('C1')), findsOneWidget);
    expect(find.text(l.hostOnlyDetective('GF', l.resultCivilian)), findsOneWidget);
    await tapKey(tester, 'startDay');

    // Day vote: everyone votes out the Godfather.
    expect(find.text(l.stageDay(1).toUpperCase()), findsOneWidget);
    await castVotes(tester, {
      'gf': ['doc', 'det', 'c2'],
    });

    expect(find.text(l.winCivilians), findsWidgets);
    expect(container.read(activeGameProvider).value!.stage, GameStage.gameOver);

    // Stored as finished: nothing to continue.
    final reloaded = await tester.runAsync(
      () => container.read(gameRepositoryProvider).loadActiveGame(),
    );
    expect(reloaded, isNull);
  });

  testWidgets('the Doctor cannot pick last night\'s player', (tester) async {
    final container = await pumpGame(tester, smallTable());
    final l = l10nOf(tester);
    await tapText(tester, l.nightBegin);
    await nightPick(tester, null); // Mafia: no kill
    await nightPick(tester, 'c2'); // Doctor
    await nightPick(tester, null); // Detective
    await tapKey(tester, 'resolveNight');
    expect(find.text(l.announceNobodyDied), findsOneWidget);
    await tapKey(tester, 'startDay');
    await skipVote(tester);
    await tapKey(tester, 'startNight');

    expect(container.read(activeGameProvider).value!.round, 2);
    await tapText(tester, l.nightBegin);
    await nightPick(tester, null);
    expect(find.text(l.nightDoctorLastNight), findsOneWidget);
    await tapKey(tester, 'target_c2');
    expect(find.byKey(const Key('nightNext')).hitTestable(), findsOneWidget);
    expect(
      tester.widget<PrimaryActionButton>(find.byKey(const Key('nightNext'))).onPressed,
      isNull,
    );
  });

  testWidgets('the Bomb picks its victims before the day starts', (tester) async {
    final container = await pumpGame(
      tester,
      GameSetup(
        settings: const GameSettings(),
        players: [
          p('gf', Role.godfather),
          p('maf', Role.mafia),
          p('bomb', Role.bomb),
          p('c1', Role.civilian),
          p('c2', Role.civilian),
          p('c3', Role.civilian),
          p('c4', Role.civilian),
        ],
      ),
    );
    final l = l10nOf(tester);
    await tapText(tester, l.nightBegin);
    await nightPick(tester, 'bomb');
    await tapKey(tester, 'resolveNight');

    // The Bomb picks before anything else; the day can't start yet.
    expect(find.byKey(const Key('bombPanel')), findsOneWidget);
    expect(find.text(l.bombWasTheBomb('BOMB')), findsOneWidget);
    expect(find.byKey(const Key('startDay')), findsNothing);

    await tapKey(tester, 'bombVictim_gf');
    await tapKey(tester, 'bombVictim_maf');
    await tapKey(tester, 'detonate');

    // Both Mafia gone → Civilians win.
    expect(container.read(activeGameProvider).value!.state.winner, Team.civilians);
    expect(find.text(l.winCivilians), findsWidgets);
  });

  testWidgets('a tie lets the host decide', (tester) async {
    await pumpGame(tester, smallTable());
    final l = l10nOf(tester);
    await tapText(tester, l.nightBegin);
    await nightPick(tester, null);
    await nightPick(tester, null);
    await nightPick(tester, null);
    await tapKey(tester, 'resolveNight');
    await tapKey(tester, 'startDay');

    await castVotes(tester, {
      'c1': ['gf'],
      'c2': ['doc'],
    });
    expect(find.byKey(const Key('tieCard')), findsOneWidget);
    expect(find.text(l.dayTieHostDecides('C1, C2')), findsOneWidget);

    await tapKey(tester, 'tieBreak_c2');
    expect(find.text(l.announceVotedOut('C2')), findsOneWidget);
  });

  testWidgets('undo goes back one step', (tester) async {
    final container = await pumpGame(tester, smallTable());
    final l = l10nOf(tester);
    await tapText(tester, l.nightBegin);
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
    await tapText(tester, l.nightBegin);
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
    await tapText(tester, l.nightBegin);
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
