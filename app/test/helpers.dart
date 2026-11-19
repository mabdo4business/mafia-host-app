import 'package:drift/native.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/common/l10n.dart';
import 'package:mafia_host/common/narrator.dart';
import 'package:mafia_host/common/screen_awake.dart';
import 'package:mafia_host/common/sounds.dart';
import 'package:mafia_host/data/database.dart';
import 'package:mafia_host/game/game_flow_screen.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/providers.dart';
import 'package:mafia_host/l10n/app_localizations.dart';
import 'package:mafia_host/theme/app_theme.dart';

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

/// Records what would be read aloud.
class FakeNarrator implements Narrator {
  final List<List<String>> read = [];
  Locale? lastLocale;
  int stops = 0;

  @override
  final ValueNotifier<bool> speaking = ValueNotifier(false);

  @override
  Future<void> speak(List<String> lines, Locale locale) async {
    read.add(lines);
    lastLocale = locale;
    speaking.value = true;
  }

  @override
  Future<void> stop() async {
    stops++;
    speaking.value = false;
  }
}

/// Records sounds instead of playing them.
class FakeSoundPlayer implements SoundPlayer {
  final List<GameSound> played = [];

  @override
  Future<void> play(GameSound sound) async => played.add(sound);
}

ProviderContainer containerFor(
  AppDatabase db, {
  ScreenAwake? screenAwake,
  SoundPlayer? sounds,
  Narrator? narrator,
}) => ProviderContainer(
  overrides: [
    narratorProvider.overrideWithValue(narrator ?? FakeNarrator()),
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
  Narrator? narrator,
}) async {
  usePhoneSize(tester);
  final container = containerFor(
    db ?? memoryDb(),
    screenAwake: screenAwake,
    sounds: sounds,
    narrator: narrator,
  );
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
  theme: AppTheme.night(locale),
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // Screens honor reduced motion by jumping to end states; this also stops
  // the game-over glow pulse from keeping pumpAndSettle busy.
  builder: (context, child) =>
      MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
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

/// Picks [targetId] (or "no action" when null) and goes to the next step
/// (past the Detective's full-screen answer, if shown).
Future<void> nightPick(WidgetTester tester, String? targetId) async {
  await tapKey(tester, targetId == null ? 'noAction' : 'target_$targetId');
  await tapKey(tester, 'nightNext');
  if (find.byKey(const Key('detectiveDone')).evaluate().isNotEmpty) {
    await tapKey(tester, 'detectiveDone');
  }
}

/// Opens the Voting tab if the day starts on Discussion.
Future<void> openVoting(WidgetTester tester) async {
  if (find.byKey(const Key('startVoting')).evaluate().isNotEmpty) {
    await tapKey(tester, 'startVoting');
  }
}

/// Ends the day without a vote.
Future<void> skipVote(WidgetTester tester) async {
  await openVoting(tester);
  await tapKey(tester, 'skipVote');
}

/// Opens the game menu and picks [item] (log, undo, end, home).
Future<void> gameMenu(WidgetTester tester, String item) async {
  await tapKey(tester, 'gameMenu');
  await tapKey(tester, 'menu_$item');
}

/// Counts raised hands: target → voters (one tap per voter), then submits.
Future<void> castVotes(WidgetTester tester, Map<String, List<String>> votes) async {
  await openVoting(tester);
  for (final MapEntry(key: target, value: voters) in votes.entries) {
    for (var i = 0; i < voters.length; i++) {
      await tapKey(tester, 'voteRow_$target');
    }
  }
  await tapKey(tester, 'countVotes');
}
