// On-device test: real SQLite, real screen wake lock, real audio.
// Run: flutter test integration_test -d <simulator or device id>
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mafia_host/app.dart';
import 'package:mafia_host/data/database.dart';
import 'package:mafia_host/game/providers.dart';
import 'package:mafia_host/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('host plays a night and a day on the device', (tester) async {
    // Start from an empty database (the real on-device file).
    final db = AppDatabase();
    await db.transaction(() async {
      for (final table in db.allTables) {
        await db.delete(table).go();
      }
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MafiaHostApp(),
      ),
    );
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(tester.element(find.byType(Scaffold).first));

    Future<void> tap(Finder f) async {
      await tester.ensureVisible(f.first);
      await tester.pumpAndSettle();
      await tester.tap(f.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
    }

    // Setup: five players, suggested roles.
    await tap(find.text(l.homeNewGame));
    for (final name in ['Ahmed', 'Sara', 'Omar', 'Laila', 'Youssef']) {
      await tester.enterText(find.byKey(const Key('playerNameField')), name);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }
    await tap(find.text(l.setupDealRoles));
    await tap(find.text(l.dealStartGame));
    expect(find.text(l.stageNight(1)), findsOneWidget);
    expect(await WakelockPlus.enabled, isTrue, reason: 'screen kept on in the game');

    // Night: plays the night cue for real, then "no action" for every role.
    await tap(find.text(l.nightBegin));
    expect(tester.takeException(), isNull, reason: 'night sound must not throw');
    while (find.byKey(const Key('nightNext')).evaluate().isNotEmpty) {
      await tap(find.byKey(const Key('noAction')));
      await tap(find.byKey(const Key('nightNext')));
    }
    await tap(find.byKey(const Key('resolveNight')));
    expect(tester.takeException(), isNull, reason: 'morning sound must not throw');
    expect(find.text(l.announceNobodyDied), findsOneWidget);

    // Day: no vote, on to night 2.
    await tap(find.byKey(const Key('startDay')));
    await tap(find.byKey(const Key('skipVote')));
    await tap(find.byKey(const Key('startNight')));
    expect(find.text(l.stageNight(2)), findsOneWidget);
    expect(await WakelockPlus.enabled, isTrue);

    // Back home: wake lock released, game saved and offered to continue.
    await tap(find.byType(BackButton));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(await WakelockPlus.enabled, isFalse, reason: 'released after leaving the game');
    expect(find.textContaining(l.homeContinueGame), findsOneWidget);
  });
}
