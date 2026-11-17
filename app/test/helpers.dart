import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/app.dart';
import 'package:mafia_host/common/l10n.dart';
import 'package:mafia_host/common/screen_awake.dart';
import 'package:mafia_host/common/sounds.dart';
import 'package:mafia_host/data/database.dart';
import 'package:mafia_host/game/game_flow_screen.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/providers.dart';
import 'package:mafia_host/l10n/app_localizations.dart';

Player p(String id, Role role, {Role? as}) =>
    Player(id: id, name: id.toUpperCase(), role: role, chameleonRole: as);

AppDatabase memoryDb() => AppDatabase(NativeDatabase.memory());

/// Records keep-screen-on requests instead of calling the native plugin.
class FakeScreenAwake implements ScreenAwake {
  final List<bool> calls = [];
  bool get isOn => calls.lastOrNull ?? false;

  @override
  Future<void> keepOn(bool on) async => calls.add(on);
}

/// Records sounds instead of playing them.
class FakeSoundPlayer implements SoundPlayer {
  final List<GameSound> played = [];

  @override
  Future<void> play(GameSound sound) async => played.add(sound);
}

ProviderContainer containerFor(AppDatabase db, {ScreenAwake? screenAwake, SoundPlayer? sounds}) =>
    ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        screenAwakeProvider.overrideWithValue(screenAwake ?? FakeScreenAwake()),
        soundPlayerProvider.overrideWithValue(sounds ?? FakeSoundPlayer()),
      ],
    );

/// Starts [setup] as the active game and shows the game flow screen.
Future<ProviderContainer> pumpGame(
  WidgetTester tester,
  GameSetup setup, {
  Locale locale = const Locale('en'),
  AppDatabase? db,
  ScreenAwake? screenAwake,
  SoundPlayer? sounds,
}) async {
  usePhoneSize(tester);
  final container = containerFor(db ?? memoryDb(), screenAwake: screenAwake, sounds: sounds);
  addTearDown(container.dispose);
  await tester.runAsync(() async {
    await container.read(activeGameProvider.future);
    await container.read(activeGameProvider.notifier).start(setup);
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: testApp(const GameFlowScreen(), locale: locale),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Widget testApp(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  theme: buildTheme(Brightness.light),
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

AppLocalizations l10nOf(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(Scaffold).first));

/// A 390×844 phone screen.
void usePhoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Scrolls the main list until [finder] is built and on screen.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    final scrollable = find.byType(Scrollable).first;
    try {
      await tester.scrollUntilVisible(finder, 150, scrollable: scrollable, maxScrolls: 20);
    } on StateError {
      await tester.scrollUntilVisible(finder, -150, scrollable: scrollable, maxScrolls: 40);
    }
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}

Future<void> tapKey(WidgetTester tester, String key) => tapFinder(tester, find.byKey(Key(key)));

Future<void> tapText(WidgetTester tester, String text) => tapFinder(tester, find.text(text));

Future<void> tapFinder(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

/// Picks [targetId] (or "no action" when null) and goes to the next step.
Future<void> nightPick(WidgetTester tester, String? targetId) async {
  await tapKey(tester, targetId == null ? 'noAction' : 'target_$targetId');
  await tapKey(tester, 'nightNext');
}

/// Casts votes: target → voters.
Future<void> castVotes(WidgetTester tester, Map<String, List<String>> votes) async {
  for (final MapEntry(key: target, value: voters) in votes.entries) {
    final header = find.descendant(
      of: find.byKey(Key('candidate_$target')),
      matching: find.byType(ListTile),
    );
    await tapFinder(tester, header);
    for (final v in voters) {
      await tapKey(tester, 'vote_${v}_for_$target');
    }
    await tapFinder(tester, header); // collapse
  }
  await tapKey(tester, 'countVotes');
}
