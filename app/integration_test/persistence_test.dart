// On-device check that a game survives a real app restart (new process).
// Run twice, keeping the app installed between runs:
//   flutter test integration_test/persistence_test.dart -d <id> --no-uninstall --dart-define=PHASE=save
//   flutter test integration_test/persistence_test.dart -d <id> --dart-define=PHASE=restore
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mafia_engine/mafia_engine.dart';
import 'package:mafia_host/data/database.dart';
import 'package:mafia_host/game/game_input.dart';
import 'package:mafia_host/game/game_session.dart';
import 'package:mafia_host/game/providers.dart';

const phase = String.fromEnvironment('PHASE');

GameSetup table() => GameSetup(
  settings: const GameSettings(bombVictimCount: 3, revealRoleOnDeath: true),
  discussionSeconds: 120,
  players: const [
    Player(id: 'p0', name: 'Ahmed', role: Role.godfather),
    Player(id: 'p1', name: 'Sara', role: Role.doctor),
    Player(id: 'p2', name: 'Omar', role: Role.civilian),
    Player(id: 'p3', name: 'Laila', role: Role.civilian),
    Player(id: 'p4', name: 'Youssef', role: Role.chameleon, chameleonRole: Role.detective),
  ],
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('save: start a game and resolve night 1', () async {
    final db = AppDatabase();
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    await db.transaction(() async {
      for (final table in db.allTables) {
        await db.delete(table).go();
      }
    });
    await container.read(activeGameProvider.future);
    final game = container.read(activeGameProvider.notifier);
    await game.start(table());
    await game.apply(const NightInput([MafiaKill('p0', 'p2'), DetectiveCheck('p4', 'p0')]));
    await game.apply(const AdvanceInput());
    container.dispose();
    await db.close();
  }, skip: phase != 'save');

  test('restore: the game is back after a restart', () async {
    final db = AppDatabase();
    final container = ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    final session = await container.read(activeGameProvider.future);

    expect(session, isNotNull, reason: 'unfinished game must be restored');
    expect(session!.stage, GameStage.day);
    expect(session.round, 1);
    expect(session.state.player('p2').isAlive, isFalse);
    expect(session.state.player('p4').effectiveRole, Role.detective, reason: 'Chameleon pick');
    expect(session.setup.settings.bombVictimCount, 3);
    expect(session.setup.settings.revealRoleOnDeath, isTrue);
    expect(session.setup.discussionSeconds, 120);
    expect(session.log, hasLength(2));
    container.dispose();
    await db.close();
  }, skip: phase != 'restore');
}
