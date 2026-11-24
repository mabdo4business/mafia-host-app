import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/features/setup/players_sheet.dart';
import 'package:mafia_host/features/setup/reveal_screen.dart';
import 'package:mafia_host/features/setup/setup_screen.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/providers.dart';

import 'helpers.dart';

void main() {
  testWidgets('setup: players, suggested mix and validation', (tester) async {
    usePhoneSize(tester);
    final container = containerFor(memoryDb());
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: testApp(const SetupScreen())),
    );
    await tester.pumpAndSettle();
    final l = l10nOf(tester);

    await tapKey(tester, 'editPlayers');
    Future<void> add(String name) async {
      await tester.enterText(find.byKey(const Key('playerNameField')), name);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    await add('Ahmed');
    await add('Sara');
    await add('Omar');
    expect(find.text(l.setupProblemTooFewPlayers(4)), findsOneWidget);

    await add('sara'); // duplicate (case-insensitive) is refused
    expect(container.read(setupDraftProvider).names, ['Ahmed', 'Sara', 'Omar']);

    await add('Laila');
    await add('Youssef');
    final draft = container.read(setupDraftProvider);
    expect(draft.problem, isNull);
    expect(draft.countOf(Role.godfather), 1);
    expect(find.text(l.setupProblemTooFewPlayers(4)), findsNothing);

    // Close the players sheet.
    Navigator.of(tester.element(find.byType(PlayersSheet))).pop();
    await tester.pumpAndSettle();

    // Too much Mafia is caught (tap a role chip = one more).
    await tapKey(tester, 'roleChip_mafia');
    await tapKey(tester, 'roleChip_mafia');
    expect(find.text(l.setupProblemMafiaTooStrong), findsOneWidget);
    expect(container.read(setupDraftProvider).customMix, isTrue);

    await tapText(tester, l.setupAutoBalance);
    expect(container.read(setupDraftProvider).problem, isNull);
  });

  testWidgets('reveal: each player sees their card, in seat order', (tester) async {
    usePhoneSize(tester);
    final container = containerFor(memoryDb());
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(activeGameProvider.future));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testApp(
          RevealScreen(
            names: const ['A', 'B', 'C', 'D', 'E'],
            mix: const {Role.godfather: 1, Role.chameleon: 1},
            settings: const GameSettings(),
            random: Random(7),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l = l10nOf(tester);

    for (final name in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.text(name), findsOneWidget);
      // Nothing to pass on until the card is turned.
      expect(find.byKey(const Key('revealNext')), findsNothing);
      await tapKey(tester, 'roleCard');
      if (name == 'E') {
        await tester.runAsync(() async {
          await tester.tap(find.byKey(const Key('revealNext')));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        });
        await tester.pumpAndSettle();
      } else {
        await tapKey(tester, 'revealNext');
      }
    }

    final session = container.read(activeGameProvider).value!;
    expect(session.stage, GameStage.night);
    expect(session.state.players.map((p) => p.name), ['A', 'B', 'C', 'D', 'E']);
    final chameleon = session.state.players.singleWhere((p) => p.role == Role.chameleon);
    expect(chameleon.chameleonRole, isNull, reason: 'chooses on night 3');
    expect(find.text(l.nightIntro), findsOneWidget);
  });
}
