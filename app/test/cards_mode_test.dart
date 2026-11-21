import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/features/setup/assign_cards_screen.dart';
import 'package:mafia_host/features/setup/setup_screen.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/providers.dart';
import 'package:mafia_host/common/l10n.dart';
import 'package:mafia_host/game/role_mix.dart';
import 'package:mafia_host/ui/ui.dart';
import 'package:material_ui/material_ui.dart';

import 'helpers.dart';

void main() {
  group('cards mode helpers', () {
    test('wake order: Mafia team first, only roles in the mix, no Civilians', () {
      expect(
        cardWakeOrder({
          Role.joker: 1,
          Role.doctor: 1,
          Role.mafia: 2,
          Role.godfather: 1,
          Role.lawyer: 0,
          Role.chameleon: 1,
        }),
        [Role.godfather, Role.mafia, Role.doctor, Role.joker, Role.chameleon],
      );
    });

    test('players from cards: unrecorded seats are Civilians; ids follow seats', () {
      final players = playersFromCards(
        [' A ', 'B', 'C', 'D'],
        {1: Role.godfather, 3: Role.chameleon},
        chameleonPicks: {3: Role.doctor, 0: Role.detective},
      );
      expect([for (final p in players) p.id], ['p0', 'p1', 'p2', 'p3']);
      expect(players[0].name, 'A');
      expect([for (final p in players) p.role], [
        Role.civilian,
        Role.godfather,
        Role.civilian,
        Role.chameleon,
      ]);
      expect(players[3].effectiveRole, Role.doctor);
      expect(players[0].chameleonRole, isNull); // a pick only sticks to a Chameleon card
    });
  });

  testWidgets('setup remembers the mode and opens the card screen', (tester) async {
    usePhoneSize(tester);
    final container = containerFor(memoryDb());
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(preferencesProvider.future));
    final controller = container.read(setupDraftProvider.notifier);
    for (final n in ['A', 'B', 'C', 'D', 'E']) {
      controller.addPlayer(n);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: testApp(const SetupScreen())),
    );
    await tester.pumpAndSettle();
    final l = l10nOf(tester);

    await tester.scrollUntilVisible(find.text(l.setupModeCards), 200);
    await tapText(tester, l.setupModeCards);
    expect(container.read(setupDraftProvider).cardsMode, isTrue);
    expect(container.read(preferencesProvider).value!.cardsMode, isTrue);
    expect(find.text(l.setupCardsDealt), findsOneWidget);

    await tapKey(tester, 'dealRoles');
    expect(find.byType(AssignCardsScreen), findsOneWidget);
  });

  testWidgets('host taps who holds each card, checks, and night 1 starts', (tester) async {
    usePhoneSize(tester);
    final container = containerFor(memoryDb());
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(activeGameProvider.future));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testApp(
          const AssignCardsScreen(
            names: ['A', 'B', 'C', 'D', 'E', 'F'],
            mix: {Role.mafia: 2, Role.doctor: 1, Role.chameleon: 1},
            settings: GameSettings(),
            discussionSeconds: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final l = l10nOf(tester);
    bool nextEnabled() =>
        tester.widget<PrimaryActionButton>(find.byKey(const Key('cardsNext'))).onPressed != null;

    // Mafia: two cards. Next waits for both; a third tap is ignored.
    expect(find.text(l.cardsWake(l.roleMafia)), findsOneWidget);
    await tapKey(tester, 'cardSeat_1');
    expect(nextEnabled(), isFalse);
    await tapKey(tester, 'cardSeat_4');
    await tapKey(tester, 'cardSeat_5');
    expect(find.text(l.cardsPicked(2, 2)), findsOneWidget);
    await tapKey(tester, 'cardSeat_4'); // untap
    await tapKey(tester, 'cardSeat_2');
    await tapKey(tester, 'cardsNext');

    // Doctor: Mafia holders can't be picked; a single card moves on retap.
    await tapKey(tester, 'cardSeat_1');
    expect(nextEnabled(), isFalse);
    await tapKey(tester, 'cardSeat_0');
    await tapKey(tester, 'cardSeat_3');
    await tapKey(tester, 'cardsNext');

    // Chameleon picks the role they play.
    await tapKey(tester, 'cardSeat_5');
    await tapKey(tester, 'cardsNext');
    await tapKey(tester, 'chameleonPick_detective');
    await tapKey(tester, 'chameleonConfirm');

    expect(find.text(l.cardsReviewTitle), findsOneWidget);
    expect(find.text(l.names(['A', 'E'])), findsOneWidget); // the Civilians
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('cardsStart')));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    final session = container.read(activeGameProvider).value!;
    expect(session.stage, GameStage.night);
    final roles = {for (final p in session.state.players) p.name: p.effectiveRole};
    expect(roles, {
      'A': Role.civilian,
      'B': Role.mafia,
      'C': Role.mafia,
      'D': Role.doctor,
      'E': Role.civilian,
      'F': Role.detective,
    });
    expect(find.text(l.nightIntro), findsOneWidget);
  });
}
