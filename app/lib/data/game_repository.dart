import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:mafia_engine/mafia_engine.dart';

import '../game/codec.dart';
import '../game/game_session.dart';
import 'database.dart';

class GameRepository {
  GameRepository(this._db);

  final AppDatabase _db;

  Future<int> createGame(GameSetup setup) => _db.transaction(() async {
    // Only one game is active at a time.
    await (_db.update(_db.games)..where((g) => g.status.equalsValue(GameStatus.active))).write(
      const GamesCompanion(status: Value(GameStatus.abandoned)),
    );
    final id = await _db
        .into(_db.games)
        .insert(
          GamesCompanion.insert(
            createdAt: DateTime.now(),
            settingsJson: jsonEncode(
              settingsToJson(setup.settings, discussionSeconds: setup.discussionSeconds),
            ),
            status: GameStatus.active,
          ),
        );
    await _db.batch(
      (b) => b.insertAll(_db.gamePlayers, [
        for (final (seat, p) in setup.players.indexed)
          GamePlayersCompanion.insert(
            gameId: id,
            seat: seat,
            playerId: p.id,
            name: p.name,
            role: p.role.name,
            chameleonRole: Value(p.chameleonRole?.name),
          ),
      ]),
    );
    return id;
  });

  /// Persists [session]'s inputs and status. Inputs are append-only except
  /// for undo, so this writes the tail and trims anything past it.
  Future<void> save(GameSession session) => _db.transaction(() async {
    final id = session.gameId;
    final stored = await _inputCount(id);
    final inputs = session.inputs;
    await (_db.delete(
      _db.gameInputs,
    )..where((i) => i.gameId.equals(id) & i.seq.isBiggerOrEqualValue(inputs.length))).go();
    for (var seq = stored.clamp(0, inputs.length); seq < inputs.length; seq++) {
      await _db
          .into(_db.gameInputs)
          .insert(
            GameInputsCompanion.insert(
              gameId: id,
              seq: seq,
              payloadJson: jsonEncode(inputToJson(inputs[seq])),
            ),
          );
    }
    final over = session.stage == GameStage.gameOver;
    await (_db.update(_db.games)..where((g) => g.id.equals(id))).write(
      GamesCompanion(
        status: Value(over ? GameStatus.finished : GameStatus.active),
        winner: Value(session.state.winner?.name),
      ),
    );
  });

  Future<void> abandon(int gameId) => (_db.update(_db.games)..where((g) => g.id.equals(gameId)))
      .write(const GamesCompanion(status: Value(GameStatus.abandoned)));

  /// The game to continue, if one was left unfinished.
  Future<GameSession?> loadActiveGame() async {
    final game =
        await (_db.select(_db.games)
              ..where((g) => g.status.equalsValue(GameStatus.active))
              ..orderBy([(g) => OrderingTerm.desc(g.id)])
              ..limit(1))
            .getSingleOrNull();
    return game == null ? null : _load(game);
  }

  /// Win counts over every finished game.
  Future<TableStats> tableStats() async {
    final rows = await (_db.select(
      _db.games,
    )..where((g) => g.status.equalsValue(GameStatus.finished))).get();
    return TableStats(
      games: rows.length,
      mafiaWins: rows.where((g) => g.winner == Team.mafia.name).length,
      civilianWins: rows.where((g) => g.winner == Team.civilians.name).length,
    );
  }

  /// The most recent finished games, newest first.
  Future<List<GameSummary>> recentGames({int limit = 3}) async {
    final games =
        await (_db.select(_db.games)
              ..where((g) => g.status.equalsValue(GameStatus.finished))
              ..orderBy([(g) => OrderingTerm.desc(g.id)])
              ..limit(limit))
            .get();
    return [
      for (final g in games)
        if (await _load(g) case final session)
          GameSummary(
            id: g.id,
            playedAt: g.createdAt,
            winner: session.state.winner,
            nights: session.state.nightNumber,
            players: session.state.players.length,
          ),
    ];
  }

  /// Every finished game, newest first, replayed.
  Future<List<(Game, GameSession)>> _finished() async {
    final games =
        await (_db.select(_db.games)
              ..where((g) => g.status.equalsValue(GameStatus.finished))
              ..orderBy([(g) => OrderingTerm.desc(g.id)]))
            .get();
    return [for (final g in games) (g, await _load(g))];
  }

  /// Each player's results over all finished games (matched by name), most
  /// wins first, then by win rate and games played.
  Future<List<PlayerRecord>> playerRecords() async {
    final byName = <String, PlayerRecord>{};
    for (final (game, session) in await _finished()) {
      final winner = session.state.winner;
      for (final p in session.state.players) {
        final r = byName[p.name] ??= PlayerRecord(name: p.name, lastPlayed: game.createdAt);
        r.games++;
        if (p.team == winner) r.wins++;
        r.roles[p.effectiveRole] = (r.roles[p.effectiveRole] ?? 0) + 1;
        if (p.team == Team.mafia) r.mafiaGames++;
      }
    }
    return byName.values.toList()..sort(
      (a, b) => b.wins != a.wins
          ? b.wins.compareTo(a.wins)
          : b.winRate != a.winRate
          ? b.winRate.compareTo(a.winRate)
          : b.games.compareTo(a.games),
    );
  }

  /// Finished games grouped by the date they were played, newest first.
  Future<List<GameNight>> gameNights() async {
    final nights = <DateTime, GameNight>{};
    for (final (game, session) in await _finished()) {
      final t = game.createdAt;
      final day = DateTime(t.year, t.month, t.day);
      final night = nights[day] ??= GameNight(date: day);
      night.games.add(
        GameSummary(
          id: game.id,
          playedAt: game.createdAt,
          winner: session.state.winner,
          nights: session.state.nightNumber,
          players: session.state.players.length,
        ),
      );
      for (final p in session.state.players) {
        if (!night.players.contains(p.name)) night.players.add(p.name);
      }
    }
    for (final n in nights.values) {
      n.players.sort();
    }
    return nights.values.toList();
  }

  Future<GameSession> _load(Game game) async {
    final players =
        await (_db.select(_db.gamePlayers)
              ..where((p) => p.gameId.equals(game.id))
              ..orderBy([(p) => OrderingTerm.asc(p.seat)]))
            .get();
    final inputs =
        await (_db.select(_db.gameInputs)
              ..where((i) => i.gameId.equals(game.id))
              ..orderBy([(i) => OrderingTerm.asc(i.seq)]))
            .get();
    final settingsJson = jsonDecode(game.settingsJson) as Map<String, Object?>;
    final setup = GameSetup(
      settings: settingsFromJson(settingsJson),
      discussionSeconds: discussionSecondsFromJson(settingsJson),
      players: [
        for (final p in players)
          Player(
            id: p.playerId,
            name: p.name,
            role: Role.values.byName(p.role),
            chameleonRole: p.chameleonRole == null ? null : Role.values.byName(p.chameleonRole!),
          ),
      ],
    );
    return GameSession.replay(game.id, setup, [
      for (final i in inputs) inputFromJson(jsonDecode(i.payloadJson) as Map<String, Object?>),
    ]);
  }

  /// Names from the most recent game, in seating order, to prefill setup.
  Future<List<String>> lastPlayerNames() async {
    final game =
        await (_db.select(_db.games)
              ..orderBy([(g) => OrderingTerm.desc(g.id)])
              ..limit(1))
            .getSingleOrNull();
    if (game == null) return const [];
    final rows =
        await (_db.select(_db.gamePlayers)
              ..where((p) => p.gameId.equals(game.id))
              ..orderBy([(p) => OrderingTerm.asc(p.seat)]))
            .get();
    return [for (final r in rows) r.name];
  }

  Future<int> _inputCount(int gameId) async {
    final count = _db.gameInputs.seq.count();
    final row =
        await (_db.selectOnly(_db.gameInputs)
              ..addColumns([count])
              ..where(_db.gameInputs.gameId.equals(gameId)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<String?> preference(String key) async => (await (_db.select(
    _db.preferences,
  )..where((p) => p.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setPreference(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_db.preferences)..where((p) => p.key.equals(key))).go();
    } else {
      await _db
          .into(_db.preferences)
          .insertOnConflictUpdate(PreferencesCompanion.insert(key: key, value: value));
    }
  }
}

/// Totals for the Home "Your table" tiles.
final class TableStats {
  const TableStats({this.games = 0, this.mafiaWins = 0, this.civilianWins = 0});

  final int games;
  final int mafiaWins;
  final int civilianWins;

  /// Percent of finished games won by [team], or null with no games.
  int? winRate(Team team) =>
      games == 0 ? null : ((team == Team.mafia ? mafiaWins : civilianWins) * 100 / games).round();
}

/// One finished game in the Home "recent games" list.
final class GameSummary {
  const GameSummary({
    required this.id,
    required this.playedAt,
    required this.winner,
    required this.nights,
    required this.players,
  });

  final int id;
  final DateTime playedAt;
  final Team? winner;
  final int nights;
  final int players;
}

/// One player's history (by name) across finished games.
final class PlayerRecord {
  PlayerRecord({required this.name, required this.lastPlayed});

  final String name;
  final DateTime lastPlayed;
  int games = 0;
  int wins = 0;
  int mafiaGames = 0;

  /// Role played → times.
  final Map<Role, int> roles = {};

  int get winRate => games == 0 ? 0 : (wins * 100 / games).round();

  Role? get favoriteRole =>
      roles.isEmpty ? null : roles.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}

/// The games played on one date: an evening at the table.
final class GameNight {
  GameNight({required this.date});

  final DateTime date;
  final List<GameSummary> games = [];

  /// Everyone who played that night, sorted.
  final List<String> players = [];
}
