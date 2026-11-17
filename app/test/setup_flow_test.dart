import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/features/setup/deal_screen.dart';
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

    // Too much Mafia is caught.
    await tapKey(tester, 'increment_mafia');
    await tapKey(tester, 'increment_mafia');
    expect(find.text(l.setupProblemMafiaTooStrong), findsOneWidget);
    expect(container.read(setupDraftProvider).customMix, isTrue);

    await tapText(tester, l.setupSuggestedMix);
    expect(container.read(setupDraftProvider).problem, isNull);
  });

  testWidgets('deal: Chameleon must pick a role before the game starts', (tester) async {
    usePhoneSize(tester);
    final container = containerFor(memoryDb());
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(activeGameProvider.future));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testApp(
          DealScreen(
            names: const ['A', 'B', 'C', 'D', 'E'],
            mix: const {Role.godfather: 1, Role.chameleon: 1},
            settings: const GameSettings(),
            discussionSeconds: 0,
            random: Random(7),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l = l10nOf(tester);

    await reveal(tester, find.text(l.dealChameleonMissing));
    expect(find.text(l.dealChameleonMissing), findsOneWidget);
    final start = find.widgetWithText(FilledButton, l.dealStartGame);
    expect(tester.widget<FilledButton>(start).onPressed, isNull);

    final pick = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('chameleonPick_'),
    );
    await tester.ensureVisible(pick);
    await tester.tap(pick);
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.roleDoctor).last);
    await tester.pumpAndSettle();

    expect(find.text(l.dealChameleonMissing), findsNothing);
    await tester.runAsync(() async {
      await tester.tap(start);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final session = container.read(activeGameProvider).value!;
    expect(session.stage, GameStage.night);
    final chameleon = session.state.players.singleWhere((p) => p.role == Role.chameleon);
    expect(chameleon.effectiveRole, Role.doctor);
    expect(find.text(l.nightIntro), findsOneWidget);
  });
}
