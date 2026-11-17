import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

enum GameStatus { active, finished, abandoned }

/// One row per game. `settingsJson` holds the engine's [GameSettings] flags
/// plus app-level options (discussion timer).
class Games extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get settingsJson => text()();
  TextColumn get status => textEnum<GameStatus>()();
  TextColumn get winner => text().nullable()();
}

/// One row per seat per game.
class GamePlayers extends Table {
  IntColumn get gameId => integer().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get seat => integer()();
  TextColumn get playerId => text()();
  TextColumn get name => text()();
  TextColumn get role => text()();
  TextColumn get chameleonRole => text().nullable()();

  @override
  Set<Column> get primaryKey => {gameId, seat};
}

@DataClassName('GameInputRow')
/// The host's inputs in order (night actions, votes, Bomb victims, advances).
/// Replaying them through the engine rebuilds the game and its log.
class GameInputs extends Table {
  IntColumn get gameId => integer().references(Games, #id, onDelete: KeyAction.cascade)();
  IntColumn get seq => integer()();
  TextColumn get payloadJson => text()();

  @override
  Set<Column> get primaryKey => {gameId, seq};
}

/// App preferences (language, theme) as key/value pairs.
class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Games, GamePlayers, GameInputs, Preferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'mafia_host'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'));
}
